// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_protection.default

import std.time.*
import std.sync.*
import std.random.*
import std.collection.*
import soulsoft_extensions_options.*

/**
 * 密钥环提供程序，负责管理加密密钥环的生命周期与缓存。
 *
 * ## 职责
 * - 维护一个线程安全的 `CacheableKeyRing` 缓存，对外提供当前有效的密钥环
 * - 缓存过期后自动刷新：重新拉取密钥列表、解析默认密钥，并在必要时生成新密钥
 * - 在存储故障时优雅降级，临时延长旧缓存有效期，避免服务中断
 *
 * ## 并发策略（对应微软旧路径 GetCurrentKeyRingCoreOld）
 * - 快速路径（99%）：原子读缓存，有效则直接返回，零竞争
 * - 慢速路径——有旧缓存：`tryLock()`（超时=0），抢锁失败直接复用旧缓存，
 *   避免高并发场景下全部请求线程阻塞在 IO 操作上
 * - 慢速路径——无旧缓存（首次/冷启动）：`lock()` 无限等待，
 *   确保调用方必然能拿到一个可用密钥环
 * - 持锁期间使用双重检查，防止多线程重复刷新
 *
 * ## 密钥解析策略（`resolveKeyRingCore`）
 * - 通过 `IDefaultKeyResolver` 解析策略，确定当前默认密钥
 * - 若默认密钥将在（刷新周期 + 传播窗口）内过期，提前生成继任密钥，
 *   保证集群所有节点在旧密钥失效前完成同步
 * - 新密钥激活时间：无默认密钥时立即激活（消除空窗期）；
 *   有默认密钥时从旧密钥过期时刻激活（消除重叠期）
 * - `keyJustAdded` 防递归守卫：生成新密钥后递归调用自身时传入，
 *   确保至多一次递归，阻止无限循环
 *
 * ## 缓存过期时间
 * 取以下两者的较小值：
 *   - 默认密钥的 `expirationDate`（密钥到期前必须刷新）
 *   - `now + keyRingRefreshPeriod × (0.8 ~ 1.0)`（带随机抖动，防止集群惊群效应）
 */
protected class KeyRingProvider <: IKeyRingProvider {
    private let _lock = Mutex()
    private let _autoGenerateKeys: Bool
    private let _keyManager: IKeyManager
    private let _defaultKeyResolver: IDefaultKeyResolver
    private let _keyRingRefreshPeriod: Duration
    private let _keyPropagationWindow: Duration
    private let _newKeyLifetime: Duration
    private let _cacheKeyRing = AtomicOptionReference<CacheableKeyRing>()
    private let _jitterRandom = Random()
    // 启动后 2 分钟内为自动刷新窗口：解密遇到未知密钥时强制刷新一次，
    private let _autoRefreshWindowEnd: DateTime

    public init(keyManager: IKeyManager, defaultKeyResolver: IDefaultKeyResolver,
        options: IOptions<KeyManagementOptions>) {
        _keyManager = keyManager
        _defaultKeyResolver = defaultKeyResolver
        _autoGenerateKeys = options.value.autoGenerateKeys
        _keyRingRefreshPeriod = options.value.keyRingRefreshPeriod
        _keyPropagationWindow = options.value.keyPropagationWindow
        _newKeyLifetime = options.value.newKeyLifetime
        _autoRefreshWindowEnd = DateTime.nowUTC() + Duration.minute * 2
    }

    public func getCurrentKeyRing(): IKeyRing {
        if (let Some(cached) <- _cacheKeyRing.load() && cached.isValid()) {
            return cached.keyRing
        }
        return createCacheableKeyRingCore()
    }

    // 判断当前是否仍在启动后的自动刷新窗口（2 分钟）内
    public func inAutoRefreshWindow(): Bool {
        return DateTime.nowUTC() < _autoRefreshWindowEnd
    }

    // 强制刷新密钥环（解密遇到未知密钥时调用，仅在自动刷新窗口内有效）
    public func refreshCurrentKeyRing(): IKeyRing {
        return createCacheableKeyRingCore(forceRefresh: true)
    }

    private func createCacheableKeyRingCore(forceRefresh!: Bool = false): IKeyRing {
        // forceRefresh=true → 强制刷新（解密遇到未知密钥时触发），始终阻塞等待锁
        // forceRefresh=false → 正常刷新：
        //   有旧缓存 → tryLock()（超时=0），抢不到锁直接复用旧缓存，避免高并发全线程阻塞
        //   无旧缓存 → lock()（无限等待），调用方必须拿到一个可用密钥环
        let existingCache = _cacheKeyRing.load()

        if (forceRefresh) {
            _lock.lock()
        } else if (let Some(stale) <- existingCache) {
            if (!_lock.tryLock()) {
                return stale.keyRing
            }
        } else {
            _lock.lock()
        }

        // 此处已持有锁，用 try/finally 保证必然解锁
        try {
            // 双重检查：forceRefresh 时跳过，确保强制刷新生效
            if (!forceRefresh) {
                if (let Some(cached) <- _cacheKeyRing.load() && cached.isValid()) {
                    return cached.keyRing
                }
            }

            // 保留旧缓存引用，供异常容错使用
            let staleCache = _cacheKeyRing.load()

            try {
                // 先取令牌，再加载密钥：若撤销发生在加载过程中，令牌已触发，缓存将立即失效
                let token = _keyManager.getCacheExpirationToken()

                // 解析密钥环（含密钥生成和防递归逻辑）
                let (defaultKey, allKeys) = resolveKeyRingCore(None)
                let keyRing = KeyRing(defaultKey, allKeys, _keyManager)

                // 缓存过期时间 = min(默认密钥过期时间, now + 带抖动刷新周期)
                let currentTime = DateTime.nowUTC()
                let nextRefresh = currentTime + getRefreshPeriodWithJitter()
                // 仅当默认密钥未来才过期时，才将其过期时间用作缓存上限；
                // 若回退密钥已过期（expirationDate <= now），强制使用 nextRefresh，
                // 避免 expirationTime 落在过去导致缓存立刻失效、陷入无限刷新循环
                let expirationTime = if (defaultKey.expirationDate > currentTime &&
                    defaultKey.expirationDate < nextRefresh) {
                    defaultKey.expirationDate
                } else {
                    nextRefresh
                }

                let newCache = CacheableKeyRing(keyRing, expirationTime, token)
                _cacheKeyRing.swap(newCache)
                return newCache.keyRing
            } catch (e: Exception) {
                // 存储故障时临时延长旧缓存 2 分钟，防止线程堆积
                if (let Some(stale) <- staleCache) {
                    _cacheKeyRing.swap(stale.withTemporaryExtendedLifetime())
                }
                throw e
            }
        } finally {
            _lock.unlock()
        }
    }

    // 解析 (defaultKey, allKeys)。
    // keyJustAdded：防递归守卫 —— 本次调用已新建密钥时传入，阻止再次触发生成逻辑。
    private func resolveKeyRingCore(keyJustAdded: ?IKey): (IKey, ReadOnlyList<IKey>) {
        let currentTime = DateTime.nowUTC()
        let allKeys = _keyManager.getAllKeys()
        let policy = _defaultKeyResolver.resolve(allKeys)

        // 防递归守卫：已新建密钥，取最优可用密钥直接返回（不再生成）
        if (let Some(justAdded) <- keyJustAdded) {
            let keyToUse = if (let Some(dk) <- policy.defaultKey) {
                dk
            } else if (let Some(fk) <- policy.fallbackKey) {
                fk
            } else {
                justAdded
            }
            return (keyToUse, allKeys)
        }

        // 判断是否需要生成新密钥：默认密钥在传播窗口内即将过期，或根本不存在
        let minExpirationDate = currentTime + _keyRingRefreshPeriod + _keyPropagationWindow
        var shouldGenerateNewKey = if (let Some(dk) <- policy.defaultKey) {
            dk.expirationDate < minExpirationDate
        } else {
            true
        }

        // 即便默认密钥即将到期，若已有继任密钥（其他节点已提前生成），则无需再生成
        if (shouldGenerateNewKey) {
            if (let Some(dk) <- policy.defaultKey) {
                let successors = allKeys |> filter { k =>
                    !k.isRevoked &&
                    k.keyId != dk.keyId &&
                    k.activationDate <= dk.expirationDate &&
                    k.expirationDate > dk.expirationDate
                } |> collectArray
                if (successors.size > 0) {
                    // 存在继任密钥
                    shouldGenerateNewKey = false
                }
            }
        }

        if (!shouldGenerateNewKey) {
            return (policy.defaultKey.getOrThrow(), allKeys)
        }

        // 自动生成已禁用，返回最优可用密钥或抛出异常
        if (!_autoGenerateKeys) {
            let keyToUse = if (let Some(dk) <- policy.defaultKey) {
                dk
            } else {
                policy.fallbackKey.getOrThrow {
                    UnsupportedException("No usable key found")
                }
            }
            return (keyToUse, allKeys)
        }

        // 生成新密钥，激活时间根据是否存在默认密钥分两种情况：
        //   无默认密钥 → 立即激活（now），消除空窗期
        //   有默认密钥 → 从旧密钥过期时激活，避免两把密钥时间段重叠
        let expirationDate = currentTime + _newKeyLifetime
        let newKey = if (let Some(defaultKey) <- policy.defaultKey) {
            _keyManager.createNewKey(defaultKey.expirationDate, expirationDate)
        } else {
            _keyManager.createNewKey(currentTime, expirationDate)
        }

        // 递归调用：重新拉取密钥列表（含新密钥）再解析；keyJustAdded 保证只递归一次
        return resolveKeyRingCore(Some(newKey))
    }

    // 带 0~20% 随机抖动的刷新周期，防止集群"惊群"效应
    private func getRefreshPeriodWithJitter(): Duration {
        _keyRingRefreshPeriod * (1.0 - _jitterRandom.nextFloat64() / 5.0)
    }
}

class CacheableKeyRing {
    CacheableKeyRing(let keyRing: IKeyRing, let expirationTime: DateTime,
        let expirationToken: IKeyExpirationToken) {
    }

    // 令牌未触发 且 未超时，则缓存有效
    public func isValid(): Bool {
        return !expirationToken.isCancel && expirationTime > DateTime.nowUTC()
    }

    public func withTemporaryExtendedLifetime(): CacheableKeyRing {
        // 被降级的密钥不允许被取消
        return CacheableKeyRing(keyRing, DateTime.nowUTC() + Duration.minute * 2, NeverExpiresToken())
    }
}

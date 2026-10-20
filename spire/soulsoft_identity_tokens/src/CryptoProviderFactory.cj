// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_tokens

import std.collection.concurrent.*
import std.reflect.*
import std.sync.*

/**
 * @brief 提供签名提供者的创建与复用能力。
 * @description 该工厂根据密钥类型和算法选择具体实现，并可选地缓存签名与验签提供者。
 */
public class CryptoProviderFactory {

    // ── 全局默认配置（先于 _default 声明，确保静态初始化顺序正确） ──

    /**
     * @brief 获取或设置全局默认的签名提供者缓存开关。
     */
    public static var defaultCacheSignatureProviders: Bool = true

    // ── 全局默认实例 ───────────────────────────────────────────────

    // AtomicReference 保证多线程并发读写 default 的内存可见性：
    // load() 提供原子读，store() 提供原子写，无需额外锁。
    private static let _default: AtomicReference<CryptoProviderFactory> = AtomicReference<CryptoProviderFactory>(
        CryptoProviderFactory())

    /**
     * @brief 获取或设置全局默认工厂实例。
     */
    public static mut prop default: CryptoProviderFactory {
        get() {
            _default.load()
        }
        set(value) {
            _default.store(value)
        }
    }

    // ── 实例状态 ───────────────────────────────────────────────────

    // ConcurrentHashMap：读非阻塞，entryView 在持锁期间原子判空插入，无需额外 Mutex
    // let 引用不变，内部并发状态由 ConcurrentHashMap 自身保证
    private let _signingCache: ConcurrentHashMap<String, SignatureProvider> = ConcurrentHashMap<String, SignatureProvider>()
    private let _verifyingCache: ConcurrentHashMap<String, SignatureProvider> = ConcurrentHashMap<String, SignatureProvider>()

    /**
     * @brief 获取或设置当前工厂是否启用签名提供者缓存。
     */
    public var cacheSignatureProviders: Bool

    /**
     * @brief 获取或设置自定义加密提供者。
     */
    public var customCryptoProvider: ?ICryptoProvider = None

    /**
     * @brief 创建加密提供者工厂实例。
     */
    public init() {
        cacheSignatureProviders = CryptoProviderFactory.defaultCacheSignatureProviders
    }

    /**
     * @brief 创建用于签名的签名提供者。
     * @param key 用于签名的安全密钥。
     * @param algorithm 签名算法标识。
     * @return 可执行签名的签名提供者。
     * @throws UnsupportedException 当密钥与算法组合不受支持时抛出。
     */
    public func createForSigning(key: SecurityKey, algorithm: String): SignatureProvider {
        createSignatureProvider(key, algorithm, willCreateSignatures: true)
    }

    /**
     * @brief 创建用于验签的签名提供者。
     * @param key 用于验签的安全密钥。
     * @param algorithm 签名算法标识。
     * @return 可执行验签的签名提供者。
     * @throws UnsupportedException 当密钥与算法组合不受支持时抛出。
     */
    public func createForVerifying(key: SecurityKey, algorithm: String): SignatureProvider {
        createSignatureProvider(key, algorithm, willCreateSignatures: false)
    }

    /**
     * @brief 归还由工厂创建的签名提供者。
     * @param provider 要归还的签名提供者。
     */
    public func releaseSignatureProvider(provider: SignatureProvider): Unit {
        if (let Some(custom) <- customCryptoProvider) {
            if (custom.isSupportedAlgorithm(provider.algorithm, provider.key, provider.willCreateSignatures)) {
                custom.releaseSignatureProvider(provider)
            }
        }
        // 内置缓存的 Provider 由工厂生命周期管理，不在此处 close
    }

    /**
     * @brief 判断指定密钥和算法组合是否受支持。
     * @param algorithm 要检查的算法标识。
     * @param key 要检查的安全密钥。
     * @return 组合受支持时返回 `true`。
     */
    public func isSupportedAlgorithm(algorithm: String, key: SecurityKey): Bool {
        if (let Some(custom) <- customCryptoProvider) {
            if (custom.isSupportedAlgorithm(algorithm, key, false)) {
                return true
            }
        }
        return SupportedAlgorithms.isSupportedAlgorithm(algorithm, key)
    }

    // ── 内部实现 ──────────────────────────────────────────────────

    private func createSignatureProvider(key: SecurityKey, algorithm: String, willCreateSignatures!: Bool): SignatureProvider {
        // 1. 自定义提供者优先
        if (let Some(custom) <- customCryptoProvider) {
            if (custom.isSupportedAlgorithm(algorithm, key, willCreateSignatures)) {
                return custom.createSignatureProvider(algorithm, key, willCreateSignatures)
            }
        }

        // 修复问题 2：缓存键只计算一次，复用于命中检测与写入两处
        let cacheKey: ?String = if (cacheSignatureProviders) {
            buildCacheKey(key, algorithm)
        } else {
            None
        }

        let cache = if (willCreateSignatures) {
            _signingCache
        } else {
            _verifyingCache
        }

        // 2. 缓存命中（ConcurrentHashMap.get 非阻塞）
        if (let Some(ck) <- cacheKey) {
            if (let Some(sp) <- cache.get(ck)) {
                return sp
            }
        }

        // 3. 校验算法兼容性：委托给 SupportedAlgorithms，与 SecurityKey.isSupportedAlgorithm 共用同一规则
        if (!SupportedAlgorithms.isSupportedAlgorithm(algorithm, key)) {
            throw UnsupportedException(
                "The combination of key (keyId: '${key.keyId ?? "null"}') and algorithm '${algorithm}' is not supported.")
        }

        // 4. buildNewProvider 在 entryView 锁内执行，保证同一 cacheKey 只有一个线程
        //    执行创建，彻底消除缓存击穿（Cache Stampede）问题。
        //    entryView 为桶级锁，不同 key 不互斥，不影响整体吞吐。
        //    无 cacheKey（匿名密钥）时直接构建，不参与缓存。
        if (let Some(ck) <- cacheKey) {
            cache.entryView(ck) {
                view => if (view.value.isNone()) {
                    view.value = buildNewProvider(key, algorithm, willCreateSignatures)
                }
            }
            return cache.get(ck).getOrThrow()
        }

        return buildNewProvider(key, algorithm, willCreateSignatures)
    }

    /// 构建缓存键。仅当 key 有稳定的 keyId 时返回键；否则返回 None（不缓存）。
    private func buildCacheKey(key: SecurityKey, algorithm: String): ?String {
        if (let Some(jwk) <- (key as JsonWebKey)) {
            if (let Some(kid) <- jwk.kid) {
                return "${kid}_${algorithm}"
            }
            return None
        }
        if (let Some(kid) <- key.keyId) {
            return "${kid}_${algorithm}"
        }
        return None
    }

    /// 根据密钥类型和算法构建具体的 SignatureProvider。
    private func buildNewProvider(
        key: SecurityKey,
        algorithm: String,
        willCreateSignatures: Bool
    ): SignatureProvider {
        // JsonWebKey 先转换为具体密钥类型
        let resolvedKey: SecurityKey = if (let Some(jwk) <- (key as JsonWebKey)) {
            JsonWebKeyConverter.convertToSecurityKey(jwk)
        } else {
            key
        }

        if (resolvedKey is SymmetricSecurityKey) {
            return SymmetricSignatureProvider(resolvedKey, algorithm, willCreateSignatures)
        }
        if (resolvedKey is AsymmetricSecurityKey) {
            return AsymmetricSignatureProvider(resolvedKey, algorithm, willCreateSignatures)
        }
        throw UnsupportedException(
            "Unsupported SecurityKey type for SignatureProvider creation: keyId='${key.keyId ?? "null"}', type=${ClassTypeInfo.of(key).name}")
    }
}

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_caching

import std.time.*
import std.sync.*
import std.collection.*
import std.collection.concurrent.*
import soulsoft_extensions_options.*

/**
 * @brief 提供基于内存的分布式缓存实现。
 */
public class MemoryDistributedCache <: IDistributedCache {
    private let _lastExpirationScan: AtomicReference<Box<DateTime>>
    private let _isScanning = AtomicBool(false)
    private let _options: DistributedCacheOptions
    private let _memory = ConcurrentHashMap<String, CacheEntry>()

    /**
     * @brief 创建基于内存的分布式缓存实例。
     * @param options 分布式缓存配置选项。
     */
    public init(options: IOptions<DistributedCacheOptions>) {
        _options = options.value
        _lastExpirationScan = AtomicReference<Box<DateTime>>(Box<DateTime>(DateTime.nowUTC()))
    }

    /**
     * @brief 获取指定键对应的缓存值。
     * @param key 缓存项的键。
     * @return 返回缓存中的二进制值；如果键不存在则返回 None。
     */
    public func get(key: String): ?Array<Byte> {
        refresh(key)
        if (let Some(value) <- _memory.get(key)) {
            return value.data
        }
        return None
    }

    /**
     * @brief 使用指定缓存选项写入二进制值。
     * @param key 缓存项的键。
     * @param value 要写入的二进制值。
     * @param options 缓存条目的过期配置。
     */
    public func set(key: String, value: Array<Byte>, options: DistributedCacheEntryOptions): Unit {
        _memory.entryView(key) {
            entryView =>
                let nowUTC = DateTime.nowUTC()
                let lastAccessTime = AtomicReference<Box<DateTime>>(Box<DateTime>(nowUTC))
                entryView.value = CacheEntry(value, nowUTC, lastAccessTime, options)
        }
        startScanForExpiredItemsIfNeeded()
    }

    /**
     * @brief 刷新指定键对应缓存项的访问状态。
     * @param key 缓存项的键。
     */
    public func refresh(key: String): Unit {
        _memory.entryView(key) {
            entryView => if (let Some(value) <- entryView.value) {
                if (value.isExpired()) {
                    entryView.value = None
                } else {
                    value.lastAccessTime.swap(Box<DateTime>(DateTime.nowUTC()))
                }
            }
        }
    }

    /**
     * @brief 删除指定键对应的缓存项。
     * @param key 缓存项的键。
     */
    public func remove(key: String): Unit {
        _memory.remove(key)
        startScanForExpiredItemsIfNeeded()
    }

    /*
    扫描过期项
     */
    private func startScanForExpiredItemsIfNeeded() {
        let nowUTC = DateTime.nowUTC()
        if (!canStartScanForExpiredItems(nowUTC)) {
            return
        }
        func scheduleTask() {
            spawn {
                try {
                    scanForExpiredItems(nowUTC)
                } finally {
                    _isScanning.store(false)
                }
            }
        }
        //处理极端场景
        if (_isScanning.compareAndSwap(false, true)) {
            scheduleTask()
        }
    }

    private func scanForExpiredItems(nowUTC: DateTime) {
        _lastExpirationScan.swap(Box<DateTime>(nowUTC))
        for ((key, value) in getCacheEntries()) {
            if (value.isExpired()) {
                _memory.remove(key)
            }
        }
    }

    private func canStartScanForExpiredItems(nowUTC: DateTime) {
        return _options.expirationScanFrequency < nowUTC - _lastExpirationScan.load().value && _memory.size > 0
    }

    private func getCacheEntries() {
        _memory |> collectArray
    }

    internal func getEntryCount() {
        _memory.size
    }
}

class CacheEntry {
    CacheEntry(let data: Array<Byte>, let creationTime: DateTime, let lastAccessTime: AtomicReference<Box<DateTime>>,
        let options: DistributedCacheEntryOptions) {
    }

    func isExpired() {
        let nowUTC = DateTime.nowUTC()
        options.absoluteExpirationRelativeToNow.flatMap {span => nowUTC - creationTime > span} == true ||
            options.absoluteExpiration.flatMap {time => nowUTC > time} == true ||
            options.slidingExpiration.flatMap {span => (nowUTC - lastAccessTime.load().value) > span} == true
    }
}

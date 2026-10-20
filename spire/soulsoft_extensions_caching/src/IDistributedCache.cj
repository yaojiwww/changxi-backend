// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_caching

/**
 * @brief 定义分布式缓存的基础读写操作。
 */
public interface IDistributedCache {
    /**
     * @brief 获取指定键对应的缓存值。
     * @param key 缓存项的键。
     * @return 返回缓存中的二进制值；如果键不存在则返回 None。
     */
    func get(key: String): ?Array<Byte>

    /**
     * @brief 刷新指定键对应缓存项的访问状态。
     * @param key 缓存项的键。
     */
    func refresh(key: String): Unit

    /**
     * @brief 删除指定键对应的缓存项。
     * @param key 缓存项的键。
     */
    func remove(key: String): Unit

    /**
     * @brief 使用默认缓存选项写入二进制值。
     * @param key 缓存项的键。
     * @param value 要写入的二进制值。
     */
    func set(key: String, value: Array<Byte>): Unit {
        set(key, value, DistributedCacheEntryOptions())
    }

    /**
     * @brief 使用指定缓存选项写入二进制值。
     * @param key 缓存项的键。
     * @param value 要写入的二进制值。
     * @param options 缓存条目的过期配置。
     */
    func set(key: String, value: Array<Byte>, options: DistributedCacheEntryOptions): Unit

    /**
     * @brief 获取指定键对应的字符串缓存值。
     * @param key 缓存项的键。
     * @return 返回缓存中的字符串值；如果键不存在则返回 None。
     */
    func getString(key: String): ?String {
        if (let Some(value) <- get(key)) {
            return String.fromUtf8(value)
        }
        return None
    }

    /**
     * @brief 使用默认缓存选项写入字符串值。
     * @param key 缓存项的键。
     * @param value 要写入的字符串值。
     */
    func setString(key: String, value: String): Unit {
        set(key, value.toArray(), DistributedCacheEntryOptions())
    }

    /**
     * @brief 使用指定缓存选项写入字符串值。
     * @param key 缓存项的键。
     * @param value 要写入的字符串值。
     * @param options 缓存条目的过期配置。
     */
    func setString(key: String, value: String, options: DistributedCacheEntryOptions): Unit {
        set(key, value.toArray(), options)
    }
}

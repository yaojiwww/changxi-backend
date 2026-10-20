// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_caching

import soulsoft_extensions_options.*
import soulsoft_extensions_injection.*

/**
 * @brief 提供分布式缓存服务注册扩展。
 */
public interface DistributedCacheExtensions {
    /**
     * @brief 注册基于内存的分布式缓存服务。
     * @return 返回当前服务集合，便于继续链式配置。
     */
    func addDistributedMemoryCache(): ServiceCollection {
        return addDistributedMemoryCache {_ =>}
    }

    /**
     * @brief 注册基于内存的分布式缓存服务并配置缓存选项。
     * @param configureOptions 用于配置分布式缓存选项的回调。
     * @return 返回当前服务集合，便于继续链式配置。
     */
    func addDistributedMemoryCache(configureOptions: (DistributedCacheOptions) -> Unit): ServiceCollection
}

extend ServiceCollection <: DistributedCacheExtensions {
    /**
     * @brief 注册基于内存的分布式缓存服务并配置缓存选项。
     * @param configureOptions 用于配置分布式缓存选项的回调。
     * @return 返回当前服务集合，便于继续链式配置。
     */
    public func addDistributedMemoryCache(configureOptions: (DistributedCacheOptions) -> Unit): ServiceCollection {
        this.configure<DistributedCacheOptions>(configureOptions)
        this.tryAddSingleton<IDistributedCache, MemoryDistributedCache>()
        return this
    }
}

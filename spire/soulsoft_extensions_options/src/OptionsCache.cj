// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_options

import std.collection.concurrent.*

/**
 * @brief 提供选项监视缓存实现。
 */
public class OptionsCache<TOptions> <: IOptionsMonitorCache<TOptions> where TOptions <: Object {
    private let _cache = ConcurrentHashMap<String, TOptions>()

    /**
     * @brief 获取指定名称的缓存项，不存在时创建并加入缓存。
     * @param name 选项名称。
     * @param createOptions 用于创建选项值的回调。
     * @return 返回缓存中的选项值。
     */
    public func getOrAdd(name: String, createOptions: () -> TOptions): TOptions {
        return _cache.entryView(name) {
            view => if (view.value.isNone()) {
                view.value = createOptions()
            }
        }.getOrThrow()
    }

    internal func add(name: String, options: TOptions): ?TOptions {
        return _cache.addIfAbsent(name, options)
    }

    internal func remove(name: String): ?TOptions {
        _cache.remove(name)
    }
}

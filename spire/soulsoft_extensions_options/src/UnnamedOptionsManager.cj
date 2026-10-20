// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_options

import std.sync.*

/**
 * @brief 提供默认名称选项的延迟初始化管理实现。
 */
public class UnnamedOptionsManager<TOptions> <: IOptions<TOptions> where TOptions <: Object {
    private var _options = AtomicOptionReference<TOptions>()
    private let _factory: IOptionsFactory<TOptions>
    private let _lock = AtomicOptionReference<Mutex>()

    /**
     * @brief 创建默认名称选项管理器。
     * @param factory 用于创建选项实例的工厂。
     */
    public init(factory: IOptionsFactory<TOptions>) {
        _factory = factory
    }

    /**
     * @brief 返回默认名称对应的选项值。
     * @return 返回默认名称对应的选项值。
     */
    public prop value: TOptions {
        get() {
            if (let Some(options) <- _options.load()) {
                return options
            }
            //延迟锁
            _lock.compareAndSwap(None, Mutex())
            synchronized(_lock.load().getOrThrow()) {
                if (let Some(options) <- _options.load()) {
                    return options
                } else {
                    _options.swap(_factory.create(Options.defaultName))
                    return _options.load().getOrThrow()
                }
            }
        }
    }
}

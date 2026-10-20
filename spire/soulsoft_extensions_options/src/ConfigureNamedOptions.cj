// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_options

import soulsoft_extensions_injection.*

/**
 * @brief 提供按名称执行选项配置的实现。
 */
public open class ConfigureNamedOptions<TOptions> <: IConfigureNamedOptions<TOptions> where TOptions <: Object {
    private let _name: ?String
    private let _services: IServiceProvider
    private let _action: (TOptions, IServiceProvider) -> Unit

    /**
     * @brief 创建按名称配置选项的实例。
     * @param name 需要匹配的选项名称；为空时表示匹配所有名称。
     * @param services 配置时使用的服务提供程序。
     * @param action 实际执行配置的委托。
     */
    public init(name: ?String, services: IServiceProvider, action: (TOptions, IServiceProvider) -> Unit) {
        _name = name
        _services = services
        _action = action
    }

    /**
     * @brief 返回当前配置器匹配的选项名称；为空时表示匹配所有名称。
     */
    public prop name: ?String {
        get() {
            _name
        }
    }

    /**
     * @brief 返回当前配置器使用的服务提供程序。
     */
    public prop services: IServiceProvider {
        get() {
            _services
        }
    }

    /**
     * @brief 返回当前配置器持有的配置委托。
     */
    public prop action: ?(TOptions, IServiceProvider) -> Unit {
        get() {
            _action
        }
    }

    /**
     * @brief 配置默认名称的选项实例。
     * @param options 需要配置的选项实例。
     */
    public func configure(options: TOptions): Unit {
        configure(Options.defaultName, options)
    }

    /**
     * @brief 配置指定名称的选项实例。
     * @param name 当前选项名称。
     * @param options 需要配置的选项实例。
     */
    public open func configure(name: ?String, options: TOptions): Unit {
        if (_name.isNone() || _name == name) {
            _action(options, _services)
        }
    }
}

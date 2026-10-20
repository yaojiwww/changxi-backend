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
 * @brief 提供默认名称选项配置的实现。
 */
public open class ConfigureOptions<TOptions> <: IConfigureOptions<TOptions> where TOptions <: Object {
    private let _services: IServiceProvider
    private let _action: ?(TOptions, IServiceProvider) -> Unit

    /**
     * @brief 创建默认名称选项配置器实例。
     * @param services 配置时使用的服务提供程序。
     * @param action 实际执行配置的委托；为空时不执行任何配置。
     */
    public init(services: IServiceProvider, action: ?(TOptions, IServiceProvider) -> Unit) {
        _action = action
        _services = services
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
     * @brief 配置选项实例。
     * @param options 需要配置的选项实例。
     */
    public open func configure(options: TOptions): Unit {
        if (let Some(action) <- _action) {
            action(options, _services)
        }
    }
}

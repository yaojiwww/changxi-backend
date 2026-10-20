// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_hosting

/**
 * @brief 提供托管服务注册扩展。
 */
public interface HostedServiceExtensions {
    /**
     * @brief 注册一个托管服务类型。
     * @return 返回当前服务集合，便于继续链式配置。
     */
    func addHostedService<THostedService>(): ServiceCollection where THostedService <: IHostedService & Object
}

extend ServiceCollection <: HostedServiceExtensions {
    /**
     * @brief 注册一个托管服务类型。
     * @return 返回当前服务集合，便于继续链式配置。
     */
    public func addHostedService<THostedService>(): ServiceCollection where THostedService <: IHostedService & Object {
        addSingleton<IHostedService, THostedService>()
        return this
    }
}

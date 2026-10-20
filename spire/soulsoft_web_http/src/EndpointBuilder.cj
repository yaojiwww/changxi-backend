// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_http

import std.collection.*
import soulsoft_extensions_injection.*

/**
 * @brief 定义构建端点实例所需的抽象成员。
 */
public abstract class EndpointBuilder {
    /**
     * @brief 创建一个端点构建器基类实例。
     */
    protected init() {
        
    }
    /**
     * @brief 返回端点元数据集合。
     * @return 当前端点元数据集合。
     */
    public prop metadata: List<Any>
    /**
     * @brief 返回端点执行委托。
     * @return 当前端点执行委托。
     */
    public prop delegate: RequestDelegate
    /**
     * @brief 返回构建端点使用的服务提供器。
     * @return 当前服务提供器。
     */
    public prop services: IServiceProvider
    /**
     * @brief 获取或设置端点显示名称。
     * @return 当前端点显示名称。
     */
    public mut prop displayName: ?String
    /**
     * @brief 构建并返回端点实例。
     * @return 构建后的端点实例。
     */
    public func build(): Endpoint
}

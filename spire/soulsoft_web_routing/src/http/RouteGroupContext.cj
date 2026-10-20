// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_routing.http

import std.collection.*
import soulsoft_web_http.*
import soulsoft_web_routing.patterns.*
import soulsoft_extensions_injection.*

/**
 * @brief 表示生成分组端点时使用的上下文。
 * @description 该上下文包含祖先路由组累计的前缀、约定以及服务提供器。
 */
public class RouteGroupContext {
    /**
     * @brief 表示当前分组链累计后的完整路由前缀。
     */
    public let prefix: ?RoutePattern

    /**
     * @brief 表示祖先路由组累计的端点约定列表。
     */
    public let conventions: ArrayList<(EndpointBuilder) -> Unit>

    /**
     * @brief 表示生成端点时使用的服务提供器。
     */
    public let services: IServiceProvider

    /**
     * @brief 创建一个路由组上下文。
     * @param prefix 当前分组链累计后的完整路由前缀。
     * @param conventions 祖先路由组累计的端点约定列表。
     * @param services 应用程序服务提供器。
     */
    public init(
        prefix: ?RoutePattern,
        conventions: ArrayList<(EndpointBuilder) -> Unit>,
        services: IServiceProvider
    ) {
        this.prefix = prefix
        this.conventions = conventions
        this.services = services
    }
}

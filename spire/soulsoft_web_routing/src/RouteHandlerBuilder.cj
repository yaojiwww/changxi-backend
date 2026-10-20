// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_routing

import std.collection.*

/**
 * @brief 提供路由端点约定的配置构建器。
 */
public class RouteHandlerBuilder <: EndpointConventionBuilder {
    private let _conventions: ArrayList<(EndpointBuilder) -> Unit>

    init(conventions: ArrayList<(EndpointBuilder) -> Unit>) {
        _conventions = conventions
    }

    /**
     * @brief 添加一个作用于端点构建器的约定。
     * @param builder 端点构建阶段执行的约定回调。
     */
    public func add(builder: (EndpointBuilder) -> Unit): Unit {
        _conventions.add(builder)
    }
}

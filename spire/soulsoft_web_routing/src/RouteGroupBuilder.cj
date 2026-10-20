// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_routing

import std.collection.*
import soulsoft_web_routing.patterns.*

/**
 * @brief 表示一组共享前缀和约定的路由构建器。
 * @description 该构建器继承端点路由构建能力，并支持为组内所有端点统一追加约定。
 */
public class RouteGroupBuilder <: EndpointRouteBuilder {
    private let _partialPrefix: RoutePattern
    private let _conventions: ArrayList<(EndpointBuilder) -> Unit>

    init(outerBuilder: EndpointRouteBuilder, partialPrefix: RoutePattern) {
        super(outerBuilder.services)
        _partialPrefix = partialPrefix
        _conventions = ArrayList<(EndpointBuilder) -> Unit>()
        // 向外部 builder 注册本组的代理数据源
        outerBuilder.dataSources.add(GroupEndpointDataSource(this))
    }

    /**
     * @brief 返回当前分组的局部路由前缀。
     * @return 路由分组前缀模式。
     */
    public prop partialPrefix: RoutePattern {
        get() { _partialPrefix }
    }

    /**
     * @brief 返回当前分组的约定列表。
     * @return 分组级端点约定集合。
     */
    public prop groupConventions: ArrayList<(EndpointBuilder) -> Unit> {
        get() { _conventions }
    }

    /**
     * @brief 添加一个分组级端点约定。
     * @description 该约定会按外层组约定、本组约定、条目级约定的顺序参与执行。
     * @param convention 分组级端点约定。
     */
    public func add(convention: (EndpointBuilder) -> Unit): Unit {
        _conventions.add(convention)
    }
}

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_routing.http

import std.reflect.*
import std.collection.*
import soulsoft_web_http.*
import soulsoft_web_routing.patterns.*

/**
 * @brief 表示可提供端点集合的数据源。
 */
public abstract class EndpointDataSource <: Equatable<EndpointDataSource> & Hashable {

    /**
     * @brief 返回当前数据源暴露的端点列表。
     * @return 端点集合。
     */
    public prop endpoints: ReadOnlyList<Endpoint>

    /**
     * @brief 为路由组生成端点列表。
     * @description 默认实现会合并路由组前缀与每个 RouteEndpoint 的路由模式，不应用构建阶段约定。
     * @param context 路由组上下文。
     * @return 路由组对应的端点列表。
     */
    public open func getGroupedEndpoints(context: RouteGroupContext): ReadOnlyList<Endpoint> {
        let result = ArrayList<Endpoint>()
        for (endpoint in endpoints) {
            if (let routeEndpoint: RouteEndpoint <- endpoint) {
                let combined = RoutePatternFactory.combine(context.prefix, routeEndpoint.routePattern)
                result.add(RouteEndpoint(combined, routeEndpoint.delegate, routeEndpoint.metadata, routeEndpoint.displayName))
            } else {
                result.add(endpoint)
            }
        }
        return result
    }

    public operator func ==(that: EndpointDataSource) {
        refEq(this, that)
    }

    /**
     * @brief 返回当前数据源实例的哈希码。
     * @return 当前实例的哈希码。
     */
    public func hashCode(): Int64 {
        ClassTypeInfo.of(this).hashCode()
    }
}

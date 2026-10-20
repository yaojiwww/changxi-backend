// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_mvc.routing

import std.collection.*
import soulsoft_web_http.*
import soulsoft_web_mvc.controllers.*

protected class ControllerActionEndpointDataSource <: ActionEndpointDataSourceBase {
    private let _endpointFactory: ActionEndpointFactory
    private let _routes = ArrayList<ConventionalRouteEntry>()

    /**
     * @brief 使用端点工厂和动作描述符提供器创建控制器动作端点数据源。
     * @param endpointFactory 用于生成端点的工厂。
     * @param actions 提供动作描述符集合的提供器。
     */
    public init(endpointFactory: ActionEndpointFactory, actions: IActionDescriptorCollectionProvider) {
        super(actions)
        _endpointFactory = endpointFactory
    }

    /**
     * @brief 添加约定路由并返回对应的端点约定构建器。
     * @param name 路由名称。
     * @param pattern 路由模板。
     * @return 与该路由关联的端点约定构建器。
     */
    public func addRoute(name: String, pattern: String): ControllerActionEndpointConventionBuilder {
        let conventions = ArrayList<(EndpointBuilder) -> Unit>()
        _routes.add(ConventionalRouteEntry(name, pattern, conventions))
        return ControllerActionEndpointConventionBuilder(this.lock, conventions)
    }

    /**
     * @brief 根据动作描述符和约定生成端点集合。
     * @param actions 要转换的控制器动作描述符集合。
     * @param conventions 要应用到端点上的约定集合。
     * @return 生成得到的端点集合。
     */
    protected func createEndpoints(actions: ReadOnlyList<ControllerActionDescriptor>,
        conventions: ArrayList<(EndpointBuilder) -> Unit>) {
        let endpoints = ArrayList<Endpoint>()
        for (action in actions) {
            _endpointFactory.addEndpoints(endpoints, action, _routes, conventions)
        }
        return endpoints
    }
}

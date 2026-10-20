// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_routing

import soulsoft_web_routing.matching.*

/**
 * @brief 定义服务集合上的路由注册扩展接口。
 */
public interface RoutingServiceCollectionExtension {
    /**
     * @brief 注册默认的路由相关服务。
     */
    func addRouting(): Unit

    /**
     * @brief 注册路由相关服务并配置路由选项。
     * @param configureOptions 路由选项配置回调。
     */
    func addRouting(configureOptions: (RouteOptions) -> Unit): Unit
}

extend ServiceCollection <: RoutingServiceCollectionExtension {
    /**
     * @brief 注册默认的路由相关服务。
     */
    public func addRouting(): Unit {
        addRouting({_ =>})
    }

    /**
     * @brief 注册路由相关服务并配置路由选项。
     * @param configureOptions 路由选项配置回调。
     */
    public func addRouting(configureOptions: (RouteOptions) -> Unit): Unit {
        this.configure(configureOptions)

        this.tryAddSingleton(RoutingMarkerService())

        this.tryAddSingleton<EndpointSelector, DefaultEndpointSelector>()
        this.tryAddEnumerable(ServiceDescriptor.singleton<INodeBuilderPolicy, HttpMethodMatcherPolicy>())

        this.tryAddSingleton<MatcherFactory, DfaMatcherFactory>()
        this.tryAddSingleton<ParameterPolicyFactory, DefaultParameterPolicyFactory>()

        this.tryAddSingleton<EndpointDataSource, CompositeEndpointDataSource> {
            sp => CompositeEndpointDataSource(sp.getOrThrow<IOptions<RouteOptions>>().value.endpointDataSources)
        }
    }
}

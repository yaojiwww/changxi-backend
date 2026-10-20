// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_routing

import soulsoft_web_http.*
import soulsoft_web_routing.matching.*

/**
 * @brief 定义应用程序构建器上的端点路由扩展接口。
 */
public interface EndpointRoutingApplicationBuilderExtensions {
    /**
     * @brief 启用端点路由匹配中间件。
     */
    func useRouting(): Unit
    /**
     * @brief 注册端点并启用端点执行中间件。
     * @param endpoints 用于配置端点的回调。
     */
    func useEndpoints(endpoints: (EndpointRouteBuilder) -> Unit): Unit
}

extend ApplicationBuilder <: EndpointRoutingApplicationBuilderExtensions {
    /**
     * @brief 向请求管道添加端点路由匹配中间件。
     */
    public func useRouting(): Unit {
        if (this.properties.contains(RoutingConstants.UseRoutingKey)) {
            return
        }
        verifyRoutingServicesAreRegistered()

        // GlobalEndpointRouteBuilderKey 由 hosting 基础设施预置（如 WebApplication 场景）；
        // 普通场景下不存在，直接创建新实例。对齐 C# DefaultEndpointRouteBuilder(builder)。
        let endpointRouteBuilder = if (let Some(obj) <- this.properties.get(RoutingConstants.GlobalEndpointRouteBuilderKey)) {
            (obj as EndpointRouteBuilder).getOrThrow()
        } else {
            EndpointRouteBuilder(this.services)
        }

        // 存到本地 key，供 useEndpoints 读取（与 GlobalEndpointRouteBuilderKey 分离）
        this.properties[RoutingConstants.EndpointRouteBuilderKey] = endpointRouteBuilder

        let matcherFactory = this.services.getOrThrow<MatcherFactory>()
        use(EndpointRoutingMiddleware(endpointRouteBuilder, matcherFactory))
        this.properties[RoutingConstants.UseRoutingKey] = useRouting
    }

    /**
     * @brief 注册端点并向请求管道添加端点执行中间件。
     * @param configure 用于配置路由端点的回调。
     */
    public func useEndpoints(configure: (EndpointRouteBuilder) -> Unit): Unit {
        if (this.properties.contains(RoutingConstants.UseEndpointsKey)) {
            return
        }
        verifyRoutingServicesAreRegistered()

        // 读取由 useRouting() 存入的构建器，同一实例传给 configure lambda：
        //   app.useEndpoints { endpoints => endpoints.mapGet("/", handler) }
        let endpointRouteBuilder = verifyEndpointRoutingMiddlewareIsRegistered()
        configure(endpointRouteBuilder)

        // 写入到 RouteOptions（供 DI 中的 CompositeEndpointDataSource 使用）
        let options = this.services.getOrThrow<IOptions<RouteOptions>>()
        for (dataSource in endpointRouteBuilder.dataSources) {
            if (!options.value.endpointDataSources.contains(dataSource)) {
                options.value.endpointDataSources.add(dataSource)
            }
        }
        use(EndpointMiddleware())
        this.properties[RoutingConstants.UseEndpointsKey] = useEndpoints
    }

    // 检测路由所需服务是否已注册
    private func verifyRoutingServicesAreRegistered(): Unit {
        let callSiteFactory = this.services.getOrThrow<IServiceProviderIsService>()
        if (!callSiteFactory.isService<RoutingMarkerService>()) {
            throw Exception(
                "Unable to find the required services. Please add all the required services by calling 'IServiceCollection.addRouting' in the application startup code.")
        }
    }

    // 检测 useRouting() 是否已调用，返回其创建的 EndpointRouteBuilder
    private func verifyEndpointRoutingMiddlewareIsRegistered(): EndpointRouteBuilder {
        if (let Some(obj) <- this.properties.get(RoutingConstants.EndpointRouteBuilderKey)) {
            return (obj as EndpointRouteBuilder).getOrThrow()
        }
        throw Exception(
            "EndpointRoutingMiddleware matches endpoints setup by EndpointMiddleware and so must be added to the request execution pipeline before EndpointMiddleware. Please add EndpointRoutingMiddleware by calling 'ApplicationBuilder.useRouting' inside the call to 'configure(...)' in the application startup code.")
    }
}

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
 * @brief 提供端点路由的构建入口。
 * @description 该构建器用于收集端点数据源，并提供按 HTTP 方法注册路由的便捷 API。
 */
public open class EndpointRouteBuilder <: ApplicationBuilder {
    private let _dataSources = ArrayList<EndpointDataSource>()

    /**
     * @brief 创建一个端点路由构建器。
     * @param services 应用程序服务提供器。
     */
    public init(services: IServiceProvider) {
        super(services)
    }

    /**
     * @brief 返回当前构建器持有的端点数据源列表。
     * @return 端点数据源集合。
     */
    public prop dataSources: List<EndpointDataSource> {
        get() {
            _dataSources
        }
    }

    /**
     * @brief 创建一个共享同一服务提供器的应用程序构建器。
     * @return 新的应用程序构建器实例。
     */
    public func createApplicationBuilder(): ApplicationBuilder {
        return new()
    }
}

extend EndpointRouteBuilder {
    /**
     * @brief 注册一个仅响应 GET 请求的路由端点。
     * @param pattern 路由模板。
     * @param delegate 请求处理委托。
     * @return 可继续配置端点约定的构建器。
     */
    public func mapGet(pattern: String, delegate: RequestDelegate): RouteHandlerBuilder {
        mapMethods(pattern, delegate, HttpMethods.Get)
    }

    /**
     * @brief 注册一个仅响应 PUT 请求的路由端点。
     * @param pattern 路由模板。
     * @param delegate 请求处理委托。
     * @return 可继续配置端点约定的构建器。
     */
    public func mapPut(pattern: String, delegate: RequestDelegate): RouteHandlerBuilder {
        mapMethods(pattern, delegate, HttpMethods.Put)
    }

    /**
     * @brief 注册一个仅响应 PATCH 请求的路由端点。
     * @param pattern 路由模板。
     * @param delegate 请求处理委托。
     * @return 可继续配置端点约定的构建器。
     */
    public func mapPatch(pattern: String, delegate: RequestDelegate): RouteHandlerBuilder {
        mapMethods(pattern, delegate, HttpMethods.Patch)
    }

    /**
     * @brief 注册一个仅响应 POST 请求的路由端点。
     * @param pattern 路由模板。
     * @param delegate 请求处理委托。
     * @return 可继续配置端点约定的构建器。
     */
    public func mapPost(pattern: String, delegate: RequestDelegate): RouteHandlerBuilder {
        mapMethods(pattern, delegate, HttpMethods.Post)
    }

    /**
     * @brief 注册一个仅响应 DELETE 请求的路由端点。
     * @param pattern 路由模板。
     * @param delegate 请求处理委托。
     * @return 可继续配置端点约定的构建器。
     */
    public func mapDelete(pattern: String, delegate: RequestDelegate): RouteHandlerBuilder {
        mapMethods(pattern, delegate, HttpMethods.Delete)
    }

    /**
     * @brief 注册一个不限制 HTTP 方法的路由端点。
     * @param pattern 路由模板。
     * @param delegate 请求处理委托。
     * @return 可继续配置端点约定的构建器。
     */
    public func map(pattern: String, delegate: RequestDelegate): RouteHandlerBuilder {
        return map(pattern, delegate, [])
    }

    /**
     * @brief 创建一个使用字符串前缀的路由分组。
     * @description 组内所有端点的路由模式都会自动追加该前缀，并可继续注册分组级约定。
     * @param prefix 路由分组前缀。
     * @return 对应的路由分组构建器。
     */
    public func mapGroup(prefix: String): RouteGroupBuilder {
        mapGroup(RoutePatternFactory.parse(prefix))
    }

    /**
     * @brief 创建一个使用路由模式前缀的路由分组。
     * @param prefix 路由分组前缀模式。
     * @return 对应的路由分组构建器。
     */
    public func mapGroup(prefix: RoutePattern): RouteGroupBuilder {
        return RouteGroupBuilder(this, prefix)
    }

    private func mapMethods(routePattern: String, delegate: RequestDelegate, httpMethods: Array<String>) {
        return map(routePattern, delegate, httpMethods)
    }

    private func map(routePattern: String, delegate: RequestDelegate, httpMethods: Array<String>) {
        let dataSource = getOrAddRouteEndpointDataSource()
        return dataSource.addRequestDelegate(routePattern, delegate, httpMethods)
    }

    private func getOrAddRouteEndpointDataSource() {
        for (i in 0..this.dataSources.size) {
            let pattern = this.dataSources[i]
            if (let foundDataSource: RouteEndpointDataSource <- pattern) {
                return foundDataSource
            }
        }
        let dataSource = RouteEndpointDataSource(this.services)
        this.dataSources.add(dataSource)
        return dataSource
    }
}

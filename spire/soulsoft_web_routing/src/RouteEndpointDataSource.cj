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

class RouteEndpointDataSource <: EndpointDataSource {
    private let _services: IServiceProvider
    private var _endpoints: ?ArrayList<Endpoint> = None
    private let _routeEntries = ArrayList<RouteEntry>()

    init(services: IServiceProvider) {
        _services = services
    }

    /**
     * @brief 返回当前数据源生成的端点列表。
     * @return 路由端点列表。
     */
    public prop endpoints: ReadOnlyList<Endpoint> {
        get() {
            if (let Some(endpoints) <- _endpoints) {
                return endpoints
            } else {
                let endpoints = ArrayList<Endpoint>()
                for (pattern in _routeEntries) {
                    let builder = createRouteEndpointBuilder(pattern)
                    endpoints.add(builder.build())
                }
                _endpoints = endpoints
                return endpoints
            }
        }
    }

    /**
     * @brief 添加一个请求处理委托对应的路由端点定义。
     * @param routePattern 路由模板。
     * @param delegate 请求处理委托。
     * @param httpMethods 允许的 HTTP 方法集合。
     * @return 用于追加端点约定的构建器。
     */
    public func addRequestDelegate(routePattern: String, delegate: RequestDelegate, httpMethods: Collection<String>): RouteHandlerBuilder {
        let conventions = ArrayList<(EndpointBuilder) -> Unit>()
        _routeEntries.add(RouteEntry(routePattern, delegate, httpMethods, conventions))
        return RouteHandlerBuilder(conventions)
    }

    public override func getGroupedEndpoints(context: RouteGroupContext): ReadOnlyList<Endpoint> {
        let endpoints = ArrayList<Endpoint>()
        for (entry in _routeEntries) {
            let builder = createGroupedRouteEndpointBuilder(entry, context.prefix, context.conventions)
            endpoints.add(builder.build())
        }
        return endpoints
    }

    private func createRouteEndpointBuilder(entry: RouteEntry) {
        let routePattern = RoutePatternFactory.parse(entry.routePattern)
        let builder = RouteEndpointBuilder(routePattern, entry.delegate, _services)
        builder.metadata.add(HttpMethodMetadata(entry.httpMethods))
        for (pattern in entry.conventions) {
            pattern(builder)
        }
        return builder
    }

    private func createGroupedRouteEndpointBuilder(
        entry: RouteEntry,
        prefix: ?RoutePattern,
        groupConventions: ArrayList<(EndpointBuilder) -> Unit>
    ) {
        let routePattern = RoutePatternFactory.parse(entry.routePattern)
        let combinedPattern = RoutePatternFactory.combine(prefix, routePattern)
        let builder = RouteEndpointBuilder(combinedPattern, entry.delegate, _services)
        builder.metadata.add(HttpMethodMetadata(entry.httpMethods))
        // 分组约定优先（低优先级在前），条目级约定在后
        for (convention in groupConventions) {
            convention(builder)
        }
        for (convention in entry.conventions) {
            convention(builder)
        }
        return builder
    }
}

struct RouteEntry {
    RouteEntry(let routePattern: String, let delegate: RequestDelegate, let httpMethods: Collection<String>,
        let conventions: ArrayList<(EndpointBuilder) -> Unit>) {
    }
}

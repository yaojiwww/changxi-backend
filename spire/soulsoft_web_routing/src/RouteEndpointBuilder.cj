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
 * @brief 提供路由端点实例的构建器。
 */
public class RouteEndpointBuilder <: EndpointBuilder {
    private let _routePattern: RoutePattern
    private let _metadata = ArrayList<Any>()
    private let _delegate: RequestDelegate
    private let _services: IServiceProvider
    private var _displayName: ?String = None

    /**
     * @brief 创建一个路由端点构建器。
     * @param routePattern 路由模式。
     * @param delegate 请求处理委托。
     * @param services 应用程序服务提供器。
     */
    public init(routePattern: RoutePattern, delegate: RequestDelegate, services: IServiceProvider) {
        _routePattern = routePattern
        _delegate = delegate
        _services = services
    }

    /**
     * @brief 返回当前端点的路由模式。
     * @return 路由模式实例。
     */
    public prop routePattern: RoutePattern {
        get() {
            _routePattern
        }
    }

    /**
     * @brief 返回当前端点的元数据集合。
     * @return 可修改的元数据列表。
     */
    public prop metadata: List<Any> {
        get() {
            _metadata
        }
    }

    /**
     * @brief 返回当前端点的请求处理委托。
     * @return 请求处理委托。
     */
    public prop delegate: RequestDelegate {
        get() {
            _delegate
        }
    }

    /**
     * @brief 返回当前端点的服务提供器。
     * @return 服务提供器实例。
     */
    public prop services: IServiceProvider {
        get() {
            _services
        }
    }

    /**
     * @brief 获取或设置端点显示名称。
     */
    public mut prop displayName: ?String {
        get() {
            _displayName
        }
        set(value) {
            _displayName = value
        }
    }

    /**
     * @brief 构建最终的端点实例。
     * @return 构建完成的端点。
     */
    public func build(): Endpoint {
        let metadata = createMetadataCollection(_metadata)
        return RouteEndpoint(_routePattern, _delegate, metadata, _displayName)
    }

    /*
    扫描 metadata 列表，若同时存在 ICorsMetadata 和 IHttpMethodMetadata，
    则将 acceptCorsPreflight 设为 true，使路由层能为该端点生成 CORS 预检分支。
     */
    private static func createMetadataCollection(metadata: List<Any>): EndpointMetadataCollection {
        if (metadata.size > 0) {
            var hasCorsMetadata = false
            var httpMethodMetadata: ?IHttpMethodMetadata = None

            for (i in 0..metadata.size) {
                // 注意：同一个 metadata 对象可能同时实现多个接口，不能用 else if
                if (let Some(m) <- (metadata[i] as IHttpMethodMetadata)) {
                    httpMethodMetadata = m
                }
                if (!hasCorsMetadata && metadata[i] is ICorsMetadata) {
                    hasCorsMetadata = true
                }
            }

            if (hasCorsMetadata) {
                if (let Some(m) <- httpMethodMetadata) {
                    if (!m.acceptCorsPreflight) {
                        m.acceptCorsPreflight = true
                    }
                }
            }
        }

        return EndpointMetadataCollection(metadata)
    }
}

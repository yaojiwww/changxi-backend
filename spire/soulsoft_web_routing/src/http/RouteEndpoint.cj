// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_routing.http

import soulsoft_web_http.*
import soulsoft_web_routing.patterns.*

/**
 * @brief 表示带有路由模式的端点。
 */
public class RouteEndpoint <: Endpoint {
    private let _routePattern: RoutePattern

    /**
     * @brief 创建一个路由端点。
     * @param routePattern 路由模式。
     * @param delegate 请求处理委托。
     * @param metadata 端点元数据集合。
     * @param displayName 端点显示名称。
     */
    public init(routePattern: RoutePattern, delegate: RequestDelegate, metadata: EndpointMetadataCollection,
        displayName: ?String) {
        super(delegate, metadata, displayName)
        _routePattern = routePattern
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

    public override func toString(): String {
        _routePattern.rawText
    }
}

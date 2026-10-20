// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_routing.http

import std.collection.*

/**
 * @brief 表示端点允许的 HTTP 方法元数据。
 */
public class HttpMethodMetadata <: IHttpMethodMetadata {
    private var _acceptCorsPreflight: Bool
    private let _httpMethods: ArrayList<String>

    /**
     * @brief 创建一个不接受 CORS 预检的 HTTP 方法元数据。
     * @param httpMethods 允许的 HTTP 方法集合。
     */
    public init(httpMethods: Collection<String>) {
        this(httpMethods, false)
    }

    /**
     * @brief 创建一个 HTTP 方法元数据实例。
     * @param httpMethods 允许的 HTTP 方法集合。
     * @param acceptCorsPreflight 是否接受 CORS 预检请求。
     */
    public init(httpMethods: Collection<String>, acceptCorsPreflight: Bool) {
        _httpMethods = ArrayList(httpMethods)
        _acceptCorsPreflight = acceptCorsPreflight
    }

    /**
     * @brief 返回允许的 HTTP 方法列表。
     * @return HTTP 方法集合。
     */
    public prop httpMethods: ReadOnlyList<String> {
        get() {
            _httpMethods
        }
    }

    /**
     * @brief 获取或设置是否接受 CORS 预检请求。
     */
    public mut prop acceptCorsPreflight: Bool {
        get() {
            _acceptCorsPreflight
        }
        set(value) {
            _acceptCorsPreflight = value
        }
    }
}

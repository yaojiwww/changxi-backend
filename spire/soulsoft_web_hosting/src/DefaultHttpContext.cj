// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_hosting

import std.collection.*
import soulsoft_identity_claims.*
import stdx.net.http.HttpContext as HttpContextBase

class DefaultHttpContext <: HttpContext {
    private let _request: DefaultHttpRequest
    private let _response: DefaultHttpResponse
    private let _services: IServiceProvider
    private var _user: ?ClaimsPrincipal = None
    private var _items: ?HashMap<String, Any> = None
    private var _features: ?IFeatureCollection = None

    init(context: HttpContextBase, services: IServiceProvider) {
        _services = services
        _request = DefaultHttpRequest(context.request)
        _response = DefaultHttpResponse(context)
        // 设置 HttpResponse.httpContext 反向引用    
        _response.setOwningContext(this)
    }

    /**
     * @brief 返回当前请求上下文关联的项目集合。
     * @return 当前项目集合。
     */
    public prop items: Map<String, Any> {
        get() {
            if (_items.isNone()) {
                _items = HashMap<String, Any>()
            }
            return _items.getOrThrow()
        }
    }

    /**
     * @brief 返回当前 HTTP 请求对象。
     * @return 当前 HTTP 请求对象。
     */
    public prop request: HttpRequest {
        get() {
            _request
        }
    }

    /**
     * @brief 返回当前 HTTP 响应对象。
     * @return 当前 HTTP 响应对象。
     */
    public prop response: HttpResponse {
        get() {
            _response
        }
    }

    /**
     * @brief 返回当前 HTTP 响应的内部实现对象。
     * @return 当前 HTTP 响应的内部实现对象。
     */
    internal prop defaultResponse: DefaultHttpResponse {
        get() {
            _response
        }
    }

    /**
     * @brief 获取或设置当前用户主体。
     * @return 当前用户主体。
     */
    public mut prop user: ClaimsPrincipal {
        get() {
            if (_user.isNone()) {
                _user = ClaimsPrincipal()
            }
            return _user.getOrThrow()
        }
        set(value) {
            _user = value
        }
    }

    /**
     * @brief 返回当前请求作用域的服务提供器。
     * @return 当前服务提供器。
     */
    public prop services: IServiceProvider {
        get() {
            _services
        }
    }

    /**
     * @brief 返回当前请求的功能集合。
     * @return 当前功能集合。
     */
    public prop features: IFeatureCollection {
        get() {
            if (_features.isNone()) {
                _features = FeatureCollection()
            }
            return _features.getOrThrow()
        }
    }

}

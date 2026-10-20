// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_web_mvc.annotations

import soulsoft_web_mvc.abstractions.*

/**
 * @brief 为动作提供 HTTP 方法和路由模板元数据。
 */
public abstract class HttpMethod <: IActionHttpMethodProvider & IRouteTemplateProvider {
    private let _template: ?String
    private let _httpMethods: String

    /**
     * @brief 使用 HTTP 方法初始化元数据。
     * @param httpMethods 要绑定的 HTTP 方法名称。
     */
    public const init(httpMethods: String) {
        this._template = None
        this._httpMethods = httpMethods
    }

    /**
     * @brief 使用 HTTP 方法和模板初始化元数据。
     * @param httpMethods 要绑定的 HTTP 方法名称。
     * @param template 要附加的路由模板。
     */
    public const init(httpMethods: String, template: String) {
        this._template = template
        this._httpMethods = httpMethods
    }

    /**
     * @brief 返回附加的路由模板。
     * @return 当前注解携带的路由模板；如果未设置则返回 `None`。
     */
    public prop template: ?String {
        get() {
            _template
        }
    }

    /**
     * @brief 返回动作支持的 HTTP 方法集合。
     * @return 当前注解声明的 HTTP 方法列表。
     */
    public prop httpMethods: Array<String> {
        get() {
            [_httpMethods]
        }
    }
}

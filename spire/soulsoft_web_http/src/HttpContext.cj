// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_http

import std.collection.*
import soulsoft_identity_claims.*
import soulsoft_extensions_injection.*

/**
 * @brief 定义 HTTP 请求处理过程中的上下文抽象。
 */
public abstract class HttpContext {
    /**
     * @brief 返回当前上下文的项目集合。
     * @return 当前上下文的项目集合。
     */
    public prop items: Map<String, Any>

    /**
     * @brief 返回当前上下文关联的 Session 对象。
     * @return 当前上下文关联的 Session 对象。
     */
    public prop session: Session {
        get() {
            if (let Some(feature) <- features.get<ISessionFeature>()) {
                return feature.session
            } else {
                DefaultSession.instance
            }
        }
    }

    /**
     * @brief 返回当前 HTTP 请求对象。
     * @return 当前 HTTP 请求对象。
     */
    public prop request: HttpRequest

    /**
     * @brief 返回当前 HTTP 响应对象。
     * @return 当前 HTTP 响应对象。
     */
    public prop response: HttpResponse

    /**
     * @brief 获取或设置当前用户主体。
     * @return 当前用户主体。
     */
    public mut prop user: ClaimsPrincipal

    /**
     * @brief 返回当前请求的服务提供器。
     * @return 当前服务提供器。
     */
    public prop services: IServiceProvider

    /**
     * @brief 返回当前上下文的功能集合。
     * @return 当前功能集合。
     */
    public prop features: IFeatureCollection
}

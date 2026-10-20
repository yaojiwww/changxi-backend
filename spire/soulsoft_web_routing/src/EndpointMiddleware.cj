// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_routing

import soulsoft_web_http.*

/**
 * @brief 提供执行已匹配端点的中间件。
 */
public class EndpointMiddleware <: IMiddleware {
    /**
     * @brief 执行当前请求对应的端点委托。
     * @param context 当前 HTTP 上下文。
     * @param next 下一个请求委托。
     */
    public func invoke(context: HttpContext, next: RequestDelegate): Unit {
        if (let Some(endpoint) <- context.getEndpoint()) {
            endpoint.delegate(context)
        } else {
            next(context)
        }
    }
}

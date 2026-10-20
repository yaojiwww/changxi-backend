// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_authorization

import soulsoft_web_http.*

/**
 * @brief 定义授权中间件结果处理器接口。
 */
public interface IAuthorizationMiddlewareResultHandler {
    /**
     * @brief 根据授权结果处理当前 HTTP 请求。
     * @param context 当前 HTTP 上下文。
     * @param next 下一个请求委托。
     * @param policy 当前授权策略。
     * @param authorizeResult 策略授权结果。
     */
    func handle(context: HttpContext, next: RequestDelegate, policy: AuthorizationPolicy,
        authorizeResult: PolicyAuthorizationResult): Unit
}

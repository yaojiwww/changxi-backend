// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_authentication

import soulsoft_web_http.*

/**
 * @brief 定义身份验证处理器的基础能力。
 */
public interface IAuthenticationHandler {
    /**
     * @brief 使用当前方案和请求上下文初始化处理器。
     * @param scheme 当前身份验证方案。
     * @param context 当前 HTTP 上下文。
     */
    func initialize(scheme: AuthenticationScheme, context: HttpContext): Unit
    /**
     * @brief 执行身份验证。
     * @return 身份验证结果。
     */
    func authenticate(): AuthenticateResult
    /**
     * @brief 触发质询流程。
     * @param properties 质询时附带的属性。
     */
    func challenge(properties: ?AuthenticationProperties): Unit
    /**
     * @brief 触发禁止访问流程。
     * @param properties 禁止访问时附带的属性。
     */
    func forbid(properties: ?AuthenticationProperties): Unit
}

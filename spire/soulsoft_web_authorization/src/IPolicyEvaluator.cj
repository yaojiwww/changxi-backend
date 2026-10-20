// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_authorization

import soulsoft_web_http.*
import soulsoft_web_authentication.*

/**
 * @brief 定义策略认证与授权执行器接口。
 */
public interface IPolicyEvaluator {
    /**
     * @brief 按策略执行认证流程。
     * @param policy 当前授权策略。
     * @param context 当前 HTTP 上下文。
     * @return 认证结果。
     */
    func authenticate(policy: AuthorizationPolicy, context: HttpContext): AuthenticateResult
    /**
     * @brief 按策略执行授权流程。
     * @param policy 当前授权策略。
     * @param authenticationResult 认证结果。
     * @param context 当前 HTTP 上下文。
     * @param resource 当前授权资源。
     * @return 策略授权结果。
     */
    func authorize(policy: AuthorizationPolicy, authenticationResult: AuthenticateResult, context: HttpContext,
        resource: ?Object): PolicyAuthorizationResult
}

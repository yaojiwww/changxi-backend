// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_cors.abstractions

import soulsoft_web_http.*

/**
 * @brief 定义按请求解析 CORS 策略的能力。
 */
public interface ICorsPolicyProvider {
    /**
     * @brief 根据请求上下文和策略名称解析 CORS 策略。
     * @param context 当前 HTTP 请求上下文。
     * @param policyName 要解析的 CORS 策略名称。
     * @return 返回解析到的 CORS 策略；如果没有匹配项则返回空。
     */
    func getPolicy(context: HttpContext, policyName: ?String): ?CorsPolicy
}

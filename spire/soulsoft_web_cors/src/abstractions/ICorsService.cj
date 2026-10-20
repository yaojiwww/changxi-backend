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
 * @brief 定义评估并应用 CORS 策略的能力。
 */
public interface ICorsService {
    /**
     * @brief 使用指定策略评估当前请求的 CORS 结果。
     * @param context 当前 HTTP 请求上下文。
     * @param policy 要评估的 CORS 策略。
     * @return 返回策略评估结果。
     */
    func evaluatePolicy(context: HttpContext, policy: CorsPolicy): CorsResult
    /**
     * @brief 将 CORS 评估结果写入响应头。
     * @param result 要应用的 CORS 评估结果。
     * @param response 要写入头信息的 HTTP 响应。
     */
    func applyResult(result: CorsResult, response: HttpResponse): Unit
}

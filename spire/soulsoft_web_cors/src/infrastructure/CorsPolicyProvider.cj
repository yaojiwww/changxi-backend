// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_cors.infrastructure

import soulsoft_web_http.*
import soulsoft_extensions_options.*
import soulsoft_web_cors.abstractions.*

/**
 * @brief 提供基于选项的 CORS 策略解析实现。
 */
public class CorsPolicyProvider <: ICorsPolicyProvider {
    private let _options: CorsOptions

    /**
     * @brief 创建一个 CORS 策略提供器实例。
     * @param options CORS 选项访问器。
     */
    public init(options: IOptions<CorsOptions>) {
        _options = options.value
    }

    /**
     * @brief 根据请求上下文和策略名称解析 CORS 策略。
     * @param context 当前 HTTP 请求上下文。
     * @param policyName 要解析的 CORS 策略名称。
     * @return 返回解析到的 CORS 策略；如果没有匹配项则返回空。
     */
    public func getPolicy(context: HttpContext, policyName: ?String): ?CorsPolicy {
        let name = policyName ?? _options.defaultPolicyName

        if (let Some(policy) <- _options.policyMap.get(name)) {
            return policy
        }

        return _options.policyResolver(context, policyName)
    }
}

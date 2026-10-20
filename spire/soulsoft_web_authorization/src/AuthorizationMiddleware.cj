// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_authorization

import std.collection.*
import soulsoft_web_http.*
import soulsoft_web_routing.*
import soulsoft_web_authentication.*
import soulsoft_extensions_options.*

/**
 * @brief 提供基于端点元数据的授权中间件。
 */
public class AuthorizationMiddleware <: IMiddleware {
    private static let MIDDLEWARE_INVOKED_KEY = "__AuthorizationMiddlewareWithEndpointInvoked"
    private let _options: AuthorizationOptions

    /**
     * @brief 创建一个授权中间件。
     * @param options 授权选项。
     */
    public init(options: IOptions<AuthorizationOptions>) {
        _options = options.value
    }

    /**
     * @brief 执行当前请求的授权流程。
     * @param context 当前 HTTP 上下文。
     * @param next 下一个请求委托。
     */
    public func invoke(context: HttpContext, next: RequestDelegate): Unit {
        // 标记授权中间件已处理端点，EndpointRoutingMiddleware 依赖此标记进行诊断
        if (context.getEndpoint().isSome()) {
            context.items[MIDDLEWARE_INVOKED_KEY] = true
        }

        if (let Some(endpoint) <- context.getEndpoint() && let Some(policy) <- resolvePolicy(context, endpoint)) {
            let policyEvaluator = context.services.getOrThrow<IPolicyEvaluator>()

            // Step 1: 执行认证，填充 context.user（AllowAnonymous 端点也需要填充 User，下游中间件可读取）
            let authenticateResult = policyEvaluator.authenticate(policy, context)

            // Step 2: 将认证结果写入 Features（必须在 AllowAnonymous 检查之前完成）
            if (authenticateResult.succeeded) {
                if (let Some(authenticateResultFeature) <- context.features.get<IAuthenticateResultFeature>()) {
                    authenticateResultFeature.result = authenticateResult
                } else {
                    let authFeatures = AuthenticationFeatures(authenticateResult)
                    context.features.set<IHttpAuthenticationFeature>(authFeatures)
                    context.features.set<IAuthenticateResultFeature>(authFeatures)
                }
            }

            // Step 3: AllowAnonymous 跳过授权失败处理，但 User 已在 Step 1/2 中填充
            if (endpoint.metadata.getMetadata<IAllowAnonymous>().isSome()) {
                next(context)
                return
            }

            // Step 4: 执行授权
            let resource = if (_options.suppressUseHttpContextAsAuthorizationResource) {
                endpoint
            } else {
                context
            }
            let authorizeResult = policyEvaluator.authorize(policy, authenticateResult, context, resource)
            let authorizationMiddlewareResultHandler = context
                .services
                .getOrThrow<IAuthorizationMiddlewareResultHandler>()
            return authorizationMiddlewareResultHandler.handle(context, next, policy, authorizeResult)
        } else {
            next(context)
        }
    }

    // 先查缓存，未命中时计算并回填缓存。
    private func resolvePolicy(context: HttpContext, endpoint: Endpoint): ?AuthorizationPolicy {
        let policyProvider = context.services.getOrThrow<IAuthorizationPolicyProvider>()
        // 仅 DefaultAuthorizationPolicyProvider（非子类）才允许缓存
        let cache: ?AuthorizationPolicyCache = if (policyProvider.allowsCachingPolicies) {
            context.services.get<AuthorizationPolicyCache>()
        } else {
            None
        }

        // 缓存命中
        if (let Some(cache) <- cache) {
            if (let Some(cached) <- cache.lookup(endpoint)) {
                return cached
            }
        }

        // 计算策略
        let policy = computePolicy(policyProvider, endpoint)

        // 回填缓存
        if (let Some(cache) <- cache) {
            if (let Some(policy) <- policy) {
                cache.store(endpoint, policy)
            }
        }

        return policy
    }

    private static func computePolicy(policyProvider: IAuthorizationPolicyProvider, endpoint: Endpoint): ?AuthorizationPolicy {
        let authorizeData = endpoint.metadata.getOrderedMetadata<IAuthorizeData>()
        let authorizePolicies = endpoint.metadata.getOrderedMetadata<AuthorizationPolicy>()
        var policy = AuthorizationPolicy.combine(policyProvider, authorizeData, authorizePolicies)

        let requirementData = endpoint.metadata.getOrderedMetadata<IAuthorizationRequirementData>()
        if (requirementData.size > 0) {
            let policyBuilder = AuthorizationPolicyBuilder()
            for (pattern in requirementData |> flatMap {f: IAuthorizationRequirementData => f.getRequirements()}) {
                policyBuilder.addRequirements(pattern)
            }
            policy = if (let Some(policy) <- policy) {
                AuthorizationPolicy.combine(policy, policyBuilder.build())
            } else {
                policyBuilder.build()
            }
        }
        return policy
    }
}

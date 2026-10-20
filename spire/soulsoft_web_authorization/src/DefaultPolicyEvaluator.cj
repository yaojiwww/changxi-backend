// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_authorization

import std.time.*
import std.collection.*
import soulsoft_web_http.*
import soulsoft_identity_claims.*
import soulsoft_web_authentication.*

/**
 * @brief 提供默认的策略认证与授权执行器。
 */
public class DefaultPolicyEvaluator <: IPolicyEvaluator {
    private let _authorizationService: IAuthorizationService

    /**
     * @brief 创建一个默认策略执行器。
     * @param authorizationService 授权服务。
     */
    public init(authorizationService: IAuthorizationService) {
        _authorizationService = authorizationService
    }

    /**
     * @brief 按策略执行认证流程。
     * @param policy 当前授权策略。
     * @param context 当前 HTTP 上下文。
     * @return 认证结果。
     */
    public func authenticate(policy: AuthorizationPolicy, context: HttpContext): AuthenticateResult {
        if (policy.authenticationSchemes.size > 0) {
            var newPrincipal: ?ClaimsPrincipal = None
            var minExpiresUtc: ?DateTime = None
            for (scheme in policy.authenticationSchemes) {
                let result = context.authenticate(scheme)
                if (result.succeeded) {
                    newPrincipal = SecurityHelper.mergeUserPrincipal(newPrincipal, result.principal)
                    // 聚合各方案 ticket 的最小过期时间，SignalR 等长连接依赖此值判断认证是否过期
                    let schemeExpires = result.ticket.flatMap {t: AuthenticationTicket => t.properties.expiresUtc}
                    minExpiresUtc = pickMinExpiry(minExpiresUtc, schemeExpires)
                }
            }
            if (let Some(newPrincipal) <- newPrincipal) {
                context.user = newPrincipal
                let schemeName = String.join(policy.authenticationSchemes |> collectArray, delimiter: ";")
                let properties = AuthenticationProperties()
                properties.expiresUtc = minExpiresUtc
                let ticket = AuthenticationTicket(newPrincipal, schemeName, properties)
                return AuthenticateResult.success(ticket)
            } else {
                context.user = ClaimsPrincipal(ClaimsIdentity())
                return AuthenticateResult.noResult()
            }
        }

        if (let Some(authenticateResultFeature) <- context.features.get<IAuthenticateResultFeature>()) {
            return authenticateResultFeature.result
        } else {
            if (context.user.identity.flatMap {f => f.isAuthenticated} ?? false) {
                return AuthenticateResult.success(AuthenticationTicket(context.user, "context.user"))
            } else {
                return AuthenticateResult.noResult()
            }
        }
    }

    // 返回两个可选过期时间中较早的那个：
    //   - 两者均为 None → None（无过期约束）
    //   - 一者为 None   → 取另一者（None 视为"无限期"，有限期优先）
    //   - 两者均有值   → 取较小值
    private static func pickMinExpiry(a: ?DateTime, b: ?DateTime): ?DateTime {
        return match ((a, b)) {
            case (None, _) => b
            case (_, None) => a
            case (Some(ta), Some(tb)) =>
                if (ta < tb) {
                    a
                } else {
                    b
                }
        }
    }

    /**
     * @brief 按策略执行授权流程。
     * @param policy 当前授权策略。
     * @param authenticationResult 认证结果。
     * @param context 当前 HTTP 上下文。
     * @param resource 当前授权资源。
     * @return 策略授权结果。
     */
    public func authorize(policy: AuthorizationPolicy, authenticationResult: AuthenticateResult, context: HttpContext,
        resource: ?Object): PolicyAuthorizationResult {
        let result = _authorizationService.authorize(context.user, resource, policy)

        if (result.succeeded) {
            return PolicyAuthorizationResult.success()
        }

        if (authenticationResult.succeeded) {
            return PolicyAuthorizationResult.forbid(result.failure)
        } else {
            return PolicyAuthorizationResult.challenge()
        }
    }
}

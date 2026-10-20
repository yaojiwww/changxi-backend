// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_authorization

import std.unicode.*
import std.collection.*
import soulsoft_web_http.*

/**
 * @brief 表示一组授权要求与认证方案的组合策略。
 */
public class AuthorizationPolicy {
    private let _requirements = ArrayList<IAuthorizationRequirement>()
    private let _authenticationSchemes = ArrayList<String>()

    /**
     * @brief 创建一个授权策略。
     * @param requirements 授权要求集合。
     * @param authenticationSchemes 认证方案集合。
     * @throws IllegalArgumentException 当授权要求集合为空时抛出。
     */
    public init(requirements: Collection<IAuthorizationRequirement>, authenticationSchemes: Collection<String>) {
        if (requirements.isEmpty()) {
            throw IllegalArgumentException("AuthorizationPolicy must have at least one requirement.")
        }
        _requirements.add(all: requirements)
        _authenticationSchemes.add(all: authenticationSchemes)
    }

    /**
     * @brief 获取授权要求集合。
     * @return 当前策略包含的授权要求集合。
     */
    public prop requirements: ReadOnlyList<IAuthorizationRequirement> {
        get() {
            _requirements
        }
    }

    /**
     * @brief 获取认证方案集合。
     * @return 当前策略允许使用的认证方案集合。
     */
    public prop authenticationSchemes: ReadOnlyList<String> {
        get() {
            _authenticationSchemes
        }
    }

    /**
     * @brief 合并多个授权策略。
     * @param policies 待合并的授权策略集合。
     * @return 合并后的授权策略。
     */
    public static func combine(policies: Array<AuthorizationPolicy>): AuthorizationPolicy {
        let builder = AuthorizationPolicyBuilder()
        for (pattern in policies) {
            builder.combine(pattern)
        }
        return builder.build()
    }

    /**
     * @brief 根据授权元数据和附加策略计算最终授权策略。
     * @param policyProvider 授权策略提供器。
     * @param authorizeData 授权元数据集合。
     * @param policies 附加授权策略集合。
     * @return 计算得到的授权策略；如果未生成策略则返回空。
     * @throws UnsupportedException 当指定的命名策略不存在时抛出。
     */
    public static func combine(policyProvider: IAuthorizationPolicyProvider, authorizeData: Collection<IAuthorizeData>,
        policies: Collection<AuthorizationPolicy>): ?AuthorizationPolicy {
        var policyBuilder: ?AuthorizationPolicyBuilder = None
        let anyPolicies = policies.size > 0
        for (pattern in authorizeData) {
            policyBuilder = policyBuilder ?? AuthorizationPolicyBuilder()
            var useDefaultPolicy = !anyPolicies

            if (let Some(policyName) <- pattern.policy && !policyName.isEmpty()) {
                if (let Some(policy) <- policyProvider.getPolicy(policyName)) {
                    policyBuilder?.combine(policy)
                    useDefaultPolicy = false
                } else {
                    throw UnsupportedException("not found policy:${policyName}")
                }
            }

            let authTypes = pattern.authenticationSchemes.flatMap {
                f => f.split(',', removeEmpty: true) |> filter {f => !f.isEmpty()} |> map {f => f.trim()} |> collectArray
            }

            if (let Some(authTypes) <- authTypes) {
                for (pattern in authTypes) {
                    policyBuilder.flatMap {f => f.authenticationSchemes.add(pattern)}
                }
            }

            if (let Some(rolesStr) <- pattern.roles && !rolesStr.isEmpty()) {
                let roles = rolesStr.split(',', removeEmpty: true) |> filter {f => !f.isEmpty()} |> map {f => f.trim()} |>
                    collectArray
                policyBuilder.flatMap {f => f.requireRole(roles)}
                useDefaultPolicy = false
            }

            if (useDefaultPolicy) {
                if (let Some(policyBuilder) <- policyBuilder) {
                    policyBuilder.combine(policyProvider.getDefaultPolicy())
                }
            }
        }
        if (anyPolicies) {
            policyBuilder = policyBuilder ?? AuthorizationPolicyBuilder()
            for (pattern in policies) {
                policyBuilder.flatMap {f => f.combine(pattern)}
            }
        }

        if (policyBuilder.isNone()) {
            if (let Some(fallbackPolicy) <- policyProvider.getFallbackPolicy()) {
                return fallbackPolicy
            }
        }
        return policyBuilder?.build()
    }
}

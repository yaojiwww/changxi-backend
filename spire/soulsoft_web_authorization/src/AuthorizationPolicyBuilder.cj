// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_authorization

import std.collection.*
import soulsoft_identity_claims.*

/**
 * @brief 提供授权策略的构建器。
 */
public class AuthorizationPolicyBuilder {
    private let _authenticationSchemes = ArrayList<String>()
    private let _requirements = ArrayList<IAuthorizationRequirement>()
    private static let _denyAnonymousAuthorizationRequirement = DenyAnonymousAuthorizationRequirement()

    /**
     * @brief 使用认证方案集合创建授权策略构建器。
     * @param authenticationSchemes 认证方案集合。
     */
    public init(authenticationSchemes: Array<String>) {
        addAuthenticationSchemes(authenticationSchemes)
    }

    /**
     * @brief 使用现有授权策略创建授权策略构建器。
     * @param policy 现有授权策略。
     */
    public init(policy: AuthorizationPolicy) {
        combine(policy)
    }

    /**
     * @brief 获取当前构建器中的授权要求集合。
     * @return 当前构建器累计的授权要求集合。
     */
    public prop requirements: List<IAuthorizationRequirement> {
        get() {
            _requirements
        }
    }

    /**
     * @brief 获取当前构建器中的认证方案集合。
     * @return 当前构建器累计的认证方案集合。
     */
    public prop authenticationSchemes: List<String> {
        get() {
            _authenticationSchemes
        }
    }

    /**
     * @brief 合并一个现有授权策略。
     * @param policy 待合并的授权策略。
     * @return 当前授权策略构建器。
     */
    public func combine(policy: AuthorizationPolicy): AuthorizationPolicyBuilder {
        addAuthenticationSchemesCore(policy.authenticationSchemes)
        addRequirementsCore(policy.requirements)
        return this
    }

    /**
     * @brief 添加基于声明值集合的授权要求。
     * @param claimName 声明名称。
     * @param allowedValues 允许的声明值集合。
     * @return 当前授权策略构建器。
     */
    public func requireClaim(claimName: String, allowedValues: Array<String>): AuthorizationPolicyBuilder {
        requirements.add(ClaimsAuthorizationRequirement(claimName, allowedValues))
        return this
    }

    /**
     * @brief 添加仅要求存在声明名称的授权要求。
     * @param claimName 声明名称。
     * @return 当前授权策略构建器。
     */
    public func requireClaim(claimName: String): AuthorizationPolicyBuilder {
        requirements.add(ClaimsAuthorizationRequirement(claimName))
        return this
    }

    /**
     * @brief 添加角色授权要求。
     * @param roles 允许的角色集合。
     * @return 当前授权策略构建器。
     */
    public func requireRole(roles: Array<String>): AuthorizationPolicyBuilder {
        requirements.add(RolesAuthorizationRequirement(roles))
        return this
    }

    /**
     * @brief 添加用户名授权要求。
     * @param userName 允许的用户名。
     * @return 当前授权策略构建器。
     */
    public func requireUserName(userName: String): AuthorizationPolicyBuilder {
        requirements.add(NameAuthorizationRequirement(userName))
        return this
    }

    /**
     * @brief 添加断言授权要求。
     * @param handler 用于判断授权是否成功的断言委托。
     * @return 当前授权策略构建器。
     */
    public func requireAssertion(handler: (AuthorizationHandlerContext) -> Bool): AuthorizationPolicyBuilder {
        requirements.add(AssertionRequirement(handler))
        return this
    }

    /**
     * @brief 添加要求用户已认证的授权要求。
     * @return 当前授权策略构建器。
     */
    public func requireAuthenticatedUser(): AuthorizationPolicyBuilder {
        requirements.add(_denyAnonymousAuthorizationRequirement)
        return this
    }

    /**
     * @brief 添加授权要求集合。
     * @param requirements 授权要求集合。
     * @return 当前授权策略构建器。
     */
    public func addRequirements(requirements: Array<IAuthorizationRequirement>): AuthorizationPolicyBuilder {
        return addRequirementsCore(requirements)
    }

    /**
     * @brief 添加认证方案集合。
     * @param schemes 认证方案集合。
     * @return 当前授权策略构建器。
     */
    public func addAuthenticationSchemes(schemes: Array<String>): AuthorizationPolicyBuilder {
        return addAuthenticationSchemesCore(schemes)
    }

    /**
     * @brief 构建授权策略。
     * @return 构建得到的授权策略。
     */
    public func build(): AuthorizationPolicy {
        return AuthorizationPolicy(_requirements, HashSet<String>(_authenticationSchemes))
    }

    private func addRequirementsCore(requirements: Collection<IAuthorizationRequirement>) {
        for (pattern in requirements) {
            _requirements.add(pattern)
        }
        return this
    }

    private func addAuthenticationSchemesCore(schemes: Collection<String>) {
        for (pattern in schemes) {
            _authenticationSchemes.add(pattern)
        }
        return this
    }
}

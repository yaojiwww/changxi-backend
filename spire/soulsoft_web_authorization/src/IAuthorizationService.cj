// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_authorization

import soulsoft_identity_claims.*

/**
 * @brief 定义授权服务接口。
 */
public interface IAuthorizationService {
    /**
     * @brief 使用命名策略执行授权。
     * @param user 待授权的用户主体。
     * @param resource 当前授权资源。
     * @param policyName 策略名称。
     * @return 授权结果。
     */
    func authorize(user: ClaimsPrincipal, resource: ?Object, policyName: String): AuthorizationResult

    /**
     * @brief 使用授权要求集合执行授权。
     * @param user 待授权的用户主体。
     * @param resource 当前授权资源。
     * @param requirements 授权要求集合。
     * @return 授权结果。
     */
    func authorize(user: ClaimsPrincipal, resource: ?Object, requirements: Collection<IAuthorizationRequirement>): AuthorizationResult

    /**
     * @brief 使用授权策略执行授权。
     * @param user 待授权的用户主体。
     * @param resource 当前授权资源。
     * @param policy 授权策略。
     * @return 授权结果。
     */
    func authorize(user: ClaimsPrincipal, resource: ?Object, policy: AuthorizationPolicy): AuthorizationResult {
        this.authorize(user, resource, policy.requirements)
    }

    /**
     * @brief 使用授权策略执行授权。
     * @param user 待授权的用户主体。
     * @param policy 授权策略。
     * @return 授权结果。
     */
    func authorize(user: ClaimsPrincipal, policy: AuthorizationPolicy): AuthorizationResult {
        this.authorize(user, None, policy)
    }

    /**
     * @brief 使用命名策略执行授权。
     * @param user 待授权的用户主体。
     * @param policyName 策略名称。
     * @return 授权结果。
     */
    func authorize(user: ClaimsPrincipal, policyName: String): AuthorizationResult {
        this.authorize(user, None, policyName)
    }
}

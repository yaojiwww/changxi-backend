// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_authorization

/**
 * @brief 表示基于角色集合的授权要求。
 */
public class RolesAuthorizationRequirement
    <: AuthorizationHandler<RolesAuthorizationRequirement> & IAuthorizationRequirement {
    private let _allowedRoles: Array<String>

    /**
     * @brief 创建一个角色授权要求。
     * @param allowedRoles 允许的角色集合。
     * @throws IllegalArgumentException 当角色集合为空时抛出。
     */
    public init(allowedRoles: Array<String>) {
        if (allowedRoles.isEmpty()) {
            throw IllegalArgumentException("allowedRoles must not be empty.")
        }
        _allowedRoles = allowedRoles
    }

    /**
     * @brief 获取允许的角色集合。
     * @return 当前授权要求允许的角色集合。
     */
    public prop allowedRoles: Array<String> {
        get() {
            _allowedRoles
        }
    }

    protected func handleRequirement(context: AuthorizationHandlerContext,
        requirement: RolesAuthorizationRequirement): Unit {
        for (role in requirement.allowedRoles) {
            if (context.user.isInRole(role)) {
                context.succeed(requirement)
                return
            }
        }
    }

    /**
     * @brief 返回当前授权要求的描述字符串。
     * @return 当前授权要求的描述字符串。
     */
    public func toString(): String {
        "RolesAuthorizationRequirement:user.isInRole must be true for one of the following roles: (${String.join(_allowedRoles, delimiter: "|")})"
    }
}

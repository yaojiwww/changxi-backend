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
 * @brief 表示基于用户名的授权要求。
 */
public class NameAuthorizationRequirement <: AuthorizationHandler<NameAuthorizationRequirement> & IAuthorizationRequirement {
    private let _requiredName: String

    /**
     * @brief 创建一个用户名授权要求。
     * @param requiredName 允许的用户名。
     */
    public init(requiredName: String) {
        _requiredName = requiredName
    }

    /**
     * @brief 获取要求的用户名。
     * @return 当前授权要求匹配的用户名。
     */
    public prop requiredName: String {
        get() {
            _requiredName
        }
    }

    protected func handleRequirement(context: AuthorizationHandlerContext, requirement: NameAuthorizationRequirement): Unit {
        for (identity in context.user.identities) {
            if (let Some(name) <- identity.findFirstValue(ClaimTypes.Name)) {
                if (name.equalsIgnoreAsciiCase(requirement.requiredName)) {
                    context.succeed(requirement)
                    return
                }
            }
        }
    }

    /**
     * @brief 返回当前授权要求的描述字符串。
     * @return 当前授权要求的描述字符串。
     */
    public func toString(): String {
        "NameAuthorizationRequirement: requires user name ${_requiredName}"
    }
}

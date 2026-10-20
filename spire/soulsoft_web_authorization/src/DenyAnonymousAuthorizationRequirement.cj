// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_authorization

import std.collection.*

/**
 * @brief 表示要求用户已完成身份认证的授权要求。
 */
public class DenyAnonymousAuthorizationRequirement 
    <: AuthorizationHandler<DenyAnonymousAuthorizationRequirement> & IAuthorizationRequirement {
   
    protected func handleRequirement(context: AuthorizationHandlerContext,
        requirement: DenyAnonymousAuthorizationRequirement) {
        var user = context.user
        var isAuthenticated = user.identities |> any {i => i.isAuthenticated}
        if (isAuthenticated) {
            context.succeed(requirement)
        }
    }

    /**
     * @brief 返回当前授权要求的描述字符串。
     * @return 当前授权要求的描述字符串。
     */
    public func toString(): String {
        "DenyAnonymousAuthorizationRequirement: Requires an authenticated user."
    }
}

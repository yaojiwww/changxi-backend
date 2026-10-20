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
 * @brief 提供默认的授权处理上下文工厂。
 */
public class DefaultAuthorizationHandlerContextFactory <: IAuthorizationHandlerContextFactory {

    /**
     * @brief 创建授权处理上下文。
     * @param requirements 授权要求集合。
     * @param user 待授权的用户主体。
     * @param resource 当前授权资源。
     * @return 授权处理上下文。
     */
    public func createContext(requirements: Collection<IAuthorizationRequirement>, user: ClaimsPrincipal,
        resource: ?Object): AuthorizationHandlerContext {
        return AuthorizationHandlerContext(requirements, user, resource)
    }
}

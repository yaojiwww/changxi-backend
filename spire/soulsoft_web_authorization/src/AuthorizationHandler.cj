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
 * @brief 提供基于授权要求类型的授权处理器基类。
 */
public abstract class AuthorizationHandler<TRequirement> <: IAuthorizationHandler where TRequirement <: IAuthorizationRequirement {
    /**
     * @brief 处理当前上下文中的匹配授权要求。
     * @param context 当前授权处理上下文。
     */
    public func handle(context: AuthorizationHandlerContext): Unit {
        for (pattern in context.requirements |> filterMap {f => f as TRequirement}) {
            handleRequirement(context, pattern)
        }
    }

    /**
     * @brief 处理单个匹配的授权要求。
     * @param context 当前授权处理上下文。
     * @param requirement 当前授权要求。
     */
    protected func handleRequirement(context: AuthorizationHandlerContext, requirement: TRequirement): Unit
}

/**
 * @brief 提供基于资源类型的授权处理器基类。
 */
public abstract class AuthorizationResourceHandler<TRequirement, TResource> <: IAuthorizationHandler where TRequirement <: IAuthorizationRequirement {
    /**
     * @brief 处理当前上下文中与资源匹配的授权要求。
     * @param context 当前授权处理上下文。
     */
    public func handle(context: AuthorizationHandlerContext): Unit {
        if (let resource: TResource <- context.resource) {
            for (pattern in context.requirements |> filterMap {f => f as TRequirement}) {
                handleRequirement(context, pattern, resource)
            }
        }
    }

    /**
     * @brief 处理单个匹配的资源授权要求。
     * @param context 当前授权处理上下文。
     * @param requirement 当前授权要求。
     * @param resource 当前授权资源。
     */
    protected func handleRequirement(context: AuthorizationHandlerContext, requirement: TRequirement,
        resource: TResource): Unit
}

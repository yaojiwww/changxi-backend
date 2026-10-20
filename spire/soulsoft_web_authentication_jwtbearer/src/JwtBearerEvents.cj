// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_authentication_jwtbearer

/**
 * @brief 提供 JWT Bearer 身份验证事件回调集合。
 */
public class JwtBearerEvents {
    /**
     * @brief 禁止访问事件回调。
     */
    public var onForbidden: (context: ForbiddenContext) -> Unit = {_ =>}
    /**
     * @brief 质询事件回调。
     */
    public var onChallenge: (context: JwtBearerChallengeContext) -> Unit = {_ =>}
    /**
     * @brief 令牌验证成功事件回调。
     */
    public var onTokenValidated: (context: TokenValidatedContext) -> Unit = {_ =>}
    /**
     * @brief 消息接收事件回调。
     */
    public var onMessageReceived: (context: MessageReceivedContext) -> Unit = {_ =>}
    /**
     * @brief 身份验证失败事件回调。
     */
    public var onAuthenticationFailed: (context: AuthenticationFailedContext) -> Unit = {_ =>}

    /**
     * @brief 触发禁止访问事件。
     * @param context 禁止访问上下文。
     */
    public func forbidden(context: ForbiddenContext): Unit {
        onForbidden(context)
    }

    /**
     * @brief 触发质询事件。
     * @param context 质询上下文。
     */
    public func challenge(context: JwtBearerChallengeContext): Unit {
        onChallenge(context)
    }

    /**
     * @brief 触发令牌验证成功事件。
     * @param context 令牌验证上下文。
     */
    public func tokenValidated(context: TokenValidatedContext): Unit {
        onTokenValidated(context)
    }

    /**
     * @brief 触发消息接收事件。
     * @param context 消息接收上下文。
     */
    public func messageReceived(context: MessageReceivedContext): Unit {
        onMessageReceived(context)
    }

    /**
     * @brief 触发身份验证失败事件。
     * @param context 身份验证失败上下文。
     */
    public func authenticationFailed(context: AuthenticationFailedContext): Unit {
        onAuthenticationFailed(context)
    }
}

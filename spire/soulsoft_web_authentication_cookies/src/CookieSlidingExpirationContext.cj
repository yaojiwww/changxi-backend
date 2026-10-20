// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_web_authentication_cookies

import soulsoft_web_http.*
import soulsoft_web_authentication.*

/**
 * @brief 表示 Cookie 滑动过期检查事件上下文。
 */
public class CookieSlidingExpirationContext <: PrincipalContext<CookieAuthenticationOptions> {
    /**
     * @brief 指定是否需要续签当前 Cookie。
     */
    public var shouldRenew = false
    /**
     * @brief 当前票据已经历的时间。
     */
    public let elapsedTime: Duration
    /**
     * @brief 当前票据剩余有效时间。
     */
    public let remainingTime: Duration

    /**
     * @brief 创建一个 Cookie 滑动过期上下文。
     * @param context 当前 HTTP 上下文。
     * @param scheme 当前身份验证方案。
     * @param options 当前 Cookie 身份验证选项。
     * @param ticket 当前身份验证票据。
     * @param elapsedTime 已经过的时间。
     * @param remainingTime 剩余有效时间。
     */
    protected init(context: HttpContext, scheme: AuthenticationScheme, options: CookieAuthenticationOptions,
        ticket: AuthenticationTicket, elapsedTime: Duration, remainingTime: Duration) {
        super(context, scheme, options, ticket.properties)
        this.elapsedTime = elapsedTime
        this.remainingTime = remainingTime
    }
}

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_web_authentication_cookies

import soulsoft_web_http.*
import soulsoft_identity_claims.*
import soulsoft_web_authentication.*

/**
 * @brief 表示 Cookie 主体验证事件上下文。
 */
public class CookieValidatePrincipalContext <: PrincipalContext<CookieAuthenticationOptions> {
    /**
     * @brief 指定是否需要续签当前 Cookie。
     */
    public var shouldRenew = false

    /**
     * @brief 创建一个 Cookie 主体验证上下文。
     * @param context 当前 HTTP 上下文。
     * @param scheme 当前身份验证方案。
     * @param options 当前 Cookie 身份验证选项。
     * @param ticket 当前身份验证票据。
     */
    protected init(context: HttpContext, scheme: AuthenticationScheme, options: CookieAuthenticationOptions,
        ticket: ?AuthenticationTicket) {
        super(context, scheme, options, if (let Some(ticket) <- ticket) {
            ticket.properties
        } else {
            None
        })
        this.principal = if (let Some(ticket) <- ticket) {
            ticket.principal
        } else {
            None
        }
    }

    /**
     * @brief 替换当前主体。
     * @param principal 新的用户主体。
     */
    public func replacePrincipal(principal: ClaimsPrincipal): Unit {
        this.principal = principal
    }

    /**
     * @brief 拒绝当前主体。
     */
    public func rejectPrincipal(): Unit {
        this.principal = None
    }
}

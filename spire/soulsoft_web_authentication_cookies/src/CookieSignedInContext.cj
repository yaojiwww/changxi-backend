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
 * @brief 表示 Cookie 登录完成后的事件上下文。
 */
public class CookieSignedInContext <: PrincipalContext<CookieAuthenticationOptions> {
    /**
     * @brief 创建一个 Cookie 已登录上下文。
     * @param context 当前 HTTP 上下文。
     * @param scheme 当前身份验证方案。
     * @param principal 已登录的用户主体。
     * @param properties 身份验证属性。
     * @param options 当前 Cookie 身份验证选项。
     */
    protected init(context: HttpContext, scheme: AuthenticationScheme, principal: ClaimsPrincipal,
        properties: ?AuthenticationProperties, options: CookieAuthenticationOptions) {
        super(context, scheme, options, properties)
    }
}

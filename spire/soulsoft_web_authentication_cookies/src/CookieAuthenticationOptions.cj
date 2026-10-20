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
import soulsoft_extensions_protection.*

/**
 * @brief 表示 Cookie 身份验证方案选项。
 */
public class CookieAuthenticationOptions <: AuthenticationSchemeOptions {
    /**
     * @brief 指定用于生成认证 Cookie 的构建器。
     */
    public var cookie = CookieBuilder()
    /**
     * @brief 指定是否启用滑动过期。
     */
    public var slidingExpiration = false
    /**
     * @brief 指定票据默认有效期。
     */
    public var expireTimeSpan = Duration.day * 14
    /**
     * @brief 指定 Cookie 身份验证事件处理器。
     */
    public var events = CookieAuthenticationEvents()
    /**
     * @brief 指定可选的票据会话存储。
     */
    public var sessionStore: ?ITicketStore = None
    /**
     * @brief 指定用于保护票据的保护器。
     */
    public var dataProtector: ?IDataProtector = None
    /**
     * @brief 指定登录路径。
     */
    public var loginPath = CookieAuthenticationDefaults.LoginPath
    /**
     * @brief 指定登出路径。
     */
    public var logoutPath = CookieAuthenticationDefaults.LogoutPath
    /**
     * @brief 指定 Cookie 读写管理器。
     */
    public var cookieManager: ICookieManager = ChunkingCookieManager()
    /**
     * @brief 指定拒绝访问路径。
     */
    public var accessDeniedPath = CookieAuthenticationDefaults.AccessDeniedPath
    /**
     * @brief 指定返回地址查询参数名称。
     */
    public var returnUrlParameter = CookieAuthenticationDefaults.ReturnUrlParameter
    /**
     * @brief 指定票据保护格式化器。
     */
    public var ticketDataFormat: ?ISecureDataFormat<AuthenticationTicket> = None
}

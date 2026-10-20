// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_web_authentication_cookies

import soulsoft_web_http.*

/**
 * @brief 提供 Cookie 身份验证默认值。
 */
public class CookieAuthenticationDefaults {
    /**
     * @brief 默认身份验证方案名称。
     */
    public static const Scheme = "Cookies"
    /**
     * @brief 默认 Cookie 名称前缀。
     */
    public static const CookiePrefix = ".cangjie."
    /**
     * @brief 默认登录路径。
     */
    public static let LoginPath = PathString("/account/login")
    /**
     * @brief 默认登出路径。
     */
    public static let LogoutPath = PathString("/account/logout")
    /**
     * @brief 默认拒绝访问路径。
     */
    public static let AccessDeniedPath = PathString("/account/accessDenied")
    /**
     * @brief 默认返回地址参数名称。
     */
    public static const ReturnUrlParameter = "returnUrl"
}

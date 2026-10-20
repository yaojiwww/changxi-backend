// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_authentication

import soulsoft_web_http.*
import soulsoft_identity_claims.*

/**
 * @brief 定义身份验证服务的统一入口。
 */
public interface IAuthenticationService {
    /**
     * @brief 对当前请求执行身份验证。
     * @param context 当前 HTTP 上下文。
     * @param scheme 指定的方案名称；为空时使用默认方案。
     * @return 身份验证结果。
     */
    func authenticate(context: HttpContext, scheme: ?String): AuthenticateResult
    /**
     * @brief 对当前请求发起质询。
     * @param context 当前 HTTP 上下文。
     * @param scheme 指定的方案名称；为空时使用默认方案。
     * @param properties 质询时附带的属性。
     */
    func challenge(context: HttpContext, scheme: ?String, properties: ?AuthenticationProperties): Unit
    /**
     * @brief 对当前请求执行禁止访问处理。
     * @param context 当前 HTTP 上下文。
     * @param scheme 指定的方案名称；为空时使用默认方案。
     * @param properties 禁止访问时附带的属性。
     */
    func forbid(context: HttpContext, scheme: ?String, properties: ?AuthenticationProperties): Unit
    /**
     * @brief 使用指定方案执行登录。
     * @param context 当前 HTTP 上下文。
     * @param scheme 指定的方案名称；为空时使用默认方案。
     * @param principal 待登录的用户主体。
     * @param properties 登录时附带的属性。
     */
    func signIn(context: HttpContext, scheme: ?String, principal: ClaimsPrincipal, properties: ?AuthenticationProperties): Unit
    /**
     * @brief 使用指定方案执行登出。
     * @param context 当前 HTTP 上下文。
     * @param scheme 指定的方案名称；为空时使用默认方案。
     * @param properties 登出时附带的属性。
     */
    func signOut(context: HttpContext, scheme: ?String, properties: ?AuthenticationProperties): Unit
}

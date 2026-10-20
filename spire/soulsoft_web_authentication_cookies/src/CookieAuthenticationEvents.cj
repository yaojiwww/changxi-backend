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
 * @brief 提供 Cookie 身份验证事件回调集合。
 */
public class CookieAuthenticationEvents {
    /**
     * @brief 登录前事件回调。
     */
    public var onSigningIn: (CookieSigningInContext) -> Unit = {_ =>}
    /**
     * @brief 登录完成事件回调。
     */
    public var onSignedIn: (CookieSignedInContext) -> Unit = {_ =>}
    /**
     * @brief 登出前事件回调。
     */
    public var onSigningOut: (CookieSigningOutContext) -> Unit = {_ =>}
    /**
     * @brief 滑动过期检查事件回调。
     */
    public var onCheckSlidingExpiration: (CookieSlidingExpirationContext) -> Unit = {_ =>}
    /**
     * @brief 主体验证事件回调。
     */
    public var onValidatePrincipal: (CookieValidatePrincipalContext) -> Unit = {_ =>}
    /**
     * @brief 返回地址重定向事件回调。
     */
    public var onRedirectToReturnUrl: (RedirectContext<CookieAuthenticationOptions>) -> Unit = {
        context => if (isAjaxRequest(context.request)) {
            context.response.headers.location = [context.redirectUri]
            context.response.statusCode = StatusCodes.Unauthorized
        } else {
            context.response.redirect(context.redirectUri)
        }
    }

    /**
     * @brief 拒绝访问重定向事件回调。
     */
    public var onRedirectToAccessDenied: (RedirectContext<CookieAuthenticationOptions>) -> Unit = {
        context => if (isAjaxRequest(context.request)) {
            context.response.headers.location = [context.redirectUri]
            context.response.statusCode = StatusCodes.Forbidden
        } else {
            context.response.redirect(context.redirectUri)
        }
    }

    /**
     * @brief 登录页重定向事件回调。
     */
    public var onRedirectToLogin: (RedirectContext<CookieAuthenticationOptions>) -> Unit = {
        context => if (isAjaxRequest(context.request)) {
            context.response.headers.location = [context.redirectUri]
            context.response.statusCode = StatusCodes.Unauthorized
        } else {
            context.response.redirect(context.redirectUri)
        }
    }

    /**
     * @brief 触发滑动过期检查事件。
     * @param context 滑动过期上下文。
     */
    public func checkSlidingExpiration(context: CookieSlidingExpirationContext): Unit {
        onCheckSlidingExpiration(context)
    }

    /**
     * @brief 触发主体验证事件。
     * @param context 主体验证上下文。
     */
    public func validatePrincipal(context: CookieValidatePrincipalContext): Unit {
        onValidatePrincipal(context)
    }

    /**
     * @brief 触发返回地址重定向事件。
     * @param context 重定向上下文。
     */
    public func redirectToReturnUrl(context: RedirectContext<CookieAuthenticationOptions>): Unit {
        onRedirectToReturnUrl(context)
    }

    /**
     * @brief 触发拒绝访问重定向事件。
     * @param context 重定向上下文。
     */
    public func redirectToAccessDenied(context: RedirectContext<CookieAuthenticationOptions>): Unit {
        onRedirectToAccessDenied(context)
    }

    /**
     * @brief 触发登录页重定向事件。
     * @param context 重定向上下文。
     */
    public func redirectToLogin(context: RedirectContext<CookieAuthenticationOptions>): Unit {
        onRedirectToLogin(context)
    }

    /**
     * @brief 触发登录前事件。
     * @param context 登录上下文。
     */
    public func signingIn(context: CookieSigningInContext): Unit {
        onSigningIn(context)
    }

    /**
     * @brief 触发登录完成事件。
     * @param context 已登录上下文。
     */
    public func signedIn(context: CookieSignedInContext): Unit {
        onSignedIn(context)
    }

    /**
     * @brief 触发登出前事件。
     * @param context 登出上下文。
     */
    public func signingOut(context: CookieSigningOutContext): Unit {
        onSigningOut(context)
    }

    private static func isAjaxRequest(request: HttpRequest) {
        "XMLHttpRequest".equalsIgnoreAsciiCase(request.query.get(HeaderNames.XRequestedWith) ?? String.empty) ||
            "XMLHttpRequest".equalsIgnoreAsciiCase(request.headers.xRequestedWith.first ?? String.empty)
    }
}

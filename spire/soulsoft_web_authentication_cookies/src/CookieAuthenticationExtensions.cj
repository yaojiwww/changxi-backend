// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_web_authentication_cookies

import soulsoft_extensions_options.*
import soulsoft_web_authentication.*
import soulsoft_extensions_injection.*
import soulsoft_extensions_protection.*

/**
 * @brief 定义 AuthenticationBuilder 的 Cookie 身份验证扩展。
 */
public interface CookieAuthenticationExtensions {
    /**
     * @brief 使用默认方案添加 Cookie 身份验证。
     * @return 身份验证构建器。
     */
    func addCookie(): AuthenticationBuilder {
        addCookie(CookieAuthenticationDefaults.Scheme, None) {
            _ =>
        }
    }
    /**
     * @brief 使用指定方案添加 Cookie 身份验证。
     * @param authenticationScheme 身份验证方案名称。
     * @return 身份验证构建器。
     */
    func addCookie(authenticationScheme: String): AuthenticationBuilder {
        addCookie(authenticationScheme, None) {
            _ =>
        }
    }
    /**
     * @brief 使用默认方案和配置回调添加 Cookie 身份验证。
     * @param configureOptions Cookie 身份验证选项配置回调。
     * @return 身份验证构建器。
     */
    func addCookie(configureOptions: (CookieAuthenticationOptions) -> Unit): AuthenticationBuilder {
        addCookie(CookieAuthenticationDefaults.Scheme, None, configureOptions)
    }
    /**
     * @brief 使用指定方案和配置回调添加 Cookie 身份验证。
     * @param authenticationScheme 身份验证方案名称。
     * @param configureOptions Cookie 身份验证选项配置回调。
     * @return 身份验证构建器。
     */
    func addCookie(authenticationScheme: String, configureOptions: (CookieAuthenticationOptions) -> Unit): AuthenticationBuilder {
        addCookie(authenticationScheme, None, configureOptions)
    }
    /**
     * @brief 使用指定方案、显示名和配置回调添加 Cookie 身份验证。
     * @param authenticationScheme 身份验证方案名称。
     * @param displayName 方案显示名称。
     * @param configureOptions Cookie 身份验证选项配置回调。
     * @return 身份验证构建器。
     */
    func addCookie(authenticationScheme: String, displayName: ?String,
        configureOptions: (CookieAuthenticationOptions) -> Unit): AuthenticationBuilder
}

extend AuthenticationBuilder <: CookieAuthenticationExtensions {
    /**
     * @brief 使用指定方案、显示名和配置回调添加 Cookie 身份验证。
     * @param authenticationScheme 身份验证方案名称。
     * @param displayName 方案显示名称。
     * @param configureOptions Cookie 身份验证选项配置回调。
     * @return 身份验证构建器。
     */
    public func addCookie(authenticationScheme: String, displayName: ?String,
        configureOptions: (CookieAuthenticationOptions) -> Unit): AuthenticationBuilder {
        this.services.addDataProtection()    
        this.addScheme<CookieAuthenticationOptions, CookieAuthenticationHandler>(authenticationScheme, displayName,
            configureOptions)
        this
            .services
            .addSingleton<IConfigureAfterOptions<CookieAuthenticationOptions>, PostConfigureCookieAuthenticationOptions>()
        return this
    }
}

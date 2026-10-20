// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_authentication

import soulsoft_extensions_options.*
import soulsoft_extensions_injection.*

/**
 * @brief 定义服务集合的身份验证注册扩展。
 */
public interface AuthenticationServiceCollectionExtensions {
    /**
     * @brief 使用默认配置注册身份验证服务。
     * @return 身份验证构建器。
     */
    func addAuthentication(): AuthenticationBuilder
    /**
     * @brief 使用默认方案注册身份验证服务。
     * @param defaultScheme 默认方案名称。
     * @return 身份验证构建器。
     */
    func addAuthentication(defaultScheme: String): AuthenticationBuilder
    /**
     * @brief 使用自定义选项注册身份验证服务。
     * @param configureOptions 身份验证选项配置回调。
     * @return 身份验证构建器。
     */
    func addAuthentication(configureOptions: (AuthenticationOptions) -> Unit): AuthenticationBuilder
}

extend ServiceCollection <: AuthenticationServiceCollectionExtensions {
    /**
     * @brief 使用默认配置注册身份验证服务。
     * @return 身份验证构建器。
     */
    public func addAuthentication(): AuthenticationBuilder {
        addAuthentication {_ =>}
    }

    /**
     * @brief 使用默认方案注册身份验证服务。
     * @param defaultScheme 默认方案名称。
     * @return 身份验证构建器。
     */
    public func addAuthentication(defaultScheme: String): AuthenticationBuilder {
        addAuthentication {
            configureOptions => configureOptions.defaultScheme = defaultScheme
        }
    }

    /**
     * @brief 使用自定义选项注册身份验证服务。
     * @param configureOptions 身份验证选项配置回调。
     * @return 身份验证构建器。
     */
    public func addAuthentication(configureOptions: (AuthenticationOptions) -> Unit): AuthenticationBuilder {
        this.configure(configureOptions)
        this.tryAddScoped<IAuthenticationService, AuthenticationService> {
            sp =>
                let schemes = sp.getOrThrow<IAuthenticationSchemeProvider>()
                let handlers = sp.getOrThrow<IAuthenticationHandlerProvider>()
                let options = sp.getOrThrow<IOptions<AuthenticationOptions>>()
                return AuthenticationService(schemes, handlers, options)
        }
        this.tryAddSingleton<IAuthenticationSchemeProvider, AuthenticationSchemeProvider>()
        this.tryAddScoped<IAuthenticationHandlerProvider, AuthenticationHandlerProvider> {
            sp =>
                let schemes = sp.getOrThrow<IAuthenticationSchemeProvider>()
                return AuthenticationHandlerProvider(schemes)
        }
        return AuthenticationBuilder(this)
    }
}

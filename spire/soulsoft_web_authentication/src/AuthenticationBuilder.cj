// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_authentication

import std.reflect.*
import soulsoft_extensions_options.*
import soulsoft_extensions_injection.*

/**
 * @brief 提供身份验证方案注册构建能力。
 */
public class AuthenticationBuilder {
    private let _services: ServiceCollection

    internal init(services: ServiceCollection) {
        _services = services
    }

    /**
     * @brief 返回当前服务集合。
     * @return 服务集合实例。
     */
    public prop services: ServiceCollection {
        get() {
            _services
        }
    }

    /**
     * @brief 添加一个使用默认选项配置的身份验证方案。
     * @param authenticationScheme 方案名称。
     * @return 当前构建器。
     */
    public func addScheme<TOptions, THandler>(authenticationScheme: String): AuthenticationBuilder where TOptions <: AuthenticationSchemeOptions,
        THandler <: AuthenticationHandler<TOptions> {
        addSchemeHelper<TOptions, THandler>(authenticationScheme, None) {
            _ =>
        }
        return this
    }

    /**
     * @brief 添加一个带自定义选项配置的身份验证方案。
     * @param authenticateScheme 方案名称。
     * @param configureOptions 方案选项配置回调。
     * @return 当前构建器。
     */
    public func addScheme<TOptions, THandler>(authenticateScheme: String, configureOptions: (TOptions) -> Unit): AuthenticationBuilder where TOptions <: AuthenticationSchemeOptions,
        THandler <: AuthenticationHandler<TOptions> {
        addSchemeHelper<TOptions, THandler>(authenticateScheme, None, configureOptions)
        return this
    }

    /**
     * @brief 添加一个带显示名称和选项配置的身份验证方案。
     * @param authenticationScheme 方案名称。
     * @param displayName 方案显示名称。
     * @param configureOptions 方案选项配置回调。
     * @return 当前构建器。
     */
    public func addScheme<TOptions, THandler>(authenticationScheme: String, displayName: ?String,
        configureOptions: (TOptions) -> Unit): AuthenticationBuilder where TOptions <: AuthenticationSchemeOptions,
        THandler <: AuthenticationHandler<TOptions> {
        addSchemeHelper<TOptions, THandler>(authenticationScheme, displayName, configureOptions)
        return this
    }

    private func addSchemeHelper<TOptions, THandler>(authenticationScheme: String, displayName: ?String,
        configureOptions: (TOptions) -> Unit): AuthenticationBuilder where TOptions <: AuthenticationSchemeOptions,
        THandler <: AuthenticationHandler<TOptions> {
        _services.configure<AuthenticationOptions> {
            options => options.addScheme(authenticationScheme) {
                configureBuilder =>
                    configureBuilder.displayName = displayName
                    configureBuilder.handlerType = TypeInfo.of<THandler>()
            }
        }
        _services.configure(authenticationScheme, configureOptions)
        _services.addScoped<THandler, THandler>()
        return this
    }
}

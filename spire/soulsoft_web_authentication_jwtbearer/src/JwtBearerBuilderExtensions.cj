// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_authentication_jwtbearer

import soulsoft_extensions_options.*
import soulsoft_web_authentication.*
import soulsoft_extensions_injection.*

/**
 * @brief 定义 AuthenticationBuilder 的 JWT Bearer 扩展。
 */
public interface JwtBearerBuilderExtensions {
    /**
     * @brief 使用指定方案、显示名和配置回调添加 JWT Bearer 身份验证。
     * @param authenticateScheme 身份验证方案名称。
     * @param displayName 方案显示名称。
     * @param configureOptions JWT Bearer 选项配置回调。
     * @return 身份验证构建器。
     */
    func addJwtBearer(authenticateScheme: String, displayName: Option<String>,
        configureOptions: (JwtBearerOptions) -> Unit): AuthenticationBuilder

    /**
     * @brief 使用指定方案和配置回调添加 JWT Bearer 身份验证。
     * @param authenticateScheme 身份验证方案名称。
     * @param configureOptions JWT Bearer 选项配置回调。
     * @return 身份验证构建器。
     */
    func addJwtBearer(authenticateScheme: String, configureOptions: (JwtBearerOptions) -> Unit): AuthenticationBuilder {
        addJwtBearer(authenticateScheme, None, configureOptions)
    }

    /**
     * @brief 使用默认方案添加 JWT Bearer 身份验证。
     * @return 身份验证构建器。
     */
    func addJwtBearer(): AuthenticationBuilder {
        addJwtBearer(JwtBearerDefaults.Scheme)
    }

    /**
     * @brief 使用指定方案添加 JWT Bearer 身份验证。
     * @param authenticateScheme 身份验证方案名称。
     * @return 身份验证构建器。
     */
    func addJwtBearer(authenticateScheme: String): AuthenticationBuilder {
        addJwtBearer(authenticateScheme, None) {_ =>}
    }

    /**
     * @brief 使用默认方案和配置回调添加 JWT Bearer 身份验证。
     * @param configureOptions JWT Bearer 选项配置回调。
     * @return 身份验证构建器。
     */
    func addJwtBearer(configureOptions: (JwtBearerOptions) -> Unit): AuthenticationBuilder {
        addJwtBearer(JwtBearerDefaults.Scheme, None, configureOptions)
    }
}

extend AuthenticationBuilder <: JwtBearerBuilderExtensions {
    /**
     * @brief 使用指定方案、显示名和配置回调添加 JWT Bearer 身份验证。
     * @param authenticateScheme 身份验证方案名称。
     * @param displayName 方案显示名称。
     * @param configureOptions JWT Bearer 选项配置回调。
     * @return 身份验证构建器。
     */
    public func addJwtBearer(authenticateScheme: String, displayName: Option<String>,
        configureOptions: (JwtBearerOptions) -> Unit): AuthenticationBuilder {
        services.tryAddEnumerable(
            ServiceDescriptor.singleton<IConfigureOptions<JwtBearerOptions>, JwtBearerConfigureOptions>())

        services.tryAddEnumerable(
            ServiceDescriptor.singleton<IConfigureAfterOptions<JwtBearerOptions>, JwtBearerConfigureAfterOptions>())
        this.addScheme<JwtBearerOptions, JwtBearerHandler>(authenticateScheme, displayName, configureOptions)
    }
}

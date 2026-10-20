/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.authentication

import soulsoft_web_authentication.*

/**
 * @brief 定义本地 API 认证注册扩展接口。
 */
public interface LocalApiAuthenticationExtensions {
    /**
     * @brief 注册本地 API 认证方案。
     * @param authenticateScheme 认证方案名称。
     * @param displayName 显示名称。
     * @param configureOptions 认证选项配置委托。
     * @return 返回认证构建器。
     */
    func addLocalApi(authenticateScheme: String, displayName: Option<String>,
        configureOptions: (LocalApiAuthenticationOptions) -> Unit): AuthenticationBuilder

    /**
     * @brief 注册本地 API 认证方案并配置选项。
     * @param authenticateScheme 认证方案名称。
     * @param configureOptions 认证选项配置委托。
     * @return 返回认证构建器。
     */
    func addLocalApi(authenticateScheme: String, configureOptions: (LocalApiAuthenticationOptions) -> Unit): AuthenticationBuilder {
        addLocalApi(authenticateScheme, None, configureOptions)
    }

    /**
     * @brief 使用默认方案注册本地 API 认证。
     * @return 返回认证构建器。
     */
    func addLocalApi(): AuthenticationBuilder {
        addLocalApi(LocalApiAuthenticationDefaults.Scheme)
    }

    /**
     * @brief 使用指定方案注册本地 API 认证。
     * @param authenticateScheme 认证方案名称。
     * @return 返回认证构建器。
     */
    func addLocalApi(authenticateScheme: String): AuthenticationBuilder {
        addLocalApi(authenticateScheme, None) {_ =>}
    }

    /**
     * @brief 使用默认方案注册本地 API 认证并配置选项。
     * @param configureOptions 认证选项配置委托。
     * @return 返回认证构建器。
     */
    func addLocalApi(configureOptions: (LocalApiAuthenticationOptions) -> Unit): AuthenticationBuilder {
        addLocalApi(LocalApiAuthenticationDefaults.Scheme, None, configureOptions)
    }
}

extend AuthenticationBuilder <: LocalApiAuthenticationExtensions {
    /**
     * @brief 注册本地 API 认证方案。
     * @param authenticateScheme 认证方案名称。
     * @param displayName 显示名称。
     * @param configureOptions 认证选项配置委托。
     * @return 返回认证构建器。
     */
    public func addLocalApi(authenticateScheme: String, displayName: Option<String>,
        configureOptions: (LocalApiAuthenticationOptions) -> Unit): AuthenticationBuilder {
        this.addScheme<LocalApiAuthenticationOptions, LocalApiAuthenticationHandler>(
            LocalApiAuthenticationDefaults.Scheme, displayName, configureOptions)
    }
}

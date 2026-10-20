/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server

import soulsoft_web_cors.*
import soulsoft_web_hosting.*
import soulsoft_extensions_options.*
import soulsoft_extensions_injection.*
import soulsoft_web_cors.abstractions.*
import soulsoft_identity_server.options.*

/**
 * @brief 定义 Identity Server 服务注册扩展接口。
 */
public interface IdentityServiceExtensions {
    /**
     * @brief 使用默认配置注册 Identity Server 服务。
     * @return 返回 Identity Server 构建器。
     */
    func addIdentityServer(): IdentityServerBuilder {
        addIdentityServer({_ =>})
    }

    /**
     * @brief 注册 Identity Server 服务并配置选项。
     * @param configureOptions 用于配置 Identity Server 选项的委托。
     * @return 返回 Identity Server 构建器。
     */
    func addIdentityServer(configureOptions: (IdentityServerOptions) -> Unit): IdentityServerBuilder

    /**
     * @brief 创建 Identity Server 构建器并注册基础服务。
     * @param configureOptions 用于配置 Identity Server 选项的委托。
     * @return 返回 Identity Server 构建器。
     */
    func addIdentityServerBuilder(configureOptions: (IdentityServerOptions) -> Unit): IdentityServerBuilder
}

extend ServiceCollection <: IdentityServiceExtensions {
    /**
     * @brief 注册完整的 Identity Server 默认服务集合。
     * @param configureOptions 用于配置 Identity Server 选项的委托。
     * @return 返回 Identity Server 构建器。
     */
    public func addIdentityServer(configureOptions: (IdentityServerOptions) -> Unit): IdentityServerBuilder {
        return addIdentityServerBuilder(configureOptions)
            .addValidators()
            .addRequiredServices()
            .addDefaultEndpoints()
            .addPluggableServices()
            .addResponseGenerators()
            .addInMemoryConsentStore()
            .addInMemoryRefreshTokenStore()
            .addInMemoryAuthorizationCodeStore()
    }

    /**
     * @brief 创建 Identity Server 构建器并注册基础依赖。
     * @param configureOptions 用于配置 Identity Server 选项的委托。
     * @return 返回 Identity Server 构建器。
     */
    public func addIdentityServerBuilder(configureOptions: (IdentityServerOptions) -> Unit): IdentityServerBuilder {
        this.configure(configureOptions)
        this.addCors()
        this.addHttpContextAccessor()
        this.addSingleton<IdentityServerOptions> {
            sp => sp.getOrThrow<IOptions<IdentityServerOptions>>().value
        }
        this.configureAfter<CorsOptions> {
            corsOptions, sp =>
                let identityServerOptions = sp.getOrThrow<IdentityServerOptions>()
                corsOptions.addPolicy(identityServerOptions.corsPolicyName) {
                    configurePolicy => configurePolicy.allowAnyHeader().allowAnyOrigin().allowAnyMethod()
                }
                corsOptions.policyResolver = CorsPolicyResolver(corsOptions, identityServerOptions).resolver
        }
        return IdentityServerBuilder(this)
    }
}

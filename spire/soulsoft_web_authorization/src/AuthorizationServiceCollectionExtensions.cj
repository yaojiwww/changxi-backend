// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_authorization

import soulsoft_extensions_logging.*
import soulsoft_extensions_options.*
import soulsoft_extensions_injection.*

/**
 * @brief 定义服务集合的授权注册扩展。
 */
public interface AuthorizationServiceCollectionExtensions {
    /**
     * @brief 使用默认配置注册授权服务。
     * @return 服务集合。
     */
    func addAuthorization(): ServiceCollection {
        addAuthorization {_ =>}
    }

    /**
     * @brief 使用指定配置注册授权服务。
     * @param configure 授权选项配置回调。
     * @return 服务集合。
     */
    func addAuthorization(configure: (AuthorizationOptions) -> Unit): ServiceCollection

    /**
     * @brief 使用默认配置注册核心授权服务。
     * @return 服务集合。
     */
    func addAuthorizationCore(): ServiceCollection {
        addAuthorizationCore {_ =>}
    }

    /**
     * @brief 创建授权构建器。
     * @return 授权构建器。
     */
    func addAuthorizationBuilder(): AuthorizationBuilder

    /**
     * @brief 使用指定配置注册核心授权服务。
     * @param configure 授权选项配置回调。
     * @return 服务集合。
     */
    func addAuthorizationCore(configure: (AuthorizationOptions) -> Unit): ServiceCollection

    /**
     * @brief 注册授权策略执行相关服务。
     * @return 服务集合。
     */
    func addAuthorizationPolicyEvaluator(): ServiceCollection
}

extend ServiceCollection <: AuthorizationServiceCollectionExtensions {
    /**
     * @brief 创建授权构建器。
     * @return 授权构建器。
     */
    public func addAuthorizationBuilder(): AuthorizationBuilder {
        return AuthorizationBuilder(addAuthorization())
    }

    /**
     * @brief 使用指定配置注册授权服务。
     * @param configure 授权选项配置回调。
     * @return 服务集合。
     */
    public func addAuthorization(configure: (AuthorizationOptions) -> Unit): ServiceCollection {
        addAuthorizationCore(configure)
        addAuthorizationPolicyEvaluator()
        return this
    }

    /**
     * @brief 使用指定配置注册核心授权服务。
     * @param configure 授权选项配置回调。
     * @return 服务集合。
     */
    public func addAuthorizationCore(configure: (AuthorizationOptions) -> Unit): ServiceCollection {
        this.configure(configure)
        this.tryAddTransient<IAuthorizationService, DefaultAuthorizationService> {
            sp => DefaultAuthorizationService(
                sp.getOrThrow<IAuthorizationPolicyProvider>(),
                sp.getOrThrow<IAuthorizationHandlerProvider>(),
                sp.getOrThrow<IAuthorizationHandlerContextFactory>(),
                sp.getOrThrow<IAuthorizationEvaluator>(),
                sp.getOrThrow<IOptions<AuthorizationOptions>>(),
                sp.getOrThrow<ILoggerFactory>()
            )
        }
        this.tryAddTransient<IAuthorizationPolicyProvider, DefaultAuthorizationPolicyProvider> {
            sp => DefaultAuthorizationPolicyProvider(sp.getOrThrow<IOptions<AuthorizationOptions>>())
        }
        this.tryAddTransient<IAuthorizationHandlerProvider, DefaultAuthorizationHandlerProvider> {
            sp => DefaultAuthorizationHandlerProvider(sp.getAll<IAuthorizationHandler>())
        }
        this.tryAddTransient<IAuthorizationEvaluator, DefaultAuthorizationEvaluator> {
            _ => DefaultAuthorizationEvaluator()
        }
        this.tryAddTransient<IAuthorizationHandlerContextFactory, DefaultAuthorizationHandlerContextFactory> {
            _ => DefaultAuthorizationHandlerContextFactory()
        }
        this.tryAddEnumerable(ServiceDescriptor.transient<IAuthorizationHandler, PassThroughAuthorizationHandler> {
            sp => PassThroughAuthorizationHandler(sp.getOrThrow<IOptions<AuthorizationOptions>>())
        })
        return this
    }

    /**
     * @brief 注册授权策略执行相关服务。
     * @return 服务集合。
     */
    public func addAuthorizationPolicyEvaluator(): ServiceCollection {
        this.tryAddSingleton<IPolicyEvaluator, DefaultPolicyEvaluator>()
        this.tryAddSingleton<IAuthorizationMiddlewareResultHandler, DefaultAuthorizationMiddlewareResultHandler>()
        this.tryAddSingleton<AuthorizationPolicyCache, AuthorizationPolicyCache>()
        return this
    }
}

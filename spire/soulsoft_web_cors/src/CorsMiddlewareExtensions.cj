// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_cors

import soulsoft_web_http.*
import soulsoft_extensions_injection.*
import soulsoft_web_cors.abstractions.*
import soulsoft_web_cors.infrastructure.*

/**
 * @brief 提供向应用管道注册 CORS 中间件的扩展约定。
 */
public interface CorsMiddlewareExtensions {
    /**
     * @brief 使用默认 CORS 策略注册中间件。
     * @return 返回当前应用构建器。
     */
    func useCors(): ApplicationBuilder
    /**
     * @brief 使用指定名称的 CORS 策略注册中间件。
     * @param policyName 要使用的 CORS 策略名称。
     * @return 返回当前应用构建器。
     */
    func useCors(policyName: String): ApplicationBuilder
    /**
     * @brief 使用动态构建的 CORS 策略注册中间件。
     * @param configurePolicy 用于配置 CORS 策略的回调。
     * @return 返回当前应用构建器。
     */
    func useCors(configurePolicy: (CorsPolicyBuilder) -> Unit): ApplicationBuilder
}

extend ApplicationBuilder <: CorsMiddlewareExtensions {
    /**
     * @brief 使用默认 CORS 策略注册中间件。
     * @return 返回当前应用构建器。
     * @throws Exception 当未注册所需的 CORS 服务时抛出。
     */
    public func useCors(): ApplicationBuilder {
        verifyMvcServicesAreRegistered()
        this.use<CorsMiddleware>()
        return this
    }

    /**
     * @brief 使用指定名称的 CORS 策略注册中间件。
     * @param policyName 要使用的 CORS 策略名称。
     * @return 返回当前应用构建器。
     * @throws Exception 当未注册所需的 CORS 服务时抛出。
     */
    public func useCors(policyName: String): ApplicationBuilder {
        verifyMvcServicesAreRegistered()
        this.use<CorsMiddleware>(policyName)
        return this
    }

    /**
     * @brief 使用动态构建的 CORS 策略注册中间件。
     * @param configurePolicy 用于配置 CORS 策略的回调。
     * @return 返回当前应用构建器。
     * @throws Exception 当未注册所需的 CORS 服务时抛出。
     * @throws UnsupportedException 当策略同时允许任意源和凭据时抛出。
     */
    public func useCors(configurePolicy: (CorsPolicyBuilder) -> Unit): ApplicationBuilder {
        verifyMvcServicesAreRegistered()
        let policyBuilder = CorsPolicyBuilder()
        configurePolicy(policyBuilder)
        let policy = policyBuilder.build()
        this.use<CorsMiddleware>(policy)
        return this
    }

    private func verifyMvcServicesAreRegistered() {
        let callSiteFactory = this.services.getOrThrow<IServiceProviderIsService>()
        if (!callSiteFactory.isService<ICorsService>()) {
            throw Exception(
                "Unable to find the required services. Please add all the required services by calling 'ServiceCollection.addCors' inside the call to 'configureServices(...)' in the application startup code.")
        }
    }
}

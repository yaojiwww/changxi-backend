// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_web_cors

import soulsoft_web_http.*
import soulsoft_web_cors.abstractions.*

/**
 * @brief 提供为终结点约定构建器配置 CORS 的扩展约定。
 */
public interface CorsEndpointConventionBuilderExtensions {
    /**
     * @brief 为终结点要求使用默认 CORS 策略。
     * @return 返回当前终结点约定构建器。
     */
    func requireCors(): EndpointConventionBuilder
    /**
     * @brief 为终结点要求使用指定名称的 CORS 策略。
     * @param policyName 要求使用的 CORS 策略名称。
     * @return 返回当前终结点约定构建器。
     */
    func requireCors(policyName: String): EndpointConventionBuilder
    /**
     * @brief 为终结点要求使用动态构建的 CORS 策略。
     * @param configurePolicy 用于配置 CORS 策略的回调。
     * @return 返回当前终结点约定构建器。
     */
    func requireCors(configurePolicy: (CorsPolicyBuilder) -> Unit): EndpointConventionBuilder
}

extend EndpointConventionBuilder <: CorsEndpointConventionBuilderExtensions {
    /**
     * @brief 为终结点要求使用默认 CORS 策略。
     * @return 返回当前终结点约定构建器。
     */
    public func requireCors(): EndpointConventionBuilder {
        this.add {
            endpointBuilder => endpointBuilder.metadata.add(EnableCors())
        }
        return this
    }

    /**
     * @brief 为终结点要求使用指定名称的 CORS 策略。
     * @param policyName 要求使用的 CORS 策略名称。
     * @return 返回当前终结点约定构建器。
     */
    public func requireCors(policyName: String): EndpointConventionBuilder {
        this.add {
            endpointBuilder => endpointBuilder.metadata.add(EnableCors(policyName))
        }
        return this
    }

    /**
     * @brief 为终结点要求使用动态构建的 CORS 策略。
     * @param configurePolicy 用于配置 CORS 策略的回调。
     * @return 返回当前终结点约定构建器。
     * @throws UnsupportedException 当策略同时允许任意源和凭据时抛出。
     */
    public func requireCors(configurePolicy: (CorsPolicyBuilder) -> Unit): EndpointConventionBuilder {
        let policyBuilder = CorsPolicyBuilder()
        configurePolicy(policyBuilder)
        let policy = policyBuilder.build()
        this.add {
            endpointBuilder => endpointBuilder.metadata.add(CorsPolicyMetadata(policy))
        }
        return this
    }
}

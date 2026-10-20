// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_authorization

import soulsoft_extensions_options.*
import soulsoft_extensions_injection.*

/**
 * @brief 提供授权服务与策略的构建入口。
 */
public class AuthorizationBuilder {
    private let _services: ServiceCollection

    /**
     * @brief 创建一个授权构建器。
     * @param services 服务集合。
     */
    public init(services: ServiceCollection) {
        _services = services
    }

    /**
     * @brief 获取当前服务集合。
     * @return 当前授权构建器持有的服务集合。
     */
    public prop services: ServiceCollection {
        get() {
            _services
        }
    }

    /**
     * @brief 设置授权失败后是否继续调用后续处理器。
     * @param invoke 是否继续调用后续处理器。
     * @return 当前授权构建器。
     */
    public func setInvokeHandlersAfterFailure(invoke: Bool): AuthorizationBuilder {
        _services.configure<AuthorizationOptions> {o => o.invokeHandlersAfterFailure = invoke}
        return this
    }

    /**
     * @brief 设置默认授权策略。
     * @param policy 默认授权策略。
     * @return 当前授权构建器。
     */
    public func setDefaultPolicy(policy: AuthorizationPolicy): AuthorizationBuilder {
        _services.configure<AuthorizationOptions> {o => o.defaultPolicy = policy}
        return this
    }

    /**
     * @brief 使用配置回调设置默认授权策略。
     * @param configure 用于构建默认策略的配置回调。
     * @return 当前授权构建器。
     */
    public func setDefaultPolicy(configure: (AuthorizationPolicyBuilder) -> Unit): AuthorizationBuilder {
        var policyBuilder = AuthorizationPolicyBuilder()
        configure(policyBuilder)
        setDefaultPolicy(policyBuilder.build())
        return this
    }

    /**
     * @brief 设置回退授权策略。
     * @param policy 回退授权策略。
     * @return 当前授权构建器。
     */
    public func setFallbackPolicy(policy: ?AuthorizationPolicy): AuthorizationBuilder {
        _services.configure<AuthorizationOptions> {o => o.fallbackPolicy = policy}
        return this
    }

    /**
     * @brief 使用配置回调设置回退授权策略。
     * @param configure 用于构建回退策略的配置回调。
     * @return 当前授权构建器。
     */
    public func setFallbackPolicy(configure: (AuthorizationPolicyBuilder) -> Unit): AuthorizationBuilder {
        var policyBuilder = AuthorizationPolicyBuilder()
        configure(policyBuilder)
        setFallbackPolicy(Some(policyBuilder.build()))
        return this
    }

    /**
     * @brief 添加命名授权策略。
     * @param name 策略名称。
     * @param policy 授权策略。
     * @return 当前授权构建器。
     */
    public func addPolicy(name: String, policy: AuthorizationPolicy): AuthorizationBuilder {
        _services.configure<AuthorizationOptions> {o => o.addPolicy(name, policy)}
        return this
    }

    /**
     * @brief 使用配置回调添加命名授权策略。
     * @param name 策略名称。
     * @param configurePolicy 用于构建策略的配置回调。
     * @return 当前授权构建器。
     */
    public func addPolicy(name: String, configurePolicy: (AuthorizationPolicyBuilder) -> Unit): AuthorizationBuilder {
        _services.configure<AuthorizationOptions> {o => o.addPolicy(name, configurePolicy)}
        return this
    }

    /**
     * @brief 添加并设置默认授权策略。
     * @param name 策略名称。
     * @param policy 授权策略。
     * @return 当前授权构建器。
     */
    public func addDefaultPolicy(name: String, policy: AuthorizationPolicy): AuthorizationBuilder {
        setDefaultPolicy(policy)
        return addPolicy(name, policy)
    }

    /**
     * @brief 使用配置回调添加并设置默认授权策略。
     * @param name 策略名称。
     * @param configure 用于构建策略的配置回调。
     * @return 当前授权构建器。
     */
    public func addDefaultPolicy(name: String, configure: (AuthorizationPolicyBuilder) -> Unit): AuthorizationBuilder {
        var policyBuilder = AuthorizationPolicyBuilder()
        configure(policyBuilder)
        return addDefaultPolicy(name, policyBuilder.build())
    }

    /**
     * @brief 添加并设置回退授权策略。
     * @param name 策略名称。
     * @param policy 授权策略。
     * @return 当前授权构建器。
     */
    public func addFallbackPolicy(name: String, policy: AuthorizationPolicy): AuthorizationBuilder {
        setFallbackPolicy(policy)
        return addPolicy(name, policy)
    }

    /**
     * @brief 使用配置回调添加并设置回退授权策略。
     * @param name 策略名称。
     * @param configure 用于构建策略的配置回调。
     * @return 当前授权构建器。
     */
    public func addFallbackPolicy(name: String, configure: (AuthorizationPolicyBuilder) -> Unit): AuthorizationBuilder {
        var policyBuilder = AuthorizationPolicyBuilder()
        configure(policyBuilder)
        return addFallbackPolicy(name, policyBuilder.build())
    }
}

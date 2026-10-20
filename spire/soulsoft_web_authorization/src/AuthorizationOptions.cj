// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_authorization

import std.collection.*

/**
 * @brief 表示授权系统的配置选项。
 */
public class AuthorizationOptions {
    private var _defaultPolicy: AuthorizationPolicy
    private let _policyMap = HashMap<String, AuthorizationPolicy>()

    /**
     * @brief 创建一组默认授权选项。
     */
    public init() {
        _defaultPolicy = AuthorizationPolicyBuilder().requireAuthenticatedUser().build()
    }

    /**
     * @brief 指示授权失败后是否继续调用后续处理器。
     */
    public var invokeHandlersAfterFailure = true

    /**
     * @brief 获取或修改未显式声明授权元数据时使用的回退策略。
     */
    public var fallbackPolicy: ?AuthorizationPolicy = None

    /**
     * @brief 指示授权资源是否使用端点而非 HTTP 上下文。
     */
    public var suppressUseHttpContextAsAuthorizationResource = false

    /**
     * @brief 获取或修改默认授权策略。
     */
    public mut prop defaultPolicy: AuthorizationPolicy {
        get() {
            _defaultPolicy
        }
        set(value) {
            _defaultPolicy = value
        }
    }

    /**
     * @brief 添加命名授权策略。
     * @param name 策略名称。
     * @param policy 授权策略。
     */
    public func addPolicy(name: String, policy: AuthorizationPolicy): Unit {
        _policyMap.add(name.toAsciiLower(), policy)
    }

    /**
     * @brief 使用配置回调添加命名授权策略。
     * @param name 策略名称。
     * @param configurePolicy 用于构建策略的配置回调。
     */
    public func addPolicy(name: String, configurePolicy: (AuthorizationPolicyBuilder) -> Unit): Unit {
        let builder = AuthorizationPolicyBuilder()
        configurePolicy(builder)
        _policyMap[name.toAsciiLower()] = builder.build()
    }

    /**
     * @brief 按名称获取授权策略。
     * @param name 策略名称。
     * @return 对应的授权策略；如果不存在则返回空。
     */
    public func getPolicy(name: String): ?AuthorizationPolicy {
        return _policyMap.get(name.toAsciiLower())
    }
}

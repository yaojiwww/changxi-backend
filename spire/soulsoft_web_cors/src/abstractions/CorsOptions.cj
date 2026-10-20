// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_cors.abstractions

import std.collection.*
import soulsoft_web_http.*

/**
 * @brief 表示 CORS 组件使用的选项集合。
 */
public class CorsOptions {
    protected let policyMap = HashMap<String, CorsPolicy>()
    private var _defaultPolicyName = "__DefaultCorsPolicy"

    /**
     * @brief 根据请求上下文和策略名称解析 CORS 策略。
     */
    public var policyResolver: (HttpContext, ?String) -> ?CorsPolicy = {_, _ => None}

    /**
     * @brief 获取或设置默认 CORS 策略名称。
     * @return 当前默认 CORS 策略名称。
     */
    public mut prop defaultPolicyName: String {
        get() {
            _defaultPolicyName
        }
        set(value) {
            _defaultPolicyName = value
        }
    }

    /**
     * @brief 将指定策略注册为默认 CORS 策略。
     * @param policy 要注册为默认策略的 CORS 策略。
     */
    public func addDefaultPolicy(policy: CorsPolicy): Unit {
        addPolicy(defaultPolicyName, policy)
    }

    /**
     * @brief 通过构建回调注册默认 CORS 策略。
     * @param configurePolicy 用于配置默认策略的回调。
     * @throws UnsupportedException 当构建出的策略同时允许任意源和凭据时抛出。
     */
    public func addDefaultPolicy(configurePolicy: (CorsPolicyBuilder) -> Unit): Unit {
        addPolicy(defaultPolicyName, configurePolicy)
    }

    /**
     * @brief 通过构建回调注册指定名称的 CORS 策略。
     * @param name 要注册的 CORS 策略名称。
     * @param configurePolicy 用于配置策略的回调。
     * @throws UnsupportedException 当构建出的策略同时允许任意源和凭据时抛出。
     */
    public func addPolicy(name: String, configurePolicy: (CorsPolicyBuilder) -> Unit): Unit {
        let policyBuilder = CorsPolicyBuilder()
        configurePolicy(policyBuilder)
        let policy = policyBuilder.build()
        addPolicy(name, policy)
    }

    /**
     * @brief 注册指定名称的 CORS 策略。
     * @param name 要注册的 CORS 策略名称。
     * @param policy 要注册的 CORS 策略实例。
     */
    public func addPolicy(name: String, policy: CorsPolicy): Unit {
        policyMap[name] = policy
    }

    /**
     * @brief 按名称获取已注册的 CORS 策略。
     * @param name 要查找的 CORS 策略名称。
     * @return 返回匹配的 CORS 策略；如果不存在则返回空。
     */
    public func getPolicy(name: String): ?CorsPolicy {
        policyMap.get(name)
    }
}

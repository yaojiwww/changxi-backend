// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_authorization

import soulsoft_extensions_options.*

/**
 * @brief 提供默认的授权策略提供器。
 */
public class DefaultAuthorizationPolicyProvider <: IAuthorizationPolicyProvider {
    private let _options: AuthorizationOptions
    private var _cachedDefaultPolicy: ?AuthorizationPolicy = None
    private var _cachedFallbackPolicy: ?AuthorizationPolicy = None

    /**
     * @brief 创建一个默认授权策略提供器。
     * @param options 授权选项。
     */
    public init(options: IOptions<AuthorizationOptions>) {
        _options = options.value
    }

    /**
     * @brief 获取当前提供器是否允许缓存策略。
     * @return 默认提供器始终允许缓存策略，返回 `true`。
     */
    public prop allowsCachingPolicies: Bool {
        get() {
            true
        }
    }

    /**
     * @brief 按名称获取授权策略。
     * @param policyName 策略名称。
     * @return 对应的授权策略；如果不存在则返回空。
     */
    public func getPolicy(policyName: String): ?AuthorizationPolicy {
        _options.getPolicy(policyName)
    }

    /**
     * @brief 获取默认授权策略。
     * @return 默认授权策略。
     */
    public func getDefaultPolicy(): AuthorizationPolicy {
        if (_cachedDefaultPolicy.isNone() || _cachedDefaultPolicy.flatMap {f => !refEq(f, _options.defaultPolicy)} ==
            Some(true)) {
            _cachedDefaultPolicy = _options.defaultPolicy
        }
        return _cachedDefaultPolicy.getOrThrow()
    }

    /**
     * @brief 获取回退授权策略。
     * @return 回退授权策略；如果未配置则返回空。
     */
    public func getFallbackPolicy(): ?AuthorizationPolicy {
        let hasCached = match ((_cachedFallbackPolicy, _options.fallbackPolicy)) {
            case (Some(a), Some(b)) => refEq(a, b)
            case _ => false
        }

        if (_cachedFallbackPolicy.isNone() || !hasCached) {
            _cachedFallbackPolicy = _options.fallbackPolicy
        }
        return _cachedFallbackPolicy
    }
}

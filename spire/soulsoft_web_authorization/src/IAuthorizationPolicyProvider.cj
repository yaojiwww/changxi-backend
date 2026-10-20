// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_authorization

/**
 * @brief 定义授权策略提供器接口。
 */
public interface IAuthorizationPolicyProvider {
    /**
     * @brief 获取当前提供器是否允许缓存策略。
     */
    prop allowsCachingPolicies: Bool {
        get() { false }
    }
    /**
     * @brief 按名称获取授权策略。
     * @param policyName 策略名称。
     * @return 对应的授权策略；如果不存在则返回空。
     */
    func getPolicy(policyName: String): ?AuthorizationPolicy
    /**
     * @brief 获取默认授权策略。
     * @return 默认授权策略。
     */
    func getDefaultPolicy(): AuthorizationPolicy
    /**
     * @brief 获取回退授权策略。
     * @return 回退授权策略；如果未配置则返回空。
     */
    func getFallbackPolicy(): ?AuthorizationPolicy
}

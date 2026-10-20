// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_authorization

import soulsoft_web_http.*

/**
 * @brief 表示应用在类型或成员上的授权元数据注解。
 */
@Annotation[target: [Type, MemberFunction]]
public class Authorize <: IAuthorizeData {
    private let _policy: ?String
    private let _roles: ?String
    private let _authenticationSchemes: ?String

    /**
     * @brief 创建一个仅指定策略名称的授权注解。
     * @param policy 策略名称。
     */
    public const init(policy: String) {
        this(policy: policy, roles: None, authenticationSchemes: None)
    }

    /**
     * @brief 创建一个授权注解。
     * @param policy 策略名称。
     * @param roles 允许访问的角色列表字符串。
     * @param authenticationSchemes 认证方案列表字符串。
     */
    public const init(policy!: ?String = None, roles!: ?String = None, authenticationSchemes!: ?String = None) {
        _policy = policy
        _roles = roles
        _authenticationSchemes = authenticationSchemes
    }

    /**
     * @brief 获取授权策略名称。
     * @return 当前注解配置的授权策略名称；未配置时返回 `None`。
     */
    public prop policy: ?String {
        get() {
            _policy
        }
    }

    /**
     * @brief 获取允许访问的角色列表字符串。
     * @return 当前注解配置的角色列表字符串；未配置时返回 `None`。
     */
    public prop roles: ?String {
        get() {
            _roles
        }
    }

    /**
     * @brief 获取认证方案列表字符串。
     * @return 当前注解配置的认证方案列表字符串；未配置时返回 `None`。
     */
    public prop authenticationSchemes: ?String {
        get() {
            _authenticationSchemes
        }
    }
}

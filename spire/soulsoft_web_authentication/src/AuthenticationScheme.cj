// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_authentication

import std.reflect.*

/**
 * @brief 表示一个身份验证方案定义。
 */
public class AuthenticationScheme {
    private let _name: String
    private let _displayName: ?String
    private let _handlerType: TypeInfo

    /**
     * @brief 创建一个身份验证方案。
     * @param name 方案名称。
     * @param displayName 方案显示名称。
     * @param handlerType 处理器类型。
     * @throws IllegalArgumentException 当处理器类型不是身份验证处理器子类型时抛出。
     */
    public init(name: String, displayName: ?String, handlerType: TypeInfo) {
        _name = name
        _displayName = displayName
        _handlerType = handlerType

        if (!handlerType.isSubtypeOf(TypeInfo.of<IAuthenticationHandler>())) {
            throw IllegalArgumentException("handlerType must be a subtype of IAuthenticationHandler")
        }
    }

    /**
     * @brief 返回方案名称。
     * @return 方案名称。
     */
    public prop name: String {
        get() {
            _name
        }
    }

    /**
     * @brief 返回方案显示名称。
     * @return 方案显示名称；未设置时返回 None。
     */
    public prop displayName: ?String {
        get() {
            _displayName
        }
    }

    /**
     * @brief 返回方案处理器类型。
     * @return 方案处理器类型。
     */
    public prop handlerType: TypeInfo {
        get() {
            _handlerType
        }
    }
}

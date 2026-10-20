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
 * @brief 用于构建身份验证方案定义。
 */
public class AuthenticationSchemeBuilder {
    private let _name: String

    /**
     * @brief 指定方案显示名称。
     */
    public var displayName: ?String = None
    /**
     * @brief 指定方案处理器类型。
     */
    public var handlerType: ?TypeInfo = None

    /**
     * @brief 创建一个身份验证方案构建器。
     * @param name 方案名称。
     */
    public init(name: String) {
        _name = name
    }

    /**
     * @brief 返回当前方案名称。
     * @return 方案名称。
     */
    public prop name: String {
        get() {
            _name
        }
    }

    /**
     * @brief 根据当前配置构建身份验证方案。
     * @return 构建后的身份验证方案。
     */
    public func build(): AuthenticationScheme {
        AuthenticationScheme(_name, displayName, handlerType.getOrThrow())
    }
}

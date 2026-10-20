// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_authentication

import std.collection.*

/**
 * @brief 表示身份验证系统的全局配置。
 */
public class AuthenticationOptions {
    private let _schemes = ArrayList<AuthenticationScheme>()
    private let _schemeMap = HashSet<String>()
    /**
     * @brief 指定默认身份验证方案名称。
     */
    public var defaultScheme: ?String = None
    /**
     * @brief 指定默认登录方案名称。
     */
    public var defaultSignInScheme: ?String = None
    /**
     * @brief 指定默认登出方案名称。
     */
    public var defaultSignOutScheme: ?String = None
    /**
     * @brief 指定是否要求登录主体已通过身份验证。
     */
    public var requireAuthenticatedSignIn = true
    /**
     * @brief 指定默认 authenticate 方案名称。
     */
    public var defaultAuthenticateScheme: ?String = None
    /**
     * @brief 指定默认 forbid 方案名称。
     */
    public var defaultForbidScheme: ?String = None
    /**
     * @brief 指定默认 challenge 方案名称。
     */
    public var defaultChallengeScheme: ?String = None

    /**
     * @brief 返回已注册身份验证方案列表。
     * @return 只读身份验证方案列表。
     */
    public prop schemes: ReadOnlyList<AuthenticationScheme> {
        get() {
            return _schemes
        }
    }

    /**
     * @brief 返回已注册方案名称集合。
     * @return 只读方案名称集合。
     */
    public prop schemeMap: ReadOnlySet<String> {
        get() {
            _schemeMap
        }
    }

    /**
     * @brief 添加一个身份验证方案定义。
     * @param name 方案名称。
     * @param configureBuilder 方案构建配置回调。
     * @throws IllegalArgumentException 当方案名称已存在时抛出。
     */
    public func addScheme(name: String, configureBuilder: (AuthenticationSchemeBuilder) -> Unit): Unit {
        if (_schemeMap.contains(name)) {
            throw IllegalArgumentException("Scheme already exists: " + name)
        }
        var builder = AuthenticationSchemeBuilder(name)
        configureBuilder(builder)
        _schemes.add(builder.build())
        _schemeMap.add(name)
    }
}

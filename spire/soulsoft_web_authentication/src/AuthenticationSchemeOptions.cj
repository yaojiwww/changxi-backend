// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_authentication

import soulsoft_web_http.*

/**
 * @brief 表示身份验证方案的基础选项。
 */
public open class AuthenticationSchemeOptions {
    /**
     * @brief 指定身份验证时要转发到的方案名称。
     */
    public var forwardAuthenticate: ?String = None
    /**
     * @brief 指定质询时要转发到的方案名称。
     */
    public var forwardChallenge: ?String = None
    /**
     * @brief 指定禁止访问时要转发到的方案名称。
     */
    public var forwardForbid: ?String = None
    /**
     * @brief 指定默认转发方案名称。
     */
    public var forwardDefault: ?String = None
    /**
     * @brief 指定登录时要转发到的方案名称。
     */
    public var forwardSignIn: ?String = None
    /**
     * @brief 指定登出时要转发到的方案名称。
     */
    public var forwardSignOut: ?String = None
    /**
     * @brief 指定按请求动态选择默认转发方案的回调。
     */
    public var forwardDefaultSelector: ?(HttpContext) -> ?String = None
    /**
     * @brief 验证当前方案选项。
     */
    public open func validate(): Unit {}
    /**
     * @brief 针对指定方案名称验证当前选项。
     * @param scheme 当前方案名称。
     */
    public open func validate(scheme: String): Unit {
        validate()
    }
}

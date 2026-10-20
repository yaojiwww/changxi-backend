// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_http

/**
 * @brief 表示 Cookie 的安全传输策略。
 */
public struct CookieSecurePolicy <: ToString & Equatable<CookieSecurePolicy> {
    private let _value: String

    private init(value: String) {
        _value = value
    }

    /**
     * @brief 表示跟随当前请求是否为 HTTPS 来决定是否启用安全传输。
     */
    public static let SameAsRequest = CookieSecurePolicy("SameAsRequest")
    /**
     * @brief 表示始终启用安全传输。
     */
    public static let Always = CookieSecurePolicy("Always")
    /**
     * @brief 表示不强制启用安全传输。
     */
    public static let None = CookieSecurePolicy("None")

    /**
     * @brief 返回当前安全策略的字符串表示。
     * @return 当前安全策略的字符串表示。
     */
    public func toString(): String {
        _value
    }

    /**
     * @brief 比较两个安全策略是否相等。
     * @param that 要比较的安全策略。
     * @return 如果两者相等则返回 true，否则返回 false。
     */
    public operator func ==(that: CookieSecurePolicy): Bool {
        this._value == that._value
    }
}

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_http

/**
 * @brief 表示 Cookie 的 SameSite 策略。
 */
public struct CookieSameSiteMode <: ToString & Equatable<CookieSameSiteMode> {
    private let _value: String

    private init(value: String) {
        _value = value
    }

    /**
     * @brief 表示未显式指定 SameSite 策略。
     */
    public static let Unspecified = CookieSameSiteMode("unspecified")
    /**
     * @brief 表示允许跨站发送 Cookie。
     */
    public static let None = CookieSameSiteMode("None")
    /**
     * @brief 表示仅在宽松同站场景下发送 Cookie。
     */
    public static let Lax = CookieSameSiteMode("lax")
    /**
     * @brief 表示仅在严格同站场景下发送 Cookie。
     */
    public static let Strict = CookieSameSiteMode("strict")

    /**
     * @brief 返回当前 SameSite 策略的字符串表示。
     * @return 当前 SameSite 策略的字符串表示。
     */
    public func toString(): String {
        _value
    }

    /**
     * @brief 比较两个 SameSite 策略是否相等。
     * @param that 要比较的 SameSite 策略。
     * @return 如果两者相等则返回 true，否则返回 false。
     */
    public operator func ==(that: CookieSameSiteMode): Bool {
        this._value == that._value
    }
}

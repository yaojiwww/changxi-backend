// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_http

import std.convert.*

/**
 * @brief 表示 URI 的主机部分。
 * @description 支持 IPv4、IPv6 以及可选端口，可用于构造格式化后的主机头值。
 */
public struct HostString <: Equatable<HostString> & Equatable<String> & ToString {
    private let _value: String

    /**
     * @brief 使用原始主机字符串创建实例。
     * @param value 原始主机字符串值。
     */
    public init(value: String) {
        _value = value
    }

    /**
     * @brief 使用主机名和端口创建实例。
     * @param host 主机名或 IP 地址。
     * @param port 端口号。
     * @throws IllegalArgumentException 当端口号小于或等于 0 时抛出。
     */
    public init(host: String, port: Int64) {
        if (port <= 0) {
            throw IllegalArgumentException("The port must be greater than zero. (Parameter 'port')")
        }
        // IPv6 without brackets ::1 is the only type of host with 2 or more colons
        let h = if (!host.indexOf('[').isSome() && hasMultipleColons(host)) {
            "[${host}]"
        } else {
            host
        }
        _value = "${h}:${port}"
    }

    /**
     * @brief 返回原始主机字符串值。
     * @return 原始主机字符串值。
     */
    public prop value: String {
        get() {
            _value
        }
    }

    /**
     * @brief 检查当前实例是否包含主机值。
     * @return 如果当前实例包含主机值则返回 true，否则返回 false。
     */
    public prop hasValue: Bool {
        get() {
            !_value.isEmpty()
        }
    }

    /**
     * @brief 返回主机部分。
     * @return 不包含端口的主机值；IPv6 地址会按需补全方括号。
     */
    public prop host: String {
        get() {
            let (h, _) = getParts(_value)
            return h
        }
    }

    /**
     * @brief 返回端口部分。
     * @return 当前主机值中的端口号；如果不存在端口则返回空。
     */
    public prop port: ?Int64 {
        get() {
            let (_, portPart) = getParts(_value)
            if (let Some(portStr) <- portPart) {
                return Int64.tryParse(portStr)
            }
            return None
        }
    }

    /**
     * @brief 返回适合写入 URI 组件的主机字符串。
     * @return 当前实例的 URI 组件表示。
     */
    public func toUriComponent(): String {
        if (!hasValue) {
            return String.empty
        }
        return _value
    }

    /**
     * @brief 从 URI 主机组件创建实例。
     * @param uriComponent URI 中的主机组件。
     * @return 创建后的主机字符串实例。
     */
    public static func fromUriComponent(uriComponent: String): HostString {
        return HostString(uriComponent)
    }

    /**
     * @brief 检查主机值是否匹配任一模式。
     * @description 比较时会忽略主机值中的端口部分，支持精确匹配、全通配符和子域名通配符。
     * @param value 要匹配的主机值。
     * @param patterns 主机匹配模式集合。
     * @return 如果主机值匹配任一模式则返回 true，否则返回 false。
     * @throws IllegalArgumentException 当主机值中的端口格式非法时抛出。
     */
    public static func matchesAny(value: String, patterns: Collection<String>): Bool {
        let (host, portPart) = getParts(value)

        // 验证端口只包含数字
        if (let Some(p) <- portPart) {
            for (i in 0..p.size) {
                let c = p[i]
                if (c < b'0' || c > b'9') {
                    throw IllegalArgumentException("The given host value '${value}' has a malformed port.")
                }
            }
        }

        for (pattern in patterns) {
            // 全通配符
            if (pattern == "*") {
                return true
            }

            // 精确匹配（大小写不敏感）
            if (pattern.equalsIgnoreAsciiCase(host)) {
                return true
            }

            // 子域名通配符：*.example.com
            if (pattern.startsWith("*.") && host.size >= pattern.size) {
                // allowedRoot = ".example.com"
                let allowedRoot = pattern[1..]
                let hostRoot = host[host.size - allowedRoot.size..]
                if (hostRoot.equalsIgnoreAsciiCase(allowedRoot)) {
                    return true
                }
            }
        }

        return false
    }

    /**
     * @brief 比较两个主机字符串是否相等。
     * @param other 要比较的主机字符串。
     * @return 如果两个主机字符串相等则返回 true，否则返回 false。
     */
    public operator func ==(other: HostString): Bool {
        if (!hasValue && !other.hasValue) {
            return true
        }
        return this._value.equalsIgnoreAsciiCase(other._value)
    }

    /**
     * @brief 比较当前实例与字符串值是否相等。
     * @param value 要比较的字符串值。
     * @return 如果两者相等则返回 true，否则返回 false。
     */
    public operator func ==(value: String): Bool {
        return this._value == value
    }

    /**
     * @brief 返回当前实例的字符串表示。
     * @return 当前实例的 URI 组件表示。
     */
    public func toString(): String {
        toUriComponent()
    }

    /// 将 value 解析为 (host, port?)。
    /// 处理以下格式：
    ///   [::1]          → host="[::1]",        port=None
    ///   [::1]:8080     → host="[::1]",        port=Some("8080")
    ///   ::1            → host="[::1]",        port=None   （自动加括号）
    ///   example.com    → host="example.com",  port=None
    ///   example.com:80 → host="example.com",  port=Some("80")
    private static func getParts(value: String): (String, ?String) {
        if (value.isEmpty()) {
            return (String.empty, None)
        }

        // IPv6 in brackets [::1], maybe with port: [::1]:8080
        if (let Some(closingIndex) <- value.indexOf(']')) {
            let h = value[0..closingIndex + 1]
            let p: ?String = if (closingIndex + 2 < value.size && value[closingIndex + 1] == b':') {
                Some(value[closingIndex + 2..])
            } else {
                None
            }
            return (h, p)
        }

        // IPv6 without brackets ::1 is the only type of host with 2 or more colons
        if (hasMultipleColons(value)) {
            return ("[${value}]", None)
        }

        // 普通 host，可能带有端口
        if (let Some(index) <- value.indexOf(':')) {
            return (value[0..index], Some(value[index + 1..]))
        }

        // 仅有 host，无端口
        return (value, None)
    }

    /// 判断字符串中是否包含两个或以上的冒号（用于识别无括号 IPv6 地址）。
    private static func hasMultipleColons(value: String): Bool {
        var count = 0
        for (i in 0..value.size) {
            if (value[i] == b':') {
                count++
                if (count >= 2) {
                    return true
                }
            }
        }
        return false
    }
}

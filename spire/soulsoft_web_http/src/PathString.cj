// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_http

/**
 * @brief 表示请求路径字符串。
 * @description 提供 Path 和 PathBase 值的正确转义，用于重建请求或重定向 URI。
 */
public struct PathString <: Equatable<PathString> & Equatable<String> & Hashable & ToString {

    /**
     * @brief 表示空路径字符串。
     */
    public static let empty: PathString = PathString("")

    private let _value: String

    /**
     * @brief 使用未转义路径值创建实例。
     * @param value 未转义的路径值。
     * @throws IllegalArgumentException 当非空路径未以 `/` 开头时抛出。
     */
    public init(value: String) {
        if (!value.isEmpty() && value[0] != b'/') {
            throw IllegalArgumentException("The path in 'value' must start with '/'. (Parameter 'value')")
        }
        _value = value
    }

    /**
     * @brief 返回原始路径值。
     * @return 当前实例的原始路径值。
     */
    public prop value: String {
        get() {
            _value
        }
    }

    /**
     * @brief 检查当前实例是否包含路径值。
     * @return 如果当前实例包含路径值则返回 true，否则返回 false。
     */
    public prop hasValue: Bool {
        get() {
            !_value.isEmpty()
        }
    }

    /**
     * @brief 返回当前路径的字符串表示。
     * @return 当前路径的 URI 组件表示。
     */
    public func toString(): String {
        toUriComponent()
    }

    /**
     * @brief 返回 URI 格式的路径字符串。
     * @return 按 URI 规则转义后的路径字符串。
     */
    public func toUriComponent(): String {
        if (_value.isEmpty()) {
            return ""
        }
        let bytes = _value.toArray()
        // 扫描找到第一个需要编码的位置
        var i: Int64 = 0
        while (i < bytes.size) {
            let b = bytes[i]
            if (b == b'%' && i + 2 < bytes.size && isHexDigit(bytes[i + 1]) && isHexDigit(bytes[i + 2])) {
                i += 3 // 已是合法 %XX，跳过
            } else if (isValidPathChar(b)) {
                i++
            } else {
                return buildEscapedUri(bytes, i)
            }
        }
        return _value
    }

    // 从 firstInvalid 处开始构建 percent-encoded URI 字符串
    private static func buildEscapedUri(bytes: Array<Byte>, firstInvalid: Int64): String {
        let sb = StringBuilder()
        // 合法前缀直接追加
        sb.append(unsafe { String.fromUtf8Unchecked(bytes.slice(0, firstInvalid)) })
        var i = firstInvalid
        while (i < bytes.size) {
            let b = bytes[i]
            if (b == b'%' && i + 2 < bytes.size && isHexDigit(bytes[i + 1]) && isHexDigit(bytes[i + 2])) {
                // 已经是 %XX，原样追加
                sb.append(unsafe { String.fromUtf8Unchecked(bytes.slice(i, 3)) })
                i += 3
            } else if (isValidPathChar(b)) {
                sb.append(unsafe { String.fromUtf8Unchecked([b]) })
                i++
            } else {
                // 对每个字节做 %XX 编码
                let hi = UInt8(Int64(b) >> 4)
                let lo = UInt8(Int64(b) & 0x0F)
                sb.append("%")
                sb.append(hexDigit(hi))
                sb.append(hexDigit(lo))
                i++
            }
        }
        return sb.toString()
    }

    /**
     * @brief 从 URI 路径组件创建实例。
     * @param uriComponent URI 中的路径组件。
     * @return 创建后的路径字符串实例。
     */
    public static func fromUriComponent(uriComponent: String): PathString {
        if (uriComponent.indexOf('%').isNone()) {
            return PathString(uriComponent)
        }
        let bytes = uriComponent.toArray()
        let out = Array<Byte>(bytes.size, repeat: 0)
        var outLen: Int64 = 0
        var i: Int64 = 0
        while (i < bytes.size) {
            let b = bytes[i]
            if (b == b'%' && i + 2 < bytes.size && isHexDigit(bytes[i + 1]) && isHexDigit(bytes[i + 2])) {
                let hi = hexValue(bytes[i + 1])
                let lo = hexValue(bytes[i + 2])
                out[outLen] = UInt8((hi << 4) | lo)
                outLen++
                i += 3
            } else {
                out[outLen] = b
                outLen++
                i++
            }
        }
        return PathString(unsafe { String.fromUtf8Unchecked(out.slice(0, outLen)) })
    }

    /**
     * @brief 按路径段检查当前路径是否以前缀路径开头。
     * @param that 要匹配的前缀路径。
     * @return 匹配成功时返回剩余路径，否则返回空。
     */
    public func startsWithSegments(that: PathString): ?PathString {
        startsWithSegments(that, true)
    }

    /**
     * @brief 按路径段检查当前路径是否以前缀路径开头。
     * @param that 要匹配的前缀路径。
     * @param ignoreCase 是否忽略大小写。
     * @return 匹配成功时返回剩余路径，否则返回空。
     */
    public func startsWithSegments(that: PathString, ignoreCase: Bool): ?PathString {
        let v1 = if (ignoreCase) {
            _value.toAsciiLower()
        } else {
            _value
        }
        let v2 = if (ignoreCase) {
            that._value.toAsciiLower()
        } else {
            that._value
        }
        if (v1.startsWith(v2) && (v1.size == v2.size || v1[v2.size] == b'/')) {
            // remaining 保留原始大小写，对应 C# value1[value2.Length..]
            return PathString(_value[that._value.size..])
        }
        return None
    }

    /**
     * @brief 拼接两个路径字符串。
     * @param other 要追加的路径字符串。
     * @return 拼接后的路径字符串。
     */
    public func add(other: PathString): PathString {
        if (hasValue && other.hasValue && _value[_value.size - 1] == b'/') {
            // 去掉 other 的前导 '/' 避免双斜杠
            return PathString(_value + other._value[1..])
        }
        return PathString(_value + other._value)
    }

    /**
     * @brief 将路径与查询字符串合并为 URI 字符串。
     * @param other 要追加的查询字符串。
     * @return 合并后的 URI 字符串。
     */
    public func add(other: QueryString): String {
        toUriComponent() + other.toUriComponent()
    }

    // -------------------------------------------------------------------------
    // Equatable 
    // -------------------------------------------------------------------------

    /**
     * @brief 比较两个路径字符串是否相等。
     * @param other 要比较的路径字符串。
     * @return 如果两个路径字符串相等则返回 true，否则返回 false。
     */
    public operator func ==(other: PathString): Bool {
        if (!hasValue && !other.hasValue) {
            return true
        }
        return _value.toAsciiLower() == other._value.toAsciiLower()
    }

    /**
     * @brief 比较当前路径与字符串值是否相等。
     * @param other 要比较的字符串值。
     * @return 如果两者相等则返回 true，否则返回 false。
     */
    public operator func ==(other: String): Bool {
        _value.toAsciiLower() == other.toAsciiLower()
    }

    /**
     * @brief 返回当前路径的哈希值。
     * @return 当前路径的哈希值。
     */
    public func hashCode(): Int64 {
        _value.toAsciiLower().hashCode()
    }

    // -------------------------------------------------------------------------
    // 运算符重载
    // -------------------------------------------------------------------------

    /**
     * @brief 使用加号运算符合并两个路径字符串。
     * @param other 要追加的路径字符串。
     * @return 合并后的路径字符串。
     */
    public operator func +(other: PathString): PathString {
        add(other)
    }

    /**
     * @brief 使用加号运算符合并路径和查询字符串。
     * @param other 要追加的查询字符串。
     * @return 合并后的 URI 字符串。
     */
    public operator func +(other: QueryString): String {
        add(other)
    }

    /**
     * @brief 使用加号运算符将路径与字符串拼接。
     * @param other 要追加的字符串。
     * @return 拼接后的字符串结果。
     */
    public operator func +(other: String): String {
        toUriComponent() + other
    }

    // -------------------------------------------------------------------------
    // 私有工具函数
    // -------------------------------------------------------------------------

    // 合法的 URI path 字符（无需 percent-encoding）
    private static func isValidPathChar(b: Byte): Bool {
        return (b >= b'A' && b <= b'Z') || (b >= b'a' && b <= b'z') || (b >= b'0' && b <= b'9') || b == b'!' || b == b'$' ||
            b == b'&' || b == b'\'' || b == b'(' || b == b')' || b == b'*' || b == b'+' || b == b',' || b == b'-' ||
            b == b'.' || b == b'/' || b == b':' || b == b';' || b == b'=' || b == b'@' || b == b'_' || b == b'~'
    }

    private static func isHexDigit(b: Byte): Bool {
        return (b >= b'0' && b <= b'9') || (b >= b'A' && b <= b'F') || (b >= b'a' && b <= b'f')
    }

    // 将十六进制字符转为数值（返回 Int64，避免 Byte 溢出运算）
    // 调用方已通过 isHexDigit 保证输入合法，减法结果不会下溢
    @OverflowWrapping
    private static func hexValue(b: Byte): Int64 {
        if (b >= b'0' && b <= b'9') {
            return Int64(b - b'0')
        }
        if (b >= b'A' && b <= b'F') {
            return Int64(b - b'A') + 10
        }
        return Int64(b - b'a') + 10
    }

    // 将 4-bit 数值（0-15）转为大写十六进制字符串
    // n ∈ [0,9]：n + 48 ≤ 57；n ∈ [10,15]：n - 10 + 65 ≤ 70，均在 Byte 范围内
    @OverflowWrapping
    private static func hexDigit(n: Byte): String {
        let c: Byte = if (n < 10) {
            n + b'0'
        } else {
            n - 10 + b'A'
        }
        return unsafe { String.fromUtf8Unchecked([c]) }
    }
}

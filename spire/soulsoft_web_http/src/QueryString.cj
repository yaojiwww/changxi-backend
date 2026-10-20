// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_http


/**
 * @brief 表示带前导问号的查询字符串。
 */
public struct QueryString <: Equatable<QueryString> & Equatable<String> & Hashable & ToString {
    private let _value: String

    /**
     * @brief 表示空查询字符串。
     */
    public static let empty = QueryString(String.empty)

    /**
     * @brief 使用原始查询字符串值创建实例。
     * @param value 原始查询字符串值。
     * @throws IllegalArgumentException 当非空值缺少前导问号时抛出。
     */
    public init(value: String) {
        if (!value.isEmpty() && value[0] != b'?') {
            throw IllegalArgumentException(
                "The leading '?' must be included for a non-empty query. (Parameter 'value')")
        }
        _value = value
    }

    /**
     * @brief 返回原始查询字符串值。
     * @return 原始查询字符串值。
     */
    public prop value: String {
        get() {
            _value
        }
    }

    /**
     * @brief 检查当前查询字符串是否包含值。
     * @return 如果当前查询字符串包含值则返回 true，否则返回 false。
     */
    public prop hasValue: Bool {
        get() {
            _value.size > 0
        }
    }

    /**
     * @brief 返回适合组合到 URI 中的查询字符串表示。
     * @return 转义后的查询字符串表示。
     */
    public func toUriComponent(): String {
        if (!hasValue) {
            return String.empty
        }
        return _value.replace("#", "%23")
    }

    /**
     * @brief 从 URI 查询部分创建查询字符串实例。
     * @param uriComponent URI 中的查询部分。
     * @return 创建后的查询字符串实例。
     */
    public static func fromUriComponent(uriComponent: String): QueryString {
        if (uriComponent.isEmpty()) {
            return QueryString(String.empty)
        }
        return QueryString(uriComponent)
    }

    /**
     * @brief 使用单个键值对创建查询字符串。
     * @param name 查询参数名称。
     * @param value 查询参数值。
     * @return 创建后的查询字符串。
     */
    public static func create(name: String, value: String): QueryString {
        let encodedName = HttpUtility.urlEncode(name)
        let encodedValue = HttpUtility.urlEncode(value)
        return QueryString("?${encodedName}=${encodedValue}")
    }

    /**
     * @brief 使用键值对集合创建查询字符串。
     * @param parameters 查询参数键值对集合。
     * @return 创建后的查询字符串。
     */
    public static func create(parameters: Collection<(String, String)>): QueryString {
        let sb = StringBuilder()
        var first = true
        for ((name, value) in parameters) {
            appendKeyValuePair(sb, name, value, first)
            first = false
        }
        return QueryString(sb.toString())
    }

    /**
     * @brief 使用多值参数集合创建查询字符串。
     * @param parameters 查询参数及其多值集合。
     * @return 创建后的查询字符串。
     */
    public static func create(parameters: Collection<(String, StringValues)>): QueryString {
        let sb = StringBuilder()
        var first = true
        for ((name, values) in parameters) {
            if (values.isEmpty()) {
                appendKeyValuePair(sb, name, String.empty, first)
                first = false
                continue
            }
            for (value in values) {
                appendKeyValuePair(sb, name, value, first)
                first = false
            }
        }
        return QueryString(sb.toString())
    }

    /**
     * @brief 将另一个查询字符串追加到当前实例后面。
     * @param other 要追加的查询字符串。
     * @return 追加后的查询字符串。
     */
    public func add(other: QueryString): QueryString {
        if (!hasValue || value == "?") {
            return other
        }
        if (!other.hasValue || other.value == "?") {
            return this
        }
        return QueryString("${value}&${other.value[1..]}")
    }

    /**
     * @brief 向当前查询字符串追加一个键值对。
     * @param name 查询参数名称。
     * @param value 查询参数值。
     * @return 追加后的查询字符串。
     */
    public func add(name: String, value: String): QueryString {
        if (!hasValue || this.value == "?") {
            return QueryString.create(name, value)
        }
        let sb = StringBuilder(this.value)
        appendKeyValuePair(sb, name, value, false)
        return QueryString(sb.toString())
    }

    /**
     * @brief 比较两个查询字符串是否相等。
     * @param that 要比较的查询字符串。
     * @return 如果两个查询字符串相等则返回 true，否则返回 false。
     */
    public operator func ==(that: QueryString): Bool {
        if (!hasValue && !that.hasValue) {
            return true
        }
        return value == that.value
    }

    /**
     * @brief 比较两个查询字符串是否不相等。
     * @param that 要比较的查询字符串。
     * @return 如果两个查询字符串不相等则返回 true，否则返回 false。
     */
    public operator func !=(that: QueryString): Bool {
        return !(this == that)
    }

    /**
     * @brief 比较当前查询字符串与字符串值是否相等。
     * @param that 要比较的字符串值。
     * @return 如果两者相等则返回 true，否则返回 false。
     */
    public operator func ==(that: String): Bool {
        return value == that
    }

    /**
     * @brief 使用加号运算符合并两个查询字符串。
     * @param that 要追加的查询字符串。
     * @return 合并后的查询字符串。
     */
    public operator func +(that: QueryString): QueryString {
        return add(that)
    }

    /**
     * @brief 返回当前查询字符串的哈希值。
     * @return 当前查询字符串的哈希值。
     */
    public func hashCode(): Int64 {
        if (hasValue) { _value.hashCode() } else { 0 }
    }

    /**
     * @brief 返回当前查询字符串的字符串表示。
     * @return 当前查询字符串的字符串表示。
     */
    public func toString(): String {
        toUriComponent()
    }

    private static func appendKeyValuePair(sb: StringBuilder, name: String, value: String, first: Bool): Unit {
        sb.append(if (first) {
            '?'
        } else {
            '&'
        })
        sb.append(HttpUtility.urlEncode(name))
        sb.append('=')
        if (!value.isEmpty()) {
            sb.append(HttpUtility.urlEncode(value))
        }
    }
}

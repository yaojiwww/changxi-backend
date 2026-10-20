// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_http.headers

import std.collection.*

/**
 * @brief 表示 RFC 2616 中定义的各种标头中使用的名称/值对
 */
public class NameValueHeaderValue <: Equatable<NameValueHeaderValue> {
    private var _name: String = ""
    private var _value: String = ""
    private var _isReadOnly: Bool = false

    // 供解析器内部使用的无参构造
    private init() {}

    /**
     * @brief 仅含名称的构造
     * @param name 标头名称。
     */
    public init(name: String) {
        this(name, "")
    }

    /**
     * @brief 名称/值对构造
     * @param name 标头名称。
     * @param value 标头值。
     */
    public init(name: String, value: String) {
        checkNameValueFormat(name, value)
        _name = name
        _value = value
    }

    /**
     * @brief 标头名称（只读）
     * @return 当前名称值对的名称部分。
     */
    public prop name: String {
        get() {
            _name
        }
    }

    /**
     * @brief 标头值（可读写）
     */
    public mut prop value: String {
        get() {
            _value
        }
        set(v) {
            HeaderUtilities.throwIfReadOnly(_isReadOnly)
            checkValueFormat(v)
            _value = v
        }
    }

    /**
     * @brief 是否只读
     * @return 当前实例为只读时返回 `true`。
     */
    public prop isReadOnly: Bool {
        get() {
            _isReadOnly
        }
    }

    /**
     * @brief 浅拷贝
     * @return 当前名称值对的可写副本。
     */
    public func copy(): NameValueHeaderValue {
        let other = NameValueHeaderValue()
        other._name = _name
        other._value = _value
        return other
    }

    /**
     * @brief 只读拷贝
     * @return 当前名称值对的只读副本。
     */
    public func copyAsReadOnly(): NameValueHeaderValue {
        if (_isReadOnly) {
            return this
        }
        let other = NameValueHeaderValue()
        other._name = _name
        other._value = _value
        other._isReadOnly = true
        return other
    }

    /**
     * @brief 若 value 是 quoted-string，去引号并反转义；否则原样返回
     * @return 去引号并反转义后的值，或原始值。
     */
    public func getUnescapedValue(): String {
        if (!HeaderUtilities.isQuoted(_value)) {
            return _value
        }
        return HeaderUtilities.unescapeAsQuotedString(_value)
    }

    /**
     * @brief 将 value 转义为 quoted-string 后设置
     * @param v 待设置的原始值。
     */
    public func setAndEscapeValue(v: String): Unit {
        HeaderUtilities.throwIfReadOnly(_isReadOnly)
        if (v.isEmpty() || getValueLength(v, 0) == v.size) {
            _value = v
        } else {
            value = HeaderUtilities.escapeAsQuotedString(v)
        }
    }

    /**
     * @brief 返回当前名称值对的哈希值。
     * @return 当前名称值对的哈希值。
     */
    public func hashCode(): Int64 {
        var h = _name.toAsciiLower().hashCode()
        if (!_value.isEmpty()) {
            h = if (_value[0] == b'"') {
                h ^ _value.hashCode()
            } else {
                h ^ _value.toAsciiLower().hashCode()
            }
        }
        return h
    }

    /**
     * @brief 比较两个名称值对是否相等。
     * @param other 要比较的名称值对。
     * @return 如果两个名称值对相等则返回 true，否则返回 false。
     */
    public operator func ==(other: NameValueHeaderValue): Bool {
        if (!_name.equalsIgnoreAsciiCase(other._name)) {
            return false
        }
        if (_value.isEmpty()) {
            return other._value.isEmpty()
        }
        if (_value[0] == b'"') {
            return _value == other._value
        }
        return _value.equalsIgnoreAsciiCase(other._value)
    }

    /**
     * @brief 返回当前名称值对的字符串表示。
     * @return 当前名称值对的字符串表示。
     */
    public func toString(): String {
        if (!_value.isEmpty()) {
            return "${_name}=${_value}"
        }
        return _name
    }

    /**
     * @brief 将参数列表序列化追加到 StringBuilder
     */
    static func appendToString(
        values: ?ArrayList<NameValueHeaderValue>,
        separator: String,
        leadingSeparator: Bool,
        sb: StringBuilder
    ): Unit {
        let list = values ?? ArrayList<NameValueHeaderValue>()
        if (list.size == 0) {
            return
        }
        var first = true
        for (item in list) {
            if (leadingSeparator || !first || sb.size > 0) {
                sb.append(separator)
                sb.append(" ")
            }
            sb.append(item._name)
            if (!item._value.isEmpty()) {
                sb.append("=")
                sb.append(item._value)
            }
            first = false
        }
    }

    /**
     * @brief 参数列表 hashCode（无序 XOR）
     */
    static func getHashCode(values: ?ArrayList<NameValueHeaderValue>): Int64 {
        let list = values ?? ArrayList<NameValueHeaderValue>()
        var result: Int64 = 0
        for (item in list) {
            result = result ^ item.hashCode()
        }
        return result
    }

    /**
     * @brief 在集合中按名称查找（大小写不敏感），返回 Option
     * @param values 要搜索的名称值对集合。
     * @param name 要查找的名称。
     * @return 找到时返回匹配项；未找到时返回 `None`。
     */
    public static func find(
        values: ArrayList<NameValueHeaderValue>,
        name: String
    ): ?NameValueHeaderValue {
        for (item in values) {
            if (item._name.equalsIgnoreAsciiCase(name)) {
                return item
            }
        }
        return None
    }

    /**
     * @brief 解析单个 name=value，返回 Option（None 表示解析失败）
     * @param input 待解析的名称值对字符串。
     * @return 解析成功时返回名称值对；失败时返回 `None`。
     */
    public static func parse(input: String): ?NameValueHeaderValue {
        let (result, _) = getNameValueLength(input, 0)
        return result
    }

    /**
     * @brief 解析 name/value 列表（如 "a=b; c=d"），追加到 nameValueCollection，返回消耗长度
     */
    static func getNameValueListLength(
        input: String,
        startIndex: Int64,
        delimiter: Byte,
        nameValueCollection: ArrayList<NameValueHeaderValue>
    ): Int64 {
        if (input.isEmpty() || startIndex >= input.size) {
            return 0
        }
        var current = startIndex + HttpRuleParser.getWhitespaceLength(input, startIndex)
        while (true) {
            let (param, nameValueLength) = getNameValueLength(input, current)
            if (nameValueLength == 0) {
                return current - startIndex
            }
            if (let Some(p) <- param) {
                nameValueCollection.add(p)
            }
            current += nameValueLength
            current += HttpRuleParser.getWhitespaceLength(input, current)
            if (current == input.size || input[current] != delimiter) {
                return current - startIndex
            }
            current++ // skip delimiter
            current += HttpRuleParser.getWhitespaceLength(input, current)
        }
        return current - startIndex
    }

    /**
     * @brief 获取 value 部分的长度（token 或 quoted-string）
     */
    static func getValueLength(input: String, startIndex: Int64): Int64 {
        if (startIndex >= input.size) {
            return 0
        }
        let tokenLen = HttpRuleParser.getTokenLength(input, startIndex)
        if (tokenLen > 0) {
            return tokenLen
        }
        let (qResult, qLen) = HttpRuleParser.getQuotedStringLength(input, startIndex)
        if (qResult == HttpParseResult.Parsed) {
            return qLen
        }
        return 0
    }

    // 解析单个 name[=value]，返回 (Option<NameValueHeaderValue>, 消耗长度)
    private static func getNameValueLength(
        input: String,
        startIndex: Int64
    ): (?NameValueHeaderValue, Int64) {
        if (input.isEmpty() || startIndex >= input.size) {
            return (None, 0)
        }
        let nameLength = HttpRuleParser.getTokenLength(input, startIndex)
        if (nameLength == 0) {
            return (None, 0)
        }
        let name = input[startIndex..startIndex + nameLength]
        var current = startIndex + nameLength
        current += HttpRuleParser.getWhitespaceLength(input, current)
        // 仅有名称，无 '='
        if (current == input.size || input[current] != b'=') {
            let nv = NameValueHeaderValue()
            nv._name = name
            return (nv, current - startIndex)
        }
        current++ // skip '='
        current += HttpRuleParser.getWhitespaceLength(input, current)
        let valueLength = getValueLength(input, current)
        let nv = NameValueHeaderValue()
        nv._name = name
        nv._value = input[current..current + valueLength]
        current += valueLength
        current += HttpRuleParser.getWhitespaceLength(input, current)
        return (nv, current - startIndex)
    }

    private static func checkNameValueFormat(name: String, value: String): Unit {
        HeaderUtilities.checkValidToken(name, "name")
        checkValueFormat(value)
    }

    private static func checkValueFormat(value: String): Unit {
        if (!value.isEmpty() && getValueLength(value, 0) != value.size) {
            throw IllegalArgumentException("The header value is invalid: '${value}'")
        }
    }
}

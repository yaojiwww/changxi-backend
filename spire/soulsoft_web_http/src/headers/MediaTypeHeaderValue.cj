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
 * @brief 表示媒体类型标头。参见 https://tools.ietf.org/html/rfc6838
 */
public class MediaTypeHeaderValue {
    private static let boundaryString = "boundary"
    private static let charsetString = "charset"
    private static let matchesAllString = "*/*"
    private static let qualityString = "q"
    private static let wildcardString = "*"

    private var _parameters: ?ArrayList<NameValueHeaderValue> = None
    private var _mediaType: String = ""
    private var _isReadOnly: Bool = false

    // 供解析器内部使用的无参构造
    private init() {}

    /**
     * @brief 仅含 mediaType 的构造（如 "application/json"）
     * @param mediaType 媒体类型字符串。
     */
    public init(mediaType: String) {
        checkMediaTypeFormat(mediaType)
        _mediaType = mediaType
    }

    /**
     * @brief 含 mediaType 和 quality 的构造
     * @param mediaType 媒体类型字符串。
     * @param quality 质量因子。
     */
    public init(mediaType: String, quality: Float64) {
        this(mediaType)
        this.quality = quality
    }

    /**
     * @brief charset 参数值（空串表示不存在）
     */
    public mut prop charset: String {
        get() {
            match (_parameters) {
                case Some(params) => NameValueHeaderValue.find(params, charsetString)?.value ?? ""
                case None => ""
            }
        }
        set(v) {
            HeaderUtilities.throwIfReadOnly(_isReadOnly)
            let charsetParam = _parameters.flatMap {p => NameValueHeaderValue.find(p, charsetString)}
            if (v.isEmpty()) {
                if (let Some(p) <- charsetParam) {
                    parameters.removeIf {x => x == p}
                }
            } else {
                match (charsetParam) {
                    case Some(p) => p.value = v
                    case None => parameters.add(NameValueHeaderValue(charsetString, v))
                }
            }
        }
    }

    /**
     * @brief boundary 参数值（空串表示不存在）
     */
    public mut prop boundary: String {
        get() {
            match (_parameters) {
                case Some(params) => NameValueHeaderValue.find(params, boundaryString)?.value ?? ""
                case None => ""
            }
        }
        set(v) {
            HeaderUtilities.throwIfReadOnly(_isReadOnly)
            let boundaryParam = _parameters.flatMap {p => NameValueHeaderValue.find(p, boundaryString)}
            if (v.isEmpty()) {
                if (let Some(p) <- boundaryParam) {
                    parameters.removeIf {x => x == p}
                }
            } else {
                match (boundaryParam) {
                    case Some(p) => p.value = v
                    case None => parameters.add(NameValueHeaderValue(boundaryString, v))
                }
            }
        }
    }

    /**
     * @brief 参数列表（懒初始化）
     * @return 当前媒体类型附带的参数列表。
     */
    public prop parameters: ArrayList<NameValueHeaderValue> {
        get() {
            match (_parameters) {
                case Some(p) => p
                case None =>
                    let list = ArrayList<NameValueHeaderValue>()
                    _parameters = list
                    list
            }
        }
    }

    /**
     * @brief quality 参数值（None 表示不存在）
     */
    public mut prop quality: ?Float64 {
        get() {
            HeaderUtilities.getQuality(_parameters)
        }
        set(v) {
            HeaderUtilities.throwIfReadOnly(_isReadOnly)
            HeaderUtilities.setQuality(parameters, v)
        }
    }

    /**
     * @brief 完整媒体类型字符串（如 "application/json"）
     */
    public mut prop mediaType: String {
        get() {
            _mediaType
        }
        set(v) {
            HeaderUtilities.throwIfReadOnly(_isReadOnly)
            checkMediaTypeFormat(v)
            _mediaType = v
        }
    }

    /**
     * @brief 主类型（如 "application"）
     * @return 当前媒体类型的主类型部分。
     */
    public prop type_: String {
        get() {
            match (_mediaType.indexOf(b'/')) {
                case Some(idx) => _mediaType[0..idx]
                case None => _mediaType
            }
        }
    }

    /**
     * @brief 子类型（如 "vnd.example+json"）
     * @return 当前媒体类型的子类型部分。
     */
    public prop subType: String {
        get() {
            match (_mediaType.indexOf(b'/')) {
                case Some(idx) => _mediaType[idx + 1..]
                case None => ""
            }
        }
    }

    /**
     * @brief 不含结构化语法后缀的子类型（如 "vnd.example"）
     * @return 去除结构化语法后缀后的子类型。
     */
    public prop subTypeWithoutSuffix: String {
        get() {
            let st = subType
            match (st.lastIndexOf(b'+')) {
                case Some(idx) => st[0..idx]
                case None => st
            }
        }
    }

    /**
     * @brief 结构化语法后缀（如 "json"），不存在时返回空串
     * @return 当前子类型的结构化语法后缀；不存在时返回空串。
     */
    public prop suffix: String {
        get() {
            let st = subType
            match (st.lastIndexOf(b'+')) {
                case Some(idx) => st[idx + 1..]
                case None => ""
            }
        }
    }

    /**
     * @brief facets：subTypeWithoutSuffix 按 '.' 分割的列表
     * @return 按 `.` 分割后的子类型片段数组。
     */
    public prop facets: Array<String> {
        get() {
            subTypeWithoutSuffix.split(".")
        }
    }

    /**
     * @brief 是否匹配所有类型（即星号斜杠星号通配媒体类型）
     * @return 当前媒体类型为全类型通配符时返回 `true`。
     */
    public prop matchesAllTypes: Bool {
        get() {
            _mediaType == matchesAllString
        }
    }

    /**
     * @brief 是否匹配所有子类型（subType == *）
     * @return 子类型为 `*` 时返回 `true`。
     */
    public prop matchesAllSubTypes: Bool {
        get() {
            subType == wildcardString
        }
    }

    /**
     * @brief 是否匹配所有不含后缀的子类型
     * @return 不含后缀的子类型为 `*` 时返回 `true`。
     */
    public prop matchesAllSubTypesWithoutSuffix: Bool {
        get() {
            subTypeWithoutSuffix.equalsIgnoreAsciiCase(wildcardString)
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
     * @brief 判断 otherMediaType 字符串（仅 type/subtype，忽略参数）是否与本实例匹配
     * 对应 C# MatchesMediaType(StringSegment)
     * @param otherMediaType 待比较的媒体类型字符串。
     * @return 与当前媒体类型匹配时返回 `true`。
     */
    public func matchesMediaType(otherMediaType: String): Bool {
        if (otherMediaType.isEmpty()) {
            return false
        }
        let (mediaType, length) = getMediaTypeExpressionLength(otherMediaType, 0)
        if (length == 0) {
            return false
        }
        let other = MediaTypeHeaderValue()
        other._mediaType = mediaType
        return matchesType(other) && matchesSubtype(other)
    }

    /**
     * @brief 判断 this 是否是 otherMediaType 的子集
     * @param other 用于比较的媒体类型。
     * @return 当前媒体类型是目标媒体类型子集时返回 `true`。
     */
    public func isSubsetOf(other: MediaTypeHeaderValue): Bool {
        return matchesType(other) && matchesSubtype(other) && matchesParameters(other)
    }

    /**
     * @brief 深拷贝
     * @return 当前媒体类型的可写副本。
     */
    public func copy(): MediaTypeHeaderValue {
        let other = MediaTypeHeaderValue()
        other._mediaType = _mediaType
        if (let Some(params) <- _parameters) {
            let list = ArrayList<NameValueHeaderValue>()
            for (item in params) {
                list.add(item.copy())
            }
            other._parameters = list
        }
        return other
    }

    /**
     * @brief 只读深拷贝
     * @return 当前媒体类型的只读副本。
     */
    public func copyAsReadOnly(): MediaTypeHeaderValue {
        if (_isReadOnly) {
            return this
        }
        let other = MediaTypeHeaderValue()
        other._mediaType = _mediaType
        if (let Some(params) <- _parameters) {
            let list = ArrayList<NameValueHeaderValue>()
            for (item in params) {
                list.add(item.copyAsReadOnly())
            }
            other._parameters = list
        }
        other._isReadOnly = true
        return other
    }

    /**
     * @brief 返回当前媒体类型标头的字符串表示。
     * @return 当前媒体类型标头的字符串表示。
     */
    public func toString(): String {
        let sb = StringBuilder()
        sb.append(_mediaType)
        NameValueHeaderValue.appendToString(_parameters, ";", true, sb)
        return sb.toString()
    }

    /**
     * @brief 比较两个媒体类型标头是否相等。
     * @param other 要比较的媒体类型标头。
     * @return 如果两个媒体类型标头相等则返回 true，否则返回 false。
     */
    public operator func ==(other: MediaTypeHeaderValue): Bool {
        return _mediaType.equalsIgnoreAsciiCase(other._mediaType) && HeaderUtilities.areEqualCollections(_parameters,
            other._parameters)
    }

    /**
     * @brief 返回当前媒体类型标头的哈希值。
     * @return 当前媒体类型标头的哈希值。
     */
    public func hashCode(): Int64 {
        return _mediaType.toAsciiLower().hashCode() ^ NameValueHeaderValue.getHashCode(_parameters)
    }

    /**
     * @brief 解析媒体类型字符串，返回 Option（None 表示格式无效）
     * 要求整个字符串（含尾部空白）均被合法解析，否则返回 None
     * @param input 待解析的媒体类型字符串。
     * @return 解析成功时返回媒体类型标头值；失败时返回 `None`。
     */
    public static func parse(input: String): ?MediaTypeHeaderValue {
        let (length, result) = getMediaTypeLength(input, 0)
        if (length == 0) {
            return None
        }
        // 验证尾部仅剩空白，确保整串被完整消耗
        let trailing = length + HttpRuleParser.getWhitespaceLength(input, length)
        if (trailing != input.size) {
            return None
        }
        return result
    }

    // 解析 "type/subtype[; params]"，返回 (消耗长度, 解析结果)
    // 长度为 0 表示格式无效；签名与 GenericHeaderParser<T> 委托兼容
    static func getMediaTypeLength(input: String, startIndex: Int64): (Int64, ?MediaTypeHeaderValue) {
        if (input.isEmpty() || startIndex >= input.size) {
            return (0, None)
        }
        let (mediaType, mediaTypeLength) = getMediaTypeExpressionLength(input, startIndex)
        if (mediaTypeLength == 0) {
            return (0, None)
        }
        var current = startIndex + mediaTypeLength
        current += HttpRuleParser.getWhitespaceLength(input, current)
        let header = MediaTypeHeaderValue()
        header._mediaType = mediaType
        if (current < input.size && input[current] == b';') {
            current++ // skip ';'
            let paramLength = NameValueHeaderValue.getNameValueListLength(input, current, b';', header.parameters)
            current += paramLength
        }
        return (current - startIndex, header)
    }

    // 解析 "type/subtype"，返回 (mediaType字符串, 消耗长度)
    private static func getMediaTypeExpressionLength(input: String, startIndex: Int64): (String, Int64) {
        let typeLength = HttpRuleParser.getTokenLength(input, startIndex)
        if (typeLength == 0) {
            return ("", 0)
        }
        var current = startIndex + typeLength
        current += HttpRuleParser.getWhitespaceLength(input, current)
        if (current >= input.size || input[current] != b'/') {
            return ("", 0)
        }
        current++ // skip '/'
        current += HttpRuleParser.getWhitespaceLength(input, current)
        let subtypeLength = HttpRuleParser.getTokenLength(input, current)
        if (subtypeLength == 0) {
            return ("", 0)
        }
        let mediaTypeLength = current + subtypeLength - startIndex
        // 若 type/subtype 之间无空白，直接切片；否则拼接
        let mediaType = if (typeLength + subtypeLength + 1 == mediaTypeLength) {
            input[startIndex..startIndex + mediaTypeLength]
        } else {
            input[startIndex..startIndex + typeLength] + "/" + input[current..current + subtypeLength]
        }
        return (mediaType, mediaTypeLength)
    }

    private static func checkMediaTypeFormat(mediaType: String): Unit {
        if (mediaType.isEmpty()) {
            throw IllegalArgumentException("An empty string is not allowed.")
        }
        let (_, length) = getMediaTypeExpressionLength(mediaType, 0)
        if (length == 0 || length != mediaType.size) {
            throw Exception("Invalid media type '${mediaType}'.")
        }
    }

    private func matchesType(other: MediaTypeHeaderValue): Bool {
        return other.matchesAllTypes || other.type_.equalsIgnoreAsciiCase(type_)
    }

    private func matchesSubtype(other: MediaTypeHeaderValue): Bool {
        if (other.matchesAllSubTypes) {
            return true
        }
        if (!other.suffix.isEmpty()) {
            if (!suffix.isEmpty()) {
                return matchesSubtypeWithoutSuffix(other) && matchesSubtypeSuffix(other)
            }
            return false
        }
        return matchesEitherSubtypeOrSuffix(other)
    }

    private func matchesSubtypeWithoutSuffix(other: MediaTypeHeaderValue): Bool {
        return other.matchesAllSubTypesWithoutSuffix || other
            .subTypeWithoutSuffix
            .equalsIgnoreAsciiCase(subTypeWithoutSuffix)
    }

    private func matchesEitherSubtypeOrSuffix(other: MediaTypeHeaderValue): Bool {
        return other.subType.equalsIgnoreAsciiCase(subType) || other.subType.equalsIgnoreAsciiCase(suffix)
    }

    private func matchesSubtypeSuffix(other: MediaTypeHeaderValue): Bool {
        return other.suffix.equalsIgnoreAsciiCase(suffix)
    }

    private func matchesParameters(other: MediaTypeHeaderValue): Bool {
        let otherParams = other._parameters ?? ArrayList<NameValueHeaderValue>()
        if (otherParams.size == 0) {
            return true
        }
        for (param in otherParams) {
            if (param.name.equalsIgnoreAsciiCase(wildcardString)) {
                continue
            }
            if (param.name.equalsIgnoreAsciiCase(qualityString)) {
                break
            }
            let localParam = NameValueHeaderValue.find(_parameters ?? ArrayList<NameValueHeaderValue>(), param.name)
            match (localParam) {
                case None => return false
                case Some(lp) =>
                    if (!param.value.equalsIgnoreAsciiCase(lp.value)) {
                        return false
                    }
            }
        }
        return true
    }
}

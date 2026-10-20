// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_http.headers

/**
 * @brief 表示 HTTP Content-Range 响应标头值（RFC 7233）
 *
 * 支持三种形式：
 * - `bytes 12-34/5678`：带范围和总长度
 * - `bytes star/1234`：未知范围，仅总长度
 * - `bytes 12-34/star`：带范围，未知总长度
 */
public class ContentRangeHeaderValue <: Equatable<ContentRangeHeaderValue> {
    private static let parser: GenericHeaderParser<ContentRangeHeaderValue> = GenericHeaderParser<ContentRangeHeaderValue>(
        false, getContentRangeLength)

    private var _unit: String = HeaderUtilities.bytesUnit
    private var _from: ?Int64 = None
    private var _to: ?Int64 = None
    private var _length: ?Int64 = None

    private init() {}

    /**
     * @brief 构造带范围和总长度的 Content-Range（"bytes from-to/length"）
     * - length 必须非负；to 必须非负且严格小于 length；from 必须非负且不大于 to
     * @param from 范围起始位置。
     * @param to 范围结束位置。
     * @param length 资源总长度。
     */
    public init(from: Int64, to: Int64, length: Int64) {
        if (length < 0) {
            throw IllegalArgumentException("length must be non-negative.")
        }
        if (to < 0 || length <= to) {
            throw IllegalArgumentException("to must be non-negative and less than length.")
        }
        if (from < 0 || from > to) {
            throw IllegalArgumentException("from must be non-negative and not greater than to.")
        }
        _from = from
        _to = to
        _length = length
        _unit = HeaderUtilities.bytesUnit
    }

    /**
     * @brief 构造仅含总长度的 Content-Range（形如 `bytes star/length`）
     * @param length 资源总长度。
     */
    public init(length: Int64) {
        if (length < 0) {
            throw IllegalArgumentException("length must be non-negative.")
        }
        _length = length
        _unit = HeaderUtilities.bytesUnit
    }

    /**
     * @brief 构造带范围但总长度未知的 Content-Range（形如 `bytes from-to/star`）
     * @param from 范围起始位置。
     * @param to 范围结束位置。
     */
    public init(from: Int64, to: Int64) {
        if (to < 0) {
            throw IllegalArgumentException("to must be non-negative.")
        }
        if (from < 0 || from > to) {
            throw IllegalArgumentException("from must be non-negative and not greater than to.")
        }
        _from = from
        _to = to
        _unit = HeaderUtilities.bytesUnit
    }

    /**
     * @brief 范围单位（默认 "bytes"）
     */
    public mut prop unit: String {
        get() {
            _unit
        }
        set(v) {
            HeaderUtilities.checkValidToken(v, "unit")
            _unit = v
        }
    }

    /**
     * @brief 范围起始（None 表示 *）
     * @return 当前范围起始位置；未指定时返回 `None`。
     */
    public prop from: ?Int64 {
        get() {
            _from
        }
    }

    /**
     * @brief 范围结束（None 表示 *）
     * @return 当前范围结束位置；未指定时返回 `None`。
     */
    public prop to: ?Int64 {
        get() {
            _to
        }
    }

    /**
     * @brief 总长度（None 表示 *）
     * @return 当前资源总长度；未知时返回 `None`。
     */
    public prop length: ?Int64 {
        get() {
            _length
        }
    }

    /**
     * @brief 是否有总长度
     * @return 包含总长度时返回 `true`。
     */
    public prop hasLength: Bool {
        get() {
            _length.isSome()
        }
    }

    /**
     * @brief 是否有具体范围（from 和 to 均存在）
     * @return 同时包含起止位置时返回 `true`。
     */
    public prop hasRange: Bool {
        get() {
            _from.isSome() && _to.isSome()
        }
    }

    /**
     * @brief 序列化为字符串，如 `bytes 0-499/1234`、`bytes star/1234` 或 `bytes 0-499/star`
     * @return 当前 Content-Range 标头的字符串表示。
     */
    public func toString(): String {
        let sb = StringBuilder()
        sb.append(_unit)
        sb.append(" ")
        if (hasRange) {
            sb.append("${_from.getOrThrow()}-${_to.getOrThrow()}")
        } else {
            sb.append("*")
        }
        sb.append("/")
        if (hasLength) {
            sb.append("${_length.getOrThrow()}")
        } else {
            sb.append("*")
        }
        return sb.toString()
    }

    /**
     * @brief 比较两个 Content-Range 标头值是否相等。
     * @param other 要比较的 Content-Range 标头值。
     * @return 如果两个 Content-Range 标头值相等则返回 true，否则返回 false。
     */
    public operator func ==(other: ContentRangeHeaderValue): Bool {
        _from == other._from && _to == other._to && _length == other._length && _unit.equalsIgnoreAsciiCase(other._unit)
    }

    /**
     * @brief 返回当前 Content-Range 标头值的哈希值。
     * @return 当前 Content-Range 标头值的哈希值。
     */
    public func hashCode(): Int64 {
        var result = _unit.toAsciiLower().hashCode()
        if (let Some(f) <- _from) {
            result ^= f
        }
        if (let Some(t) <- _to) {
            result ^= t
        }
        if (let Some(l) <- _length) {
            result ^= l
        }
        return result
    }

    /**
     * @brief 解析 Content-Range 字符串，格式非法时抛出异常
     * @param input 待解析的 Content-Range 字符串。
     * @return 解析得到的 Content-Range 标头值。
     */
    public static func parse(input: String): ContentRangeHeaderValue {
        let (ok, result, _) = parser.tryParseValue(input, 0)
        if (!ok) {
            throw Exception("Invalid Content-Range header value: '${input}'")
        }
        match (result) {
            case Some(v) => return v
            case None => throw Exception("Invalid Content-Range header value: '${input}'")
        }
    }

    /**
     * @brief 尝试解析 Content-Range 字符串，返回 None 表示格式无效
     * @param input 待解析的 Content-Range 字符串。
     * @return 解析成功时返回标头值；失败时返回 `None`。
     */
    public static func tryParse(input: String): ?ContentRangeHeaderValue {
        let (ok, result, _) = parser.tryParseValue(input, 0)
        if (!ok) {
            return None
        }
        return result
    }

    // 解析 "<unit> (<from>-<to> | *)/(<length> | *)"
    private static func getContentRangeLength(input: String, startIndex: Int64): (Int64, ?ContentRangeHeaderValue) {
        if (input.isEmpty() || startIndex >= input.size) {
            return (0, None)
        }

        // 解析 unit token
        let unitLength = HttpRuleParser.getTokenLength(input, startIndex)
        if (unitLength == 0) {
            return (0, None)
        }
        let unit = input[startIndex..startIndex + unitLength]
        var current = startIndex + unitLength

        // unit 与范围之间必须有空白
        let sepLen = HttpRuleParser.getWhitespaceLength(input, current)
        if (sepLen == 0) {
            return (0, None)
        }
        current += sepLen

        if (current == input.size) {
            return (0, None)
        }

        // 解析范围部分："*" 或 "from-to"
        var fromStartIndex: Int64 = 0
        var fromLength: Int64 = 0
        var toStartIndex: Int64 = 0
        var toLength: Int64 = 0

        if (input[current] == b'*') {
            current++
        } else {
            // 解析 from
            fromStartIndex = current
            fromLength = HttpRuleParser.getNumberLength(input, current, false)
            if (fromLength == 0 || fromLength > HttpRuleParser.MaxInt64Digits) {
                return (0, None)
            }
            current += fromLength
            current += HttpRuleParser.getWhitespaceLength(input, current)

            // 必须有 '-'
            if (current == input.size || input[current] != b'-') {
                return (0, None)
            }
            current++ // skip '-'
            current += HttpRuleParser.getWhitespaceLength(input, current)

            if (current == input.size) {
                return (0, None)
            }

            // 解析 to
            toStartIndex = current
            toLength = HttpRuleParser.getNumberLength(input, current, false)
            if (toLength == 0 || toLength > HttpRuleParser.MaxInt64Digits) {
                return (0, None)
            }
            current += toLength
        }
        current += HttpRuleParser.getWhitespaceLength(input, current)

        // 必须有 '/'
        if (current == input.size || input[current] != b'/') {
            return (0, None)
        }
        current++ // skip '/'
        current += HttpRuleParser.getWhitespaceLength(input, current)

        if (current == input.size) {
            return (0, None)
        }

        // 解析 length 部分："*" 或数字
        var lengthStartIndex: Int64 = 0
        var lengthLength: Int64 = 0

        if (input[current] == b'*') {
            current++
        } else {
            lengthStartIndex = current
            lengthLength = HttpRuleParser.getNumberLength(input, current, false)
            if (lengthLength == 0 || lengthLength > HttpRuleParser.MaxInt64Digits) {
                return (0, None)
            }
            current += lengthLength
        }
        current += HttpRuleParser.getWhitespaceLength(input, current)

        // 数值转换
        var from: Int64 = 0
        if (fromLength > 0) {
            match (HeaderUtilities.tryParseNonNegativeInt64(input[fromStartIndex..fromStartIndex + fromLength])) {
                case Some(v) => from = v
                case None => return (0, None)
            }
        }

        var to: Int64 = 0
        if (toLength > 0) {
            match (HeaderUtilities.tryParseNonNegativeInt64(input[toStartIndex..toStartIndex + toLength])) {
                case Some(v) => to = v
                case None => return (0, None)
            }
        }

        // from 不得大于 to
        if (fromLength > 0 && toLength > 0 && from > to) {
            return (0, None)
        }

        var length: Int64 = 0
        if (lengthLength > 0) {
            match (HeaderUtilities.tryParseNonNegativeInt64(input[lengthStartIndex..lengthStartIndex + lengthLength])) {
                case Some(v) => length = v
                case None => return (0, None)
            }
        }

        // to 必须严格小于 length（RFC 7233 §4.2 规定）
        if (toLength > 0 && lengthLength > 0 && to >= length) {
            return (0, None)
        }

        let result = ContentRangeHeaderValue()
        result._unit = unit
        if (fromLength > 0) {
            result._from = from
            result._to = to
        }
        if (lengthLength > 0) {
            result._length = length
        }

        return (current - startIndex, result)
    }
}

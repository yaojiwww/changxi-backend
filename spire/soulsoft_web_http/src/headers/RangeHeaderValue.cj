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
 * @brief 表示 HTTP Range 请求标头值（RFC 7233）
 *
 * 格式：`<unit>=<from1>-<to1>[, <from2>-<to2>...]`
 * 示例：`bytes=0-499`、`bytes=500-999, 1500-`
 */
public class RangeHeaderValue <: Equatable<RangeHeaderValue> {
    private static let parser: GenericHeaderParser<RangeHeaderValue> =
        GenericHeaderParser<RangeHeaderValue>(false, getRangeLength)

    private var _unit: String = HeaderUtilities.bytesUnit
    private var _ranges: ?ArrayList<RangeItemHeaderValue> = None

    /**
     * @brief 构造默认 Range 标头（unit = "bytes"，无范围项，需手动添加）
     */
    public init() {
        _unit = HeaderUtilities.bytesUnit
    }

    /**
     * @brief 构造包含单个范围的 Range 标头（unit = "bytes"）
     * @param from 范围起始位置。
     * @param to 范围结束位置。
     */
    public init(from: ?Int64, to: ?Int64) {
        _unit = HeaderUtilities.bytesUnit
        ranges.add(RangeItemHeaderValue(from, to))
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
     * @brief 范围项列表（懒初始化）
     * @return 当前 Range 标头包含的范围项列表。
     */
    public prop ranges: ArrayList<RangeItemHeaderValue> {
        get() {
            match (_ranges) {
                case Some(r) => r
                case None =>
                    let list = ArrayList<RangeItemHeaderValue>()
                    _ranges = list
                    list
            }
        }
    }

    /**
     * @brief 序列化为字符串，如 "bytes=0-499" 或 "bytes=0-499, 1000-1499"
     * @return 当前 Range 标头的字符串表示。
     */
    public func toString(): String {
        let sb = StringBuilder()
        sb.append(_unit)
        sb.append("=")
        var first = true
        for (range in ranges) {
            if (first) {
                first = false
            } else {
                sb.append(", ")
            }
            sb.append(range.toString())
        }
        return sb.toString()
    }

    /**
     * @brief 比较两个 Range 标头值是否相等。
     * @param other 要比较的 Range 标头值。
     * @return 如果两个 Range 标头值相等则返回 true，否则返回 false。
     */
    public operator func ==(other: RangeHeaderValue): Bool {
        if (!_unit.equalsIgnoreAsciiCase(other._unit)) {
            return false
        }
        let xList = _ranges ?? ArrayList<RangeItemHeaderValue>()
        let yList = other._ranges ?? ArrayList<RangeItemHeaderValue>()
        if (xList.size != yList.size) {
            return false
        }
        for (i in 0..xList.size) {
            if (!(xList[i] == yList[i])) {
                return false
            }
        }
        return true
    }

    /**
     * @brief 返回当前 Range 标头值的哈希值。
     * @return 当前 Range 标头值的哈希值。
     */
    public func hashCode(): Int64 {
        var result = _unit.toAsciiLower().hashCode()
        if (let Some(r) <- _ranges) {
            for (range in r) {
                result ^= range.hashCode()
            }
        }
        return result
    }

    /**
     * @brief 解析 Range 标头字符串，格式非法时抛出异常
     * @param input 待解析的 Range 标头字符串。
     * @return 解析得到的 Range 标头值。
     */
    public static func parse(input: String): RangeHeaderValue {
        let (ok, result, _) = parser.tryParseValue(input, 0)
        if (!ok) {
            throw Exception("Invalid Range header value: '${input}'")
        }
        match (result) {
            case Some(v) => return v
            case None => throw Exception("Invalid Range header value: '${input}'")
        }
    }

    /**
     * @brief 尝试解析 Range 标头字符串，返回 None 表示格式无效
     * @param input 待解析的 Range 标头字符串。
     * @return 解析成功时返回 Range 标头值；失败时返回 `None`。
     */
    public static func tryParse(input: String): ?RangeHeaderValue {
        let (ok, result, _) = parser.tryParseValue(input, 0)
        if (!ok) {
            return None
        }
        return result
    }

    // 解析 "<unit>=<ranges>" 格式
    static func getRangeLength(input: String, startIndex: Int64): (Int64, ?RangeHeaderValue) {
        if (input.isEmpty() || startIndex >= input.size) {
            return (0, None)
        }

        // 解析 unit token
        let unitLength = HttpRuleParser.getTokenLength(input, startIndex)
        if (unitLength == 0) {
            return (0, None)
        }

        let result = RangeHeaderValue()
        result._unit = input[startIndex..startIndex + unitLength]
        var current = startIndex + unitLength
        current += HttpRuleParser.getWhitespaceLength(input, current)

        // 必须有 '='
        if (current == input.size || input[current] != b'=') {
            return (0, None)
        }
        current++ // skip '='
        current += HttpRuleParser.getWhitespaceLength(input, current)

        // 解析范围列表
        let rangesLength = RangeItemHeaderValue.getRangeItemListLength(input, current, result.ranges)
        if (rangesLength == 0) {
            return (0, None)
        }

        current += rangesLength
        return (current - startIndex, result)
    }
}

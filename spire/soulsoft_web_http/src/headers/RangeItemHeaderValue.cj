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
 * @brief 表示 Range 标头中的单个字节范围项（RFC 7233）
 *
 * 支持三种形式：
 * - `from-to`：从 from 到 to（含）
 * - `from-`：从 from 到末尾
 * - `-to`：末尾 to 个字节
 */
public class RangeItemHeaderValue <: Equatable<RangeItemHeaderValue> {
    private let _from: ?Int64
    private let _to: ?Int64

    /**
     * @brief 构造字节范围项
     * - from 和 to 不能同时为 None
     * - from 和 to 如存在则必须非负
     * - 如二者均存在，from 不得大于 to
     * @param from 范围起始位置。
     * @param to 范围结束位置。
     */
    public init(from: ?Int64, to: ?Int64) {
        if (from.isNone() && to.isNone()) {
            throw IllegalArgumentException("from and to cannot both be None.")
        }
        if (let Some(f) <- from) {
            if (f < 0) {
                throw IllegalArgumentException("from must be non-negative.")
            }
        }
        if (let Some(t) <- to) {
            if (t < 0) {
                throw IllegalArgumentException("to must be non-negative.")
            }
        }
        if (let Some(f) <- from) {
            if (let Some(t) <- to) {
                if (f > t) {
                    throw IllegalArgumentException("from must not be greater than to.")
                }
            }
        }
        _from = from
        _to = to
    }

    /**
     * @brief 范围起始位置（None 表示末尾相对范围）
     * @return 当前范围起始位置；未指定时返回 `None`。
     */
    public prop from: ?Int64 {
        get() {
            _from
        }
    }

    /**
     * @brief 范围结束位置（None 表示到末尾）
     * @return 当前范围结束位置；未指定时返回 `None`。
     */
    public prop to: ?Int64 {
        get() {
            _to
        }
    }

    /**
     * @brief 序列化为字符串，如 "1-2"、"0-"、"-500"
     * @return 当前范围项的字符串表示。
     */
    public func toString(): String {
        match ((_from, _to)) {
            case (None, Some(t)) => "-${t}"
            case (Some(f), None) => "${f}-"
            case (Some(f), Some(t)) => "${f}-${t}"
            case _ => ""
        }
    }

    /**
     * @brief 比较两个 Range 范围项是否相等。
     * @param other 要比较的范围项。
     * @return 如果两个范围项相等则返回 true，否则返回 false。
     */
    public operator func ==(other: RangeItemHeaderValue): Bool {
        _from == other._from && _to == other._to
    }

    /**
     * @brief 返回当前 Range 范围项的哈希值。
     * @return 当前 Range 范围项的哈希值。
     */
    public func hashCode(): Int64 {
        let f = match (_from) {
            case Some(v) => v
            case None => 0
        }
        let t = match (_to) {
            case Some(v) => v
            case None => 0
        }
        return f ^ t
    }

    // ── 内部解析 API（供 RangeHeaderValue 使用）────────────────────────────

    /**
     * @brief 解析逗号分隔的范围项列表，返回消耗长度（0 表示失败）
     * 成功项追加到 rangeCollection
     */
    protected static func getRangeItemListLength(
        input: String,
        startIndex: Int64,
        rangeCollection: ArrayList<RangeItemHeaderValue>
    ): Int64 {
        if (input.isEmpty() || startIndex >= input.size) {
            return 0
        }

        // 跳过前导空白和空分隔符
        let (idx0, _) = HeaderUtilities.getNextNonEmptyOrWhitespaceIndex(input, startIndex, true)
        var current = idx0
        if (current == input.size) {
            return 0
        }

        while (true) {
            let (rangeLength, range) = getRangeItemLength(input, current)
            if (rangeLength == 0) {
                return 0
            }
            if (let Some(r) <- range) {
                rangeCollection.add(r)
            }
            current += rangeLength
            let (nextIdx, separatorFound) = HeaderUtilities.getNextNonEmptyOrWhitespaceIndex(input, current, true)
            current = nextIdx

            if (current == input.size) {
                return current - startIndex
            }
            if (!separatorFound) {
                // 剩余内容但无逗号分隔符，格式非法
                return 0
            }
            // separatorFound && current < input.size：继续解析下一项
        }
        // 不可达，满足编译器需求
        return 0
    }

    /**
     * @brief 解析单个范围项，返回 (消耗长度, 解析结果)；长度 0 表示失败
     * 调用方负责去除前导空白
     */
    protected static func getRangeItemLength(input: String, startIndex: Int64): (Int64, ?RangeItemHeaderValue) {
        if (input.isEmpty() || startIndex >= input.size) {
            return (0, None)
        }

        var current = startIndex

        // 解析 from 数字
        let fromStartIndex = current
        let fromLength = HttpRuleParser.getNumberLength(input, current, false)
        if (fromLength > HttpRuleParser.MaxInt64Digits) {
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

        let toStartIndex = current
        var toLength: Int64 = 0
        if (current < input.size) {
            toLength = HttpRuleParser.getNumberLength(input, current, false)
            if (toLength > HttpRuleParser.MaxInt64Digits) {
                return (0, None)
            }
            current += toLength
            current += HttpRuleParser.getWhitespaceLength(input, current)
        }

        // from 和 to 至少有一个
        if (fromLength == 0 && toLength == 0) {
            return (0, None)
        }

        // 解析数值
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

        let fromOpt: ?Int64 = if (fromLength == 0) {
            None
        } else {
            from
        }
        let toOpt: ?Int64 = if (toLength == 0) {
            None
        } else {
            to
        }

        return (current - startIndex, RangeItemHeaderValue(fromOpt, toOpt))
    }
}

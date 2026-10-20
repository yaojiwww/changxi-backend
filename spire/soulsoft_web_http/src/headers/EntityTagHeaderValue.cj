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
 * @brief 表示 HTTP ETag 标头值（RFC 7232 §2.3）
 *
 * 支持：
 * - 强 ETag：`"abc123"`
 * - 弱 ETag：`W/"abc123"`
 * - 通配符：`*`（仅在 If-Match / If-None-Match 中使用）
 */
public class EntityTagHeaderValue <: Equatable<EntityTagHeaderValue> {
    // 单值解析器（不支持逗号分隔）
    private static let singleValueParser: GenericHeaderParser<EntityTagHeaderValue> = GenericHeaderParser<EntityTagHeaderValue>(
        false, getEntityTagLength)
    // 多值解析器（支持逗号分隔，用于 If-Match / If-None-Match）
    private static let multipleValueParser: GenericHeaderParser<EntityTagHeaderValue> = GenericHeaderParser<EntityTagHeaderValue>(
        true, getEntityTagLength)

    private var _tag: String = ""
    private var _isWeak: Bool = false

    // 供解析器内部使用的无参构造（不做格式校验）
    private init() {}

    /**
     * @brief 构造强 ETag（isWeak = false）
     * tag 必须是 quoted-string（如 `"abc"`）或通配符 `*`
     * @param tag ETag 标签值。
     */
    public init(tag: String) {
        this(tag, false)
    }

    /**
     * @brief 构造 ETag
     * tag 必须是 quoted-string（如 `"abc"`）；若 isWeak=false 则也接受通配符 `*`
     * 注意：弱 ETag 不允许 `*`（RFC 7232 §2.3）
     * @param tag ETag 标签值。
     * @param isWeak 是否构造为弱 ETag。
     */
    public init(tag: String, isWeak: Bool) {
        if (tag.isEmpty()) {
            throw IllegalArgumentException("An empty string is not allowed.")
        }
        if (!isWeak && tag == "*") {
            // 通配符仅允许强 ETag
            _tag = tag
        } else {
            let (result, length) = HttpRuleParser.getQuotedStringLength(tag, 0)
            if (result != HttpParseResult.Parsed || length != tag.size) {
                throw Exception("Invalid ETag format: '${tag}'")
            }
            _tag = tag
            _isWeak = isWeak
        }
    }

    /**
     * @brief 通配符 ETag（`*`），表示"任意 ETag"
     */
    /**
     * @brief 表示匹配任意实体标签的通配符值。
     */
    public static let any: EntityTagHeaderValue = EntityTagHeaderValue("*", false)

    /**
     * @brief 带引号的 ETag 标签值（如 `"abc123"`）
     * @return 当前 ETag 的标签值。
     */
    public prop tag: String {
        get() {
            _tag
        }
    }

    /**
     * @brief 是否为弱 ETag（`W/` 前缀）
     * @return 当前 ETag 为弱标签时返回 `true`。
     */
    public prop isWeak: Bool {
        get() {
            _isWeak
        }
    }

    /**
     * @brief 序列化为字符串：弱 ETag 带 `W/` 前缀
     * @return 当前 ETag 标头的字符串表示。
     */
    public func toString(): String {
        if (_isWeak) {
            return "W/" + _tag
        }
        return _tag
    }

    /**
     * @brief 比较两个 ETag 标头值是否相等。
     * @param other 要比较的 ETag 标头值。
     * @return 如果两个 ETag 标头值相等则返回 true，否则返回 false。
     */
    public operator func ==(other: EntityTagHeaderValue): Bool {
        return _isWeak == other._isWeak && _tag == other._tag
    }

    /**
     * @brief 返回当前 ETag 标头值的哈希值。
     * @return 当前 ETag 标头值的哈希值。
     */
    public func hashCode(): Int64 {
        return _tag.hashCode() ^ (if (_isWeak) {
            1
        } else {
            0
        })
    }

    /**
     * @brief RFC 7232 §2.3.2 ETag 比较
     *
     * useStrongComparison=true：强比较，双方均不得为弱 ETag，且 tag 字节完全相同
     * useStrongComparison=false：弱比较，忽略强弱标志，仅比较 tag 字节
     * @param other 要比较的另一个 ETag。
     * @param useStrongComparison 是否执行强比较。
     * @return 满足比较规则时返回 `true`。
     */
    public func compare(other: EntityTagHeaderValue, useStrongComparison: Bool): Bool {
        if (useStrongComparison) {
            return !isWeak && !other.isWeak && _tag == other._tag
        }
        return _tag == other._tag
    }

    /**
     * @brief 解析单个 ETag 字符串，格式非法时抛出异常
     * @param input 待解析的 ETag 字符串。
     * @return 解析得到的 ETag 标头值。
     */
    public static func parse(input: String): EntityTagHeaderValue {
        let (ok, result, _) = singleValueParser.tryParseValue(input, 0)
        if (!ok) {
            throw Exception("Invalid ETag value: '${input}'")
        }
        match (result) {
            case Some(v) => return v
            case None => throw Exception("Invalid ETag value: '${input}'")
        }
    }

    /**
     * @brief 尝试解析单个 ETag 字符串，返回 None 表示格式无效
     * @param input 待解析的 ETag 字符串。
     * @return 解析成功时返回 ETag 标头值；失败时返回 `None`。
     */
    public static func tryParse(input: String): ?EntityTagHeaderValue {
        let (ok, result, _) = singleValueParser.tryParseValue(input, 0)
        if (!ok) {
            return None
        }
        return result
    }

    /**
     * @brief 解析逗号分隔的 ETag 列表（宽松模式，忽略无效项）
     * @param inputs 待解析的原始字符串列表。
     * @return 成功解析得到的 ETag 列表。
     */
    public static func parseList(inputs: ?ArrayList<String>): ArrayList<EntityTagHeaderValue> {
        return multipleValueParser.parseValues(inputs)
    }

    /**
     * @brief 解析逗号分隔的 ETag 列表（严格模式，遇无效项抛出异常）
     * @param inputs 待解析的原始字符串列表。
     * @return 严格解析得到的 ETag 列表。
     */
    public static func parseStrictList(inputs: ?ArrayList<String>): ArrayList<EntityTagHeaderValue> {
        return multipleValueParser.parseStrictValues(inputs)
    }

    /**
     * @brief 尝试解析逗号分隔的 ETag 列表（宽松模式），有效项为空时返回 None
     * @param inputs 待解析的原始字符串列表。
     * @return 解析成功时返回 ETag 列表；失败或无有效项时返回 `None`。
     */
    public static func tryParseList(inputs: ?ArrayList<String>): ?ArrayList<EntityTagHeaderValue> {
        return multipleValueParser.tryParseValues(inputs)
    }

    /**
     * @brief 尝试解析逗号分隔的 ETag 列表（严格模式），遇到无效项返回 None
     * @param inputs 待解析的原始字符串列表。
     * @return 严格解析成功时返回 ETag 列表；失败时返回 `None`。
     */
    public static func tryParseStrictList(inputs: ?ArrayList<String>): ?ArrayList<EntityTagHeaderValue> {
        return multipleValueParser.tryParseStrictValues(inputs)
    }

    // ── 内部解析核心 ──────────────────────────────────────────────────────────

    // 解析从 startIndex 开始的 ETag 值
    // 返回 (消耗长度, 解析结果)；长度为 0 表示格式无效
    // 调用方负责去除前导空白
    static func getEntityTagLength(input: String, startIndex: Int64): (Int64, ?EntityTagHeaderValue) {
        if (input.isEmpty() || startIndex >= input.size) {
            return (0, None)
        }

        var isWeak = false
        var current = startIndex
        let firstChar = input[current]
        var parsedValue: ?EntityTagHeaderValue = None

        if (firstChar == b'*') {
            // 通配符 *：构造新实例避免与 any 的静态初始化产生循环依赖
            let wildcard = EntityTagHeaderValue()
            wildcard._tag = "*"
            parsedValue = wildcard
            current++ // skip '*'
        } else {
            // 检查弱 ETag 前缀 'W/' 或 'w/'（RFC 7232 允许大写 W，兼容小写 w）
            if (firstChar == b'W' || firstChar == b'w') {
                current++
                // 弱 ETag 至少需要 '/' + '""' = 3 个字符，不足则格式非法
                if (current + 2 >= input.size || input[current] != b'/') {
                    return (0, None)
                }
                isWeak = true
                current++ // skip '/'

                // RFC 不允许此处有空白，但宽松模式下跳过（同 C# 实现）
                current += HttpRuleParser.getWhitespaceLength(input, current)
            }

            // 解析 quoted-string
            let tagStartIndex = current
            let (qResult, tagLength) = HttpRuleParser.getQuotedStringLength(input, current)
            if (qResult != HttpParseResult.Parsed) {
                return (0, None)
            }

            let etag = EntityTagHeaderValue()
            etag._tag = input[tagStartIndex..tagStartIndex + tagLength]
            etag._isWeak = isWeak
            parsedValue = etag
            current += tagLength
        }

        // 跳过尾部空白（与 C# 行为一致，使消耗长度包含尾部空白）
        current += HttpRuleParser.getWhitespaceLength(input, current)

        return (current - startIndex, parsedValue)
    }
}

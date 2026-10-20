// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_http.headers

/**
 * @brief 表示 HTTP 解析结果。
 */
enum HttpParseResult <: Equatable<HttpParseResult> {
    /**
     * @brief 表示解析成功。
     */
    | Parsed
    /**
     * @brief 表示当前输入未解析出目标内容。
     */
    | NotParsed
    /**
     * @brief 表示输入格式非法。
     */
    | InvalidFormat

    /**
     * @brief 比较两个解析结果是否相等。
     * @param other 要比较的解析结果。
     * @return 如果两个解析结果相等则返回 true，否则返回 false。
     */
    public operator func ==(other: HttpParseResult): Bool {
        match ((this, other)) {
            case (Parsed, Parsed) => true
            case (NotParsed, NotParsed) => true
            case (InvalidFormat, InvalidFormat) => true
            case _ => false
        }
    }

    /**
     * @brief 比较两个解析结果是否不相等。
     * @param other 要比较的解析结果。
     * @return 如果两个解析结果不相等则返回 true，否则返回 false。
     */
    public operator func !=(other: HttpParseResult): Bool {
        !(this == other)
    }
}

class HttpRuleParser {
    static let maxNestedCount: Int64 = 5

    // Int32 最大十进制位数（对应 2147483647 = 2^31-1，10 位）
    static let MaxInt32Digits: Int64 = 10

    // Int64 最大十进制位数（对应 9223372036854775807 = 2^63-1，19 位）
    static let MaxInt64Digits: Int64 = 19

    // 返回从 startIndex 开始的十进制数字字符数量（不含前导空白）
    // allowLeadingWhitespace 参数保留用于 API 兼容，本实现中调用方负责去除空白
    static func getNumberLength(input: String, startIndex: Int64, _: Bool): Int64 {
        if (startIndex >= input.size) {
            return 0
        }
        var current = startIndex
        while (current < input.size && input[current] >= b'0' && input[current] <= b'9') {
            current++
        }
        return current - startIndex
    }

    // RFC 7230 §3.2.6 separator 字符集，静态共享，避免每次调用重新分配
    private static let SEPARATORS: Array<Byte> = [b'(', b')', b'<', b'>', b'@', b',', b';', b':', b'\\', b'"', b'/',
        b'[', b']', b'?', b'=', b'{', b'}']

    // token = 1*<any CHAR except CTLs or separators>（RFC 7230）
    private static func isTokenChar(b: Byte): Bool {
        if (b <= 32 || b == 127) {
            return false
        }
        return !SEPARATORS.contains(b)
    }

    // 返回从 startIndex 开始的 token 长度（0 表示不是 token）
    static func getTokenLength(input: String, startIndex: Int64): Int64 {
        if (startIndex >= input.size) {
            return 0
        }
        var current = startIndex
        while (current < input.size && isTokenChar(input[current])) {
            current++
        }
        return current - startIndex
    }

    // 返回从 startIndex 开始的空白字符长度（SP、HT、折叠空白 CRLF SP/HT）
    static func getWhitespaceLength(input: String, startIndex: Int64): Int64 {
        if (startIndex >= input.size) {
            return 0
        }
        var current = startIndex
        while (current < input.size) {
            let c = input[current]
            if (c == b' ' || c == b'\t') {
                current++
                continue
            }
            if (c == b'\r' && current + 2 < input.size && input[current + 1] == b'\n') {
                let next = input[current + 2]
                if (next == b' ' || next == b'\t') {
                    current += 3
                    continue
                }
            }
            break
        }
        return current - startIndex
    }

    // 解析 quoted-string，返回 (HttpParseResult, length)，length 含首尾引号
    static func getQuotedStringLength(input: String, startIndex: Int64): (HttpParseResult, Int64) {
        var nested: Int64 = 0
        return getExpressionLength(input, startIndex, b'"', b'"', false, nested)
    }

    // 解析 quoted-pair（\\ + ASCII char），返回 (HttpParseResult, length)
    static func getQuotedPairLength(input: String, startIndex: Int64): (HttpParseResult, Int64) {
        if (startIndex >= input.size || input[startIndex] != b'\\') {
            return (HttpParseResult.NotParsed, 0)
        }
        if (startIndex + 2 > input.size || input[startIndex + 1] > 127) {
            return (HttpParseResult.InvalidFormat, 0)
        }
        return (HttpParseResult.Parsed, 2)
    }

    // 通用表达式解析，返回 (HttpParseResult, length)
    private static func getExpressionLength(
        input: String,
        startIndex: Int64,
        openChar: Byte,
        closeChar: Byte,
        supportsNesting: Bool,
        nested: Int64
    ): (HttpParseResult, Int64) {
        if (startIndex >= input.size || input[startIndex] != openChar) {
            return (HttpParseResult.NotParsed, 0)
        }
        var current = startIndex + 1
        var nestedCount = nested
        while (current < input.size) {
            let (pairResult, pairLen) = getQuotedPairLength(input, current)
            if (pairResult == HttpParseResult.Parsed) {
                current += pairLen
                continue
            }
            if (supportsNesting && input[current] == openChar) {
                nestedCount++
                if (nestedCount > maxNestedCount) {
                    return (HttpParseResult.InvalidFormat, 0)
                }
                let (nestedResult, nestedLen) = getExpressionLength(input, current, openChar, closeChar, supportsNesting,
                    nestedCount)
                nestedCount--
                match (nestedResult) {
                    case HttpParseResult.Parsed => current += nestedLen
                    case HttpParseResult.InvalidFormat => return (HttpParseResult.InvalidFormat, 0)
                    case _ => ()
                }
                continue
            }
            if (input[current] == closeChar) {
                return (HttpParseResult.Parsed, current - startIndex + 1)
            }
            current++
        }
        return (HttpParseResult.InvalidFormat, 0)
    }
}

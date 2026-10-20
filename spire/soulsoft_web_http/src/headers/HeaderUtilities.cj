// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_http.headers

import std.convert.*
import std.collection.*

/**
 * @brief 提供 HTTP 标头解析和格式化辅助函数。
 */
public class HeaderUtilities {
    static let qualityName = "q"

    /**
     * @brief 表示字节范围标头使用的单位名称。
     */
    public static let bytesUnit: String = "bytes"

    // HTTP 日期各字段名称表（用于 formatDate）
    private static let MONTHS: Array<String> = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct",
        "Nov", "Dec"]
    private static let WEEKDAYS: Array<String> = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

    // 只读保护：isReadOnly 为 true 时抛出异常
    static func throwIfReadOnly(isReadOnly: Bool): Unit {
        if (isReadOnly) {
            throw Exception("The object cannot be modified because it is read-only.")
        }
    }

    // 校验合法 token（非空且全为 token 字符）
    static func checkValidToken(value: String, paramName: String): Unit {
        if (value.isEmpty()) {
            throw IllegalArgumentException("An empty string is not allowed for parameter '${paramName}'.")
        }
        if (HttpRuleParser.getTokenLength(value, 0) != value.size) {
            throw IllegalArgumentException("Invalid token '${value}'.")
        }
    }

    /**
     * @brief 检查字符串是否为带引号的 quoted-string。
     * @param value 要检查的字符串。
     * @return 如果字符串是 quoted-string 则返回 true，否则返回 false。
     */
    public static func isQuoted(value: String): Bool {
        return value.size >= 2 && value[0] == b'"' && value[value.size - 1] == b'"'
    }

    /**
     * @brief 去除字符串首尾的双引号。
     * @param value 要处理的字符串。
     * @return 去除首尾双引号后的字符串。
     */
    public static func removeQuotes(value: String): String {
        if (isQuoted(value)) {
            return value[1..value.size - 1]
        }
        return value
    }

    /**
     * @brief 对 quoted-string 执行去引号和反转义。
     * @param value 要处理的 quoted-string。
     * @return 处理后的普通字符串。
     */
    public static func unescapeAsQuotedString(value: String): String {
        let inner = removeQuotes(value)
        let backslashCount = countBackslashesForDecoding(inner)
        if (backslashCount == 0) {
            return inner
        }
        let sb = StringBuilder()
        var i = 0
        while (i < inner.size) {
            let next = i + 1
            if (next < inner.size && inner[i] == b'\\') {
                sb.append(String.fromUtf8([inner[next]]))
                i += 2
            } else {
                sb.append(String.fromUtf8([inner[i]]))
                i++
            }
        }
        return sb.toString()
    }

    /**
     * @brief 将字符串转义为 quoted-string。
     * @param value 要转义的字符串。
     * @return 转义后的 quoted-string。
     * @throws Exception 当输入包含非法控制字符时抛出。
     */
    public static func escapeAsQuotedString(value: String): String {
        let sb = StringBuilder()
        sb.append("\"")
        for (b in value) {
            if (b == b'\\' || b == b'"') {
                sb.append("\\")
            } else if ((b <= 0x1F || b == 0x7F) && b != 0x09) {
                throw Exception("Invalid control character in input.")
            }
            sb.append(String.fromUtf8([b]))
        }
        sb.append("\"")
        return sb.toString()
    }

    // 从参数列表获取 quality 值（q=0.9 → Some(0.9)）
    static func getQuality(parameters: ?ArrayList<NameValueHeaderValue>): ?Float64 {
        if (let Some(params) <- parameters) {
            if (let Some(qParam) <- NameValueHeaderValue.find(params, qualityName)) {
                return parseQualityDouble(qParam.value, 0)
            }
        }
        return None
    }

    // 设置 quality 值；None 表示移除
    static func setQuality(parameters: ArrayList<NameValueHeaderValue>, value: ?Float64): Unit {
        let qParam = NameValueHeaderValue.find(parameters, qualityName)
        match (value) {
            case Some(v) =>
                if (v < 0.0 || v > 1.0) {
                    throw IllegalArgumentException("Quality value must be between 0 and 1.")
                }
                let qualityStr = formatQuality(v)
                match (qParam) {
                    case Some(p) => p.value = qualityStr
                    case None => parameters.add(NameValueHeaderValue(qualityName, qualityStr))
                }
            case None =>
                if (let Some(p) <- qParam) {
                    parameters.removeIf {v => v == p}
                }
        }
    }

    // 无序集合相等比较
    static func areEqualCollections(
        x: ?ArrayList<NameValueHeaderValue>,
        y: ?ArrayList<NameValueHeaderValue>
    ): Bool {
        let xList = x ?? ArrayList<NameValueHeaderValue>()
        let yList = y ?? ArrayList<NameValueHeaderValue>()
        if (xList.size != yList.size) {
            return false
        }
        if (xList.size == 0) {
            return true
        }
        var alreadyFound = Array<Bool>(xList.size, repeat: false)
        for (xItem in xList) {
            var found = false
            var i = 0
            for (yItem in yList) {
                if (!alreadyFound[i] && xItem == yItem) {
                    alreadyFound[i] = true
                    found = true
                    break
                }
                i++
            }
            if (!found) {
                return false
            }
        }
        return true
    }

    // 解析 quality double（RFC 9110 §12.4.2）
    private static func parseQualityDouble(input: String, startIndex: Int64): ?Float64 {
        if (startIndex >= input.size) {
            return None
        }
        let ch = input[startIndex]
        if (ch < b'0' || ch > b'1') {
            return None
        }
        var intPart = Int64(ch - b'0')
        var current = startIndex + 1
        var decPart: Int64 = 0
        var decPow: Int64 = 1
        if (current < input.size && input[current] == b'.') {
            current++
            while (current < input.size) {
                let c = input[current]
                if (c >= b'0' && c <= b'9') {
                    decPart = decPart * 10 + Int64(c - b'0')
                    decPow *= 10
                    current++
                } else {
                    break
                }
            }
        }
        let quality = if (decPart != 0) {
            Float64(intPart) + Float64(decPart) / Float64(decPow)
        } else {
            Float64(intPart)
        }
        if (quality > 1.0) {
            return None
        }
        return quality
    }

    // 格式化 quality 为字符串（对应 C# "0.0##"：固定至少一位小数，最多三位，去除尾零）
    private static func formatQuality(v: Float64): String {
        // 先格式化为三位固定小数，再去除尾零，但至少保留一位（如 1.0→"1.0"，0.9→"0.9"，0.05→"0.05"）
        var s = v.format(".3")
        while (s.endsWith("0") && !s.endsWith(".0")) {
            s = s[0..s.size - 1]
        }
        return s
    }

    // 跳过从 startIndex 起的空白，若遇到逗号分隔符则跳过它（及其后的空白），
    // skipEmptyValues=true 时连续跳过多个空逗号（如 ",,"）
    // 返回 (newIndex, separatorFound)
    static func getNextNonEmptyOrWhitespaceIndex(
        input: String,
        startIndex: Int64,
        skipEmptyValues: Bool
    ): (Int64, Bool) {
        var current = startIndex + HttpRuleParser.getWhitespaceLength(input, startIndex)
        if (current == input.size || input[current] != b',') {
            return (current, false)
        }
        // 找到逗号分隔符
        current++ // skip ','
        current += HttpRuleParser.getWhitespaceLength(input, current)
        if (skipEmptyValues) {
            // 连续跳过多个空分隔符（如 ",,"）
            while (current < input.size && input[current] == b',') {
                current++
                current += HttpRuleParser.getWhitespaceLength(input, current)
            }
        }
        return (current, true)
    }

    /**
     * @brief 尝试将字符串解析为非负 Int64。
     * @param input 要解析的字符串。
     * @return 解析成功时返回非负整数，否则返回空。
     */
    public static func tryParseNonNegativeInt64(input: String): ?Int64 {
        if (input.isEmpty()) {
            return None
        }
        match (Int64.tryParse(input)) {
            case Some(v) =>
                if (v < 0) {
                    return None
                }
                return v
            case None => return None
        }
    }

    /**
     * @brief 将 Unix epoch 秒格式化为 RFC 7231 IMF-fixdate 字符串。
     * @param epochSeconds Unix epoch 秒值。
     * @return RFC 7231 IMF-fixdate 格式的日期字符串。
     */
    public static func formatDate(epochSeconds: Int64): String {
        let (year, month, day, hour, minute, second, dow) = epochToDate(epochSeconds)
        let dayName = WEEKDAYS[dow]
        let monthName = MONTHS[month - 1]
        let dayStr = if (day < 10) {
            "0${day}"
        } else {
            "${day}"
        }
        let hourStr = if (hour < 10) {
            "0${hour}"
        } else {
            "${hour}"
        }
        let minStr = if (minute < 10) {
            "0${minute}"
        } else {
            "${minute}"
        }
        let secStr = if (second < 10) {
            "0${second}"
        } else {
            "${second}"
        }
        return "${dayName}, ${dayStr} ${monthName} ${year} ${hourStr}:${minStr}:${secStr} GMT"
    }

    /**
     * @brief 尝试将 HTTP-date 字符串解析为时间戳。
     * @param input 要解析的 HTTP-date 字符串。
     * @param startIndex 开始解析的位置。
     * @return 解析成功时返回消耗长度和 Unix epoch 秒，否则返回空。
     */
    public static func tryStringToDate(input: String, startIndex: Int64): ?(Int64, Int64) {
        if (startIndex + 29 > input.size) {
            return None
        }
        match (tryParseImfFixdate(input, startIndex)) {
            case Some(epochSeconds) =>
                // 跳过尾部空白
                var end = startIndex + 29
                end += HttpRuleParser.getWhitespaceLength(input, end)
                return Some((end - startIndex, epochSeconds))
            case None => return None
        }
    }

    // 解析 IMF-fixdate，返回 epoch 秒；失败返回 None
    // 格式："Day, DD Mon YYYY HH:MM:SS GMT"（29 字符，索引 0..28）
    private static func tryParseImfFixdate(input: String, base: Int64): ?Int64 {
        // 固定位置检验分隔符
        if (input[base + 3] != b',' || input[base + 4] != b' ' || input[base + 7] != b' ' || input[base + 11] != b' ' ||
            input[base + 16] != b' ' || input[base + 19] != b':' || input[base + 22] != b':' || input[base + 25] != b' ' ||
            input[base + 26] != b'G' || input[base + 27] != b'M' || input[base + 28] != b'T') {
            return None
        }
        let day = match (parseTwoDigit(input, base + 5)) {
            case Some(v) => v
            case None => return None
        }
        let month = match (parseMonthName(input[base + 8..base + 11])) {
            case Some(v) => v
            case None => return None
        }
        let year = match (parseFourDigit(input, base + 12)) {
            case Some(v) => v
            case None => return None
        }
        let hour = match (parseTwoDigit(input, base + 17)) {
            case Some(v) => v
            case None => return None
        }
        let minute = match (parseTwoDigit(input, base + 20)) {
            case Some(v) => v
            case None => return None
        }
        let second = match (parseTwoDigit(input, base + 23)) {
            case Some(v) => v
            case None => return None
        }
        // 范围校验
        if (month < 1 || month > 12 || day < 1 || day > 31 || hour > 23 || minute > 59 || second > 59) {
            return None
        }
        return dateToEpoch(year, month, day, hour, minute, second)
    }

    // 从 idx 处解析两位十进制数字（不含前导空白）
    private static func parseTwoDigit(input: String, idx: Int64): ?Int64 {
        let h = input[idx]
        let l = input[idx + 1]
        if (h < b'0' || h > b'9' || l < b'0' || l > b'9') {
            return None
        }
        return Int64(h - b'0') * 10 + Int64(l - b'0')
    }

    // 从 idx 处解析四位十进制数字
    private static func parseFourDigit(input: String, idx: Int64): ?Int64 {
        let a = input[idx]
        let b_ = input[idx + 1]
        let c = input[idx + 2]
        let d = input[idx + 3]
        if (a < b'0' || a > b'9' || b_ < b'0' || b_ > b'9' || c < b'0' || c > b'9' || d < b'0' || d > b'9') {
            return None
        }
        return Int64(a - b'0') * 1000 + Int64(b_ - b'0') * 100 + Int64(c - b'0') * 10 + Int64(d - b'0')
    }

    // 解析 3 字符月份缩写为 1-12
    private static func parseMonthName(s: String): ?Int64 {
        if (s == "Jan") {
            return 1
        }
        if (s == "Feb") {
            return 2
        }
        if (s == "Mar") {
            return 3
        }
        if (s == "Apr") {
            return 4
        }
        if (s == "May") {
            return 5
        }
        if (s == "Jun") {
            return 6
        }
        if (s == "Jul") {
            return 7
        }
        if (s == "Aug") {
            return 8
        }
        if (s == "Sep") {
            return 9
        }
        if (s == "Oct") {
            return 10
        }
        if (s == "Nov") {
            return 11
        }
        if (s == "Dec") {
            return 12
        }
        return None
    }

    // Unix epoch 秒 → (year, month, day, hour, minute, second, dayOfWeek)
    // dayOfWeek: 0=Sun, 1=Mon, ..., 6=Sat
    // 使用 Howard Hinnant 的民用日期算法
    private static func epochToDate(ts: Int64): (Int64, Int64, Int64, Int64, Int64, Int64, Int64) {
        let days = ts / 86400
        let rem = ts % 86400
        let hour = rem / 3600
        let minute = (rem % 3600) / 60
        let second = rem % 60
        // 1970-01-01 是星期四 (4)；偏移后 0=Sunday
        let dow = ((days % 7) + 4 + 7) % 7

        // 民用日历算法（Howard Hinnant）
        let z = days + 719468
        let era = if (z >= 0) {
            z / 146097
        } else {
            (z - 146096) / 146097
        }
        let doe = z - era * 146097
        let yoe = (doe - doe / 1460 + doe / 36524 - doe / 146096) / 365
        let y = yoe + era * 400
        let doy = doe - (365 * yoe + yoe / 4 - yoe / 100)
        let mp = (5 * doy + 2) / 153
        let d = doy - (153 * mp + 2) / 5 + 1
        let m = if (mp < 10) {
            mp + 3
        } else {
            mp - 9
        }
        let adjY = y + (if (m <= 2) {
            1
        } else {
            0
        })

        return (adjY, m, d, hour, minute, second, dow)
    }

    // (year, month, day, hour, minute, second) → Unix epoch 秒（UTC）
    // 使用 Howard Hinnant 的逆向算法
    private static func dateToEpoch(
        year: Int64,
        month: Int64,
        day: Int64,
        hour: Int64,
        minute: Int64,
        second: Int64
    ): ?Int64 {
        var y = year
        var m = month
        if (m <= 2) {
            y -= 1
            m += 9
        } else {
            m -= 3
        }
        let era = if (y >= 0) {
            y / 400
        } else {
            (y - 399) / 400
        }
        let yoe = y - era * 400
        let doy = (153 * m + 2) / 5 + day - 1
        let doe = yoe * 365 + yoe / 4 - yoe / 100 + doy
        let days = era * 146097 + doe - 719468
        return days * 86400 + hour * 3600 + minute * 60 + second
    }

    private static func countBackslashesForDecoding(input: String): Int64 {
        var count: Int64 = 0
        var i = 0
        while (i < input.size) {
            if (i < input.size - 1 && input[i] == b'\\') {
                if (input[i + 1] == b'\\') {
                    i++
                }
                count++
            }
            i++
        }
        return count
    }
}

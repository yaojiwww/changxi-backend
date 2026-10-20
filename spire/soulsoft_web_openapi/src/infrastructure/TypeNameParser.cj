/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_openapi.infrastructure

import std.collection.*

private let Space = UInt8(32)
private let Tab = UInt8(9)
private let LineFeed = UInt8(10)
private let CarriageReturn = UInt8(13)
private let LessThan = UInt8(60)
private let GreaterThan = UInt8(62)
private let Comma = UInt8(44)

/**
 * @brief 提供基于类型限定名的轻量泛型解析能力。
 */
protected class TypeNameParser {
    /**
     * @brief 返回泛型类型的原始类型名；非泛型时返回自身。
     * @param qualifiedName 类型限定名。
     * @return 去掉泛型参数后的类型名。
     */
    public static func getGenericBaseName(qualifiedName: String): String {
        if (let Some(index) <- qualifiedName.indexOf('<')) {
            return trimAsciiWhitespace(qualifiedName[0..index])
        }
        return trimAsciiWhitespace(qualifiedName)
    }

    /**
     * @brief 解析限定名中的顶层泛型参数列表。
     * @param qualifiedName 类型限定名，例如 `Map<String, Int64>`。
     * @return 顶层泛型参数；若不是合法泛型限定名则返回 `None`。
     */
    public static func getGenericArguments(qualifiedName: String): ?Array<String> {
        if (!qualifiedName.endsWith('>')) {
            return None
        }
        let start = qualifiedName.indexOf('<') ?? return None
        let payload = qualifiedName[start + 1..qualifiedName.size - 1]
        let result = ArrayList<String>()
        var depth = 0
        var segmentStart = 0
        var index = 0
        while (index < payload.size) {
            let ch = payload[index]
            if (ch == LessThan) {
                depth++
            } else if (ch == GreaterThan) {
                if (depth == 0) {
                    return None
                }
                depth--
            } else if (ch == Comma && depth == 0) {
                let argument = trimAsciiWhitespace(payload[segmentStart..index])
                if (argument.isEmpty()) {
                    return None
                }
                result.add(argument)
                segmentStart = index + 1
            }
            index++
        }
        if (depth != 0) {
            return None
        }
        let argument = trimAsciiWhitespace(payload[segmentStart..payload.size])
        if (argument.isEmpty()) {
            return None
        }
        result.add(argument)
        return result.toArray()
    }

    private static func trimAsciiWhitespace(value: String): String {
        var start = 0
        var end = value.size
        while (start < end && isAsciiWhitespace(value[start])) {
            start++
        }
        while (end > start && isAsciiWhitespace(value[end - 1])) {
            end--
        }
        return value[start..end]
    }

    private static func isAsciiWhitespace(ch: UInt8): Bool {
        ch == Space || ch == Tab || ch == LineFeed || ch == CarriageReturn
    }
}

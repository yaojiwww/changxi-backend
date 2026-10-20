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
 * @brief 表示 HTTP 标头解析器抽象基类。
 */
abstract class HttpHeaderParser<T> {
    // 是否支持多值（逗号分隔）解析
    let supportsMultipleValues: Bool

    /**
     * @brief 创建 HTTP 标头解析器实例。
     * @param supportsMultipleValues 是否支持多值解析。
     */
    protected init(supportsMultipleValues: Bool) {
        this.supportsMultipleValues = supportsMultipleValues
    }

    /**
     * @brief 尝试从指定位置解析单个标头值。
     * @param value 标头原始字符串。
     * @param startIndex 开始解析的位置。
     * @return 解析是否成功、解析结果以及新的游标位置。
     */
    public open func tryParseValue(value: String, startIndex: Int64): (Bool, ?T, Int64) {
        return (false, None, startIndex)
    }

    /**
     * @brief 从指定位置解析单个标头值。
     * @param value 标头原始字符串。
     * @param startIndex 开始解析的位置。
     * @return 解析得到的标头值；合法空项时返回空。
     * @throws Exception 当标头值格式无效时抛出。
     */
    public func parseValue(value: String, startIndex: Int64): ?T {
        let (ok, result, _) = tryParseValue(value, startIndex)
        if (!ok) {
            throw Exception("The header contains invalid values at index ${startIndex}: '${value}'")
        }
        return result
    }

    /**
     * @brief 以宽松模式尝试解析多值标头列表。
     * @param values 标头值字符串列表。
     * @return 解析成功的标头值列表；没有可用值时返回空。
     */
    public func tryParseValues(values: ?ArrayList<String>): ?ArrayList<T> {
        return tryParseValuesCore(values, false)
    }

    /**
     * @brief 以严格模式尝试解析多值标头列表。
     * @param values 标头值字符串列表。
     * @return 全部值均合法时返回解析结果；否则返回空。
     */
    public func tryParseStrictValues(values: ?ArrayList<String>): ?ArrayList<T> {
        return tryParseValuesCore(values, true)
    }

    /**
     * @brief 以宽松模式解析多值标头列表。
     * @param values 标头值字符串列表。
     * @return 解析成功的标头值列表。
     */
    public func parseValues(values: ?ArrayList<String>): ArrayList<T> {
        return parseValuesCore(values, false)
    }

    /**
     * @brief 以严格模式解析多值标头列表。
     * @param values 标头值字符串列表。
     * @return 解析后的标头值列表。
     * @throws Exception 当任一标头值格式无效时抛出。
     */
    public func parseStrictValues(values: ?ArrayList<String>): ArrayList<T> {
        return parseValuesCore(values, true)
    }

    private func tryParseValuesCore(values: ?ArrayList<String>, strict: Bool): ?ArrayList<T> {
        match (values) {
            case None => return None
            case Some(vals) =>
                var results: ?ArrayList<T> = None
                for (value in vals) {
                    var index: Int64 = 0
                    while (index < value.size) {
                        let (ok, output, newIndex) = tryParseValue(value, index)
                        if (ok) {
                            if (let Some(v) <- output) {
                                match (results) {
                                    case None =>
                                        let list = ArrayList<T>()
                                        list.add(v)
                                        results = list
                                    case Some(r) => r.add(v)
                                }
                            }
                            index = newIndex
                        } else if (strict) {
                            return None
                        } else {
                            index++
                        }
                    }
                }
                return results
        }
    }

    private func parseValuesCore(values: ?ArrayList<String>, strict: Bool): ArrayList<T> {
        let parsedValues = ArrayList<T>()
        match (values) {
            case None => return parsedValues
            case Some(vals) =>
                for (value in vals) {
                    var index: Int64 = 0
                    while (index < value.size) {
                        let (ok, output, newIndex) = tryParseValue(value, index)
                        if (ok) {
                            if (let Some(v) <- output) {
                                parsedValues.add(v)
                            }
                            index = newIndex
                        } else if (strict) {
                            throw Exception("The header contains invalid values at index ${index}: '${value}'")
                        } else {
                            index++
                        }
                    }
                }
                return parsedValues
        }
    }
}

/**
 * @brief 表示基于委托函数的通用标头解析器。
 */
class GenericHeaderParser<T> <: HttpHeaderParser<T> {
    // 委托：解析 input[startIndex..] 中的单个值
    // 返回 (消耗长度, 解析结果)；长度为 0 表示解析失败
    private let _getParsedValueLength: (String, Int64) -> (Int64, ?T)

    init(supportsMultipleValues: Bool, getParsedValueLength: (String, Int64) -> (Int64, ?T)) {
        super(supportsMultipleValues)
        _getParsedValueLength = getParsedValueLength
    }

    /**
     * @brief 尝试从指定位置解析单个标头值。
     * @param value 标头原始字符串。
     * @param startIndex 开始解析的位置。
     * @return 解析是否成功、解析结果以及新的游标位置。
     */
    public override func tryParseValue(value: String, startIndex: Int64): (Bool, ?T, Int64) {
        // 空串或已到末尾：多值模式视为合法空项
        if (value.isEmpty() || startIndex == value.size) {
            return (supportsMultipleValues, None, startIndex)
        }

        // 跳过前导空白，检查是否存在逗号分隔符
        let (current1, sepFound1) = HeaderUtilities.getNextNonEmptyOrWhitespaceIndex(
            value,
            startIndex,
            supportsMultipleValues
        )

        // 单值模式不允许前导分隔符
        if (sepFound1 && !supportsMultipleValues) {
            return (false, None, startIndex)
        }

        // 跳过空白/分隔符后已到末尾
        if (current1 == value.size) {
            return (supportsMultipleValues, None, current1)
        }

        // 调用具体解析委托
        let (length, parsedValue) = _getParsedValueLength(value, current1)
        if (length == 0) {
            return (false, None, startIndex)
        }

        // 跳过尾部空白和可选的逗号分隔符（供下次迭代使用）
        let current2 = current1 + length
        let (current3, sepFound2) = HeaderUtilities.getNextNonEmptyOrWhitespaceIndex(
            value,
            current2,
            supportsMultipleValues
        )

        // 单值模式不允许尾部分隔符；若无分隔符但尚未到末尾则格式非法
        if ((sepFound2 && !supportsMultipleValues) || (!sepFound2 && current3 < value.size)) {
            return (false, None, startIndex)
        }

        return (true, parsedValue, current3)
    }
}

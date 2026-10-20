// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_routing.patterns

/**
 * 路由模式调试字符串格式化工具（包内使用）。
 *
 * 当路由模式存在 required values 对应到参数时，将参数替换为该值，
 * 生成比 rawText 更有诊断意义的调试字符串。
 *
 * 例如：模板 "{controller}/{action}" + requiredValues { controller="Home", action="Index" }
 * 调试字符串为 "Home/Index"。
 */
class RoutePatternDebugStringFormatter {

    private static let SEPARATOR: UInt8 = b'/'
    private static let SEPARATOR_STRING = "/"

    /**
     * 将路由模式格式化为调试友好的字符串。
     *
     * @param pattern 目标路由模式。
     * @return 格式化后的调试字符串。
     */
    static func format(pattern: RoutePattern): String {
        // 若无任何参数有匹配的 required value，直接返回 rawText（快速路径）
        if (pattern.rawText.size > 0 && !hasMatchingRequiredValues(pattern)) {
            return pattern.rawText
        }

        // 逐段构建调试字符串，参数替换为对应 required value
        let builder = StringBuilder()
        var first = true
        for (i in 0..pattern.pathSegments.size) {
            if (!first) {
                builder.append(SEPARATOR)
            }
            builder.append(getSegmentDebuggerToString(pattern, pattern.pathSegments[i]))
            first = false
        }

        let result = builder.toString()

        // 保留原始路径的前导斜杠
        if (pattern.rawText.size > 0 && pattern.rawText[0] == SEPARATOR) {
            return SEPARATOR_STRING + result
        }

        // 空结果统一返回 "/"
        return if (result.size == 0) { SEPARATOR_STRING } else { result }
    }

    /**
     * 检查是否有任何参数在 required values 中存在有效条目。
     */
    private static func hasMatchingRequiredValues(pattern: RoutePattern): Bool {
        if (pattern.requiredValues.size == 0) {
            return false
        }
        for (i in 0..pattern.parameters.size) {
            if (tryGetRequiredValue(pattern, pattern.parameters[i].name).isSome()) {
                return true
            }
        }
        return false
    }

    /**
     * 将单个路径段格式化为调试字符串。
     *
     * 简单段（单参数）若有 required value 直接返回该值；
     * 复杂段逐部分拼接，参数部分用 required value 替换。
     */
    private static func getSegmentDebuggerToString(
        pattern: RoutePattern,
        segment: RoutePatternPathSegment
    ): String {
        // 简单段（仅含一个参数）且有 required value，直接返回
        if (segment.isSimple) {
            if (let parameter: RoutePatternParameterPart <- segment.parts[0]) {
                if (let Some(value) <- tryGetRequiredValue(pattern, parameter.name)) {
                    return value
                }
            }
        }

        // 复杂段：逐部分构建，参数用 required value 替换
        let builder = StringBuilder()
        for (i in 0..segment.parts.size) {
            let part = segment.parts[i]
            var replaced = false
            if (let parameter: RoutePatternParameterPart <- part) {
                if (let Some(value) <- tryGetRequiredValue(pattern, parameter.name)) {
                    builder.append(value)
                    replaced = true
                }
            }
            if (!replaced) {
                builder.append(part.debuggerToString())
            }
        }
        return builder.toString()
    }

    /**
     * 从 pattern.requiredValues 获取指定参数名的有效值。
     *
     * 以下情况返回 None：
     * - 键不存在
     * - 值为 None
     * - 值是 RoutePattern.requiredValueAny 哨兵
     * - 值为空字符串
     *
     * @param pattern 路由模式。
     * @param parameterName 参数名。
     * @return 有效的字符串值，或 None。
     */
    private static func tryGetRequiredValue(pattern: RoutePattern, parameterName: String): ?String {
        if (let Some(Some(value)) <- pattern.requiredValues.get(parameterName)) {
            if (!RoutePattern.isRequiredValueAny(value) && value.size > 0) {
                return value
            }
        }
        return None
    }
}

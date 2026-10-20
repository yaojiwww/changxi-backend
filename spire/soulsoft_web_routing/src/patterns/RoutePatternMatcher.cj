// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_routing.patterns

import std.collection.*
import soulsoft_web_http.*

/**
 * 路由模式匹配器，对应 C# 的 RoutePatternMatcher。
 *
 * 构造时缓存每个 segment 的默认值索引（性能优化），
 * 通过 tryMatch 判断请求路径是否与路由模式匹配，并捕获路由值。
 */
protected class RoutePatternMatcher {

    // 性能优化：缓存每个 segment 对应参数的默认值，避免每次请求查 defaults。
    // 下标与 routePattern.pathSegments 一一对应（0 起）。
    private let _hasDefaultValue: Array<Bool>
    private let _defaultValues: Array<?String>

    private let _defaults: RouteValueDictionary
    private let _routePattern: RoutePattern

    /**
     * @param pattern  路由模式。
     * @param defaults 附加默认值字典；为 None 时使用空字典。
     */
    public init(pattern: RoutePattern, defaults: ?RouteValueDictionary) {
        _routePattern = pattern
        _defaults = defaults ?? RouteValueDictionary()

        let count = pattern.pathSegments.size
        _hasDefaultValue = Array<Bool>(count, repeat: false)
        _defaultValues = Array<?String>(count, repeat: None)

        for (i in 0..count) {
            let segment = pattern.pathSegments[i]
            if (!segment.isSimple) {
                continue
            }
            let part = segment.parts[0]
            if (!part.isParameter) {
                continue
            }
            if (let parameter: RoutePatternParameterPart <- part) {
                // get 返回 ?String：Some(v) 表示键存在（v 为 String）
                if (let Some(value) <- _defaults.get(parameter.name)) {
                    _hasDefaultValue[i] = true
                    _defaultValues[i] = Some(value)
                }
            }
        }
    }

    /** 附加默认值字典。 */
    public prop defaults: RouteValueDictionary {
        get() {
            _defaults
        }
    }

    /** 路由模式。 */
    public prop routePattern: RoutePattern {
        get() {
            _routePattern
        }
    }

    /**
     * 尝试将请求路径与路由模式匹配，成功时将捕获的路由值写入 values。
     *
     * 两遍策略（对齐 C# 原版性能设计）：
     *   第一遍：快速失败——检查字面量段是否匹配，参数段是否有值/默认值。
     *   第二遍：确认匹配后，将实际值写入 values，并补充默认值。
     *
     * @param path   请求路径（如 `/products/42`）。
     * @param values 接收捕获路由值的字典（调用方应传入空字典）。
     * @return 匹配成功返回 true，否则 false。
     */
    public func tryMatch(path: PathString, values: RouteValueDictionary): Bool {
        let requestSegments = tokenizePath(path)

        // ——— 第一遍：快速失败检查 ———
        var i = 0
        while (i < requestSegments.size) {
            let requestSegment = requestSegments[i]

            if (requestSegment.size == 0) {
                // 连续 '//' 产生空段，视为无效路径
                return false
            }

            if (i >= _routePattern.pathSegments.size) {
                // URL 段数超过路由定义段数
                return false
            }

            let pathSegment = _routePattern.pathSegments[i]

            // catch-all 参数可匹配任意字符串（含空），第一遍直接结束
            if (pathSegment.isSimple) {
                if (let parameter: RoutePatternParameterPart <- pathSegment.parts[0]) {
                    if (parameter.isCatchAll) {
                        break
                    }
                }
            }

            if (!tryMatchLiterals(i, requestSegment, pathSegment)) {
                return false
            }

            i++
        }

        // 检查剩余路由段：必须全部有默认值、是可选参数或是 catch-all，否则无法匹配
        var j = i
        while (j < _routePattern.pathSegments.size) {
            let pathSegment = _routePattern.pathSegments[j]

            if (!pathSegment.isSimple) {
                // 复合段（含字面量子段）没有 URL 提供值 → 不匹配
                return false
            }

            let part = pathSegment.parts[0]
            if (part.isLiteral || part.isSeparator) {
                // 字面量段需要 URL 提供值
                return false
            }

            if (let parameter: RoutePatternParameterPart <- part) {
                if (parameter.isCatchAll) {
                    break
                }
                if (!_hasDefaultValue[j] && !parameter.isOptional) {
                    return false
                }
            }

            j++
        }

        // ——— 第二遍：捕获值 ———
        i = 0
        while (i < requestSegments.size) {
            let pathSegment = _routePattern.pathSegments[i]

            if (savePathSegmentsAsValues(i, requestSegments, i, values, pathSegment)) {
                // catch-all 已捕获剩余全部路径，结束
                i = requestSegments.size
                break
            }

            if (!pathSegment.isSimple) {
                // 复合段：委托专用算法解析
                if (!matchComplexSegment(pathSegment, requestSegments[i], values)) {
                    return false
                }
            }

            i++
        }

        // 处理剩余路由段（URL 未提供值，使用默认值）
        while (i < _routePattern.pathSegments.size) {
            let pathSegment = _routePattern.pathSegments[i]
            let part = pathSegment.parts[0]

            if (let parameter: RoutePatternParameterPart <- part) {
                if (parameter.isCatchAll || _hasDefaultValue[i]) {
                    let defaultValue = _defaultValues[i]
                    // 仅在 default 非 null 或键不存在时写入（不覆盖已捕获的值）
                    if (defaultValue.isSome() || !values.contains(parameter.name)) {
                        values[parameter.name] = defaultValue ?? String.empty
                    }
                }
            }

            i++
        }

        // 将 defaults 中剩余键值复制到 values（不覆盖已存在的值）
        for ((key, value) in _defaults) {
            values.addIfAbsent(key, value)
        }

        return true
    }

    /**
     * 第一遍：验证单个路径段是否通过字面量匹配和基本有效性检查。
     *
     * @param index          路由段下标（用于查询默认值缓存）。
     * @param requestSegment URL 对应段的字符串值。
     * @param pathSegment    路由模式段。
     * @return 通过返回 true，失败返回 false。
     */
    private func tryMatchLiterals(index: Int64, requestSegment: String, pathSegment: RoutePatternPathSegment): Bool {
        if (pathSegment.isSimple && !pathSegment.parts[0].isParameter) {
            // 字面量段：大小写不敏感精确匹配
            let part = pathSegment.parts[0]
            let content: String = if (let literal: RoutePatternLiteralPart <- part) {
                literal.content
            } else if (let separator: RoutePatternSeparatorPart <- part) {
                separator.content
            } else {
                throw UnsupportedException()
            }
            if (!requestSegment.equalsIgnoreAsciiCase(content)) {
                return false
            }
        } else if (pathSegment.isSimple && pathSegment.parts[0].isParameter) {
            // 简单参数段：空值时需要有默认值或为可选参数
            if (let parameter: RoutePatternParameterPart <- pathSegment.parts[0]) {
                if (requestSegment.size == 0 && !_hasDefaultValue[index] && !parameter.isOptional) {
                    return false
                }
            }
        }
        // 复合段：第一遍不做详细验证（交给第二遍的 matchComplexSegment）
        return true
    }

    /**
     * 第二遍：将 URL 段的值写入 values 字典。
     *
     * catch-all 参数会将从当前下标起的所有剩余 URL 段拼接后写入，返回 true 通知调用方停止迭代。
     *
     * @param segmentIndex    路由段下标（用于查询默认值缓存）。
     * @param requestSegments 所有 URL 段列表。
     * @param requestIndex    当前处理的 URL 段下标。
     * @param values          接收路由值的字典。
     * @param pathSegment     当前路由模式段。
     * @return catch-all 捕获时返回 true（停止迭代），否则返回 false。
     */
    private func savePathSegmentsAsValues(
        segmentIndex: Int64,
        requestSegments: ArrayList<String>,
        requestIndex: Int64,
        values: RouteValueDictionary,
        pathSegment: RoutePatternPathSegment
    ): Bool {
        if (!pathSegment.isSimple) {
            return false
        }

        if (let parameter: RoutePatternParameterPart <- pathSegment.parts[0]) {
            if (parameter.isCatchAll) {
                // catch-all：将从 requestIndex 起的所有段拼接为一个值
                if (requestIndex < requestSegments.size) {
                    let sb = StringBuilder()
                    for (k in requestIndex..requestSegments.size) {
                        if (k > requestIndex) {
                            sb.append('/')
                        }
                        sb.append(requestSegments[k])
                    }
                    let captured = sb.toString()
                    if (captured.size > 0) {
                        values[parameter.name] = captured
                    } else {
                        values[parameter.name] = _defaultValues[segmentIndex] ?? String.empty
                    }
                } else {
                    values[parameter.name] = _defaultValues[segmentIndex] ?? String.empty
                }
                return true
            }

            // 普通参数：直接捕获当前段，或使用默认值
            let requestSegment = requestSegments[requestIndex]
            if (requestSegment.size > 0) {
                values[parameter.name] = requestSegment
            } else if (_hasDefaultValue[segmentIndex]) {
                values[parameter.name] = _defaultValues[segmentIndex] ?? String.empty
            }
        }

        return false
    }

    /**
     * 将 PathString 按 '/' 分割为各路径段列表。
     *
     * 自动跳过前导 '/'（正常路径必须以 '/' 开头），
     * 保留中间空字符串（来自连续 '//'，由调用方检测并返回 false）。
     *
     * @param path 请求路径。
     * @return 各路径段的列表；'/' 或空路径返回空列表。
     */
    private static func tokenizePath(path: PathString): ArrayList<String> {
        let result = ArrayList<String>()
        let pathStr = path.value
        // 跳过前导 '/'（PathString 规定非空路径必须以 '/' 开头）
        let offset: Int64 = if (pathStr.size > 0 && pathStr[0] == b'/') {
            1
        } else {
            0
        }
        let rest = pathStr[offset..]
        if (rest.isEmpty()) {
            // "/" 或空路径：返回空列表（路由段从剩余默认值中补充）
            return result
        }
        for (part in rest.split("/")) {
            result.add(part)
        }
        return result
    }

    // =========================================================================
    // 静态辅助方法：复合段匹配（多子段，如 {controller}.{action?}）
    // =========================================================================

    /**
     * 匹配复合路径段（包含多个字面量/参数子段）。
     *
     * 若末尾参数为可选，先尝试含末尾参数的完整匹配，失败后再尝试省略该参数的匹配。
     *
     * @param routeSegment   路由模式段。
     * @param requestSegment URL 对应段的字符串值。
     * @param values         接收路由值的字典。
     * @return 匹配成功返回 true。
     */
    public static func matchComplexSegment(
        routeSegment: RoutePatternPathSegment,
        requestSegment: String,
        values: RouteValueDictionary
    ): Bool {
        let indexOfLastSegment = routeSegment.parts.size - 1

        // 带有前导符的可选参数：{controller}.{action?}
        if (let parameter: RoutePatternParameterPart <- routeSegment.parts[indexOfLastSegment] && parameter.isOptional &&
            routeSegment.parts[indexOfLastSegment - 1].isSeparator) {
            if (matchComplexSegmentCore(routeSegment, requestSegment, values, indexOfLastSegment)) {
                return true
            } else if (let separator: RoutePatternSeparatorPart <- routeSegment.parts[indexOfLastSegment - 1]) {
                if (requestSegment.endsWith(separator.content)) {
                    return false
                }
            }
            return matchComplexSegmentCore(routeSegment, requestSegment, values, indexOfLastSegment - 2)
        } else {
            return matchComplexSegmentCore(routeSegment, requestSegment, values, indexOfLastSegment)
        }
    }

    /**
     * 复合段匹配的核心算法（从右向左逐步定位字面量，提取参数值）。
     *
     * @param routeSegment        路由模式段。
     * @param requestSegment      URL 段字符串。
     * @param values              接收路由值的字典。
     * @param indexOfLastSegment  本次匹配从该下标开始（向左扫描）。
     * @return 匹配成功返回 true。
     */
    private static func matchComplexSegmentCore(
        routeSegment: RoutePatternPathSegment,
        requestSegment: String,
        values: RouteValueDictionary,
        indexOfLastSegment: Int64
    ): Bool {
        var lastIndex = requestSegment.size
        let outValues = RouteValueDictionary()

        var indexOfLastSegmentUsed = indexOfLastSegment

        var lastLiteral: ?RoutePatternPart = None
        var parameterNeedsValue: ?RoutePatternParameterPart = None

        while (indexOfLastSegmentUsed >= 0) {
            var newLastIndex = lastIndex
            let part = routeSegment.parts[indexOfLastSegmentUsed]

            if (let part: RoutePatternParameterPart <- part) {
                parameterNeedsValue = part
            } else {
                lastLiteral = part

                var startIndex = lastIndex

                if (startIndex == 0) {
                    return false
                }

                if (parameterNeedsValue.isSome()) {
                    startIndex--
                }

                let indexOfLiteral: ?Int64 = if (let literal: RoutePatternLiteralPart <- part) {
                    requestSegment[0..startIndex].lastIndexOf(literal.content)
                } else if (let literal: RoutePatternSeparatorPart <- part) {
                    requestSegment[0..startIndex].lastIndexOf(literal.content)
                } else {
                    throw UnsupportedException()
                }

                if (let Some(indexOfLiteral) <- indexOfLiteral) {
                    if (indexOfLastSegmentUsed == (routeSegment.parts.size - 1)) {
                        if (let literal: RoutePatternLiteralPart <- part && ((indexOfLiteral + literal.content.size)) != requestSegment
                            .size) {
                            return false
                        } else if (let separator: RoutePatternSeparatorPart <- part &&
                            ((indexOfLiteral + separator.content.size)) != requestSegment.size) {
                            return false
                        }
                    }

                    newLastIndex = indexOfLiteral
                } else {
                    return false
                }
            }

            if ((let Some(parameter) <- parameterNeedsValue) && ((lastLiteral.isSome() && !part.isParameter) ||
                indexOfLastSegmentUsed == 0)) {
                let (parameterStartIndex, parameterTextLength) = if (lastLiteral.isNone()) {
                    let parameterStartIndex = if (indexOfLastSegmentUsed == 0) {
                        0
                    } else {
                        newLastIndex
                    }
                    (parameterStartIndex, lastIndex)
                } else {
                    if (indexOfLastSegmentUsed == 0 && part.isParameter) {
                        (0, lastIndex)
                    } else {
                        let parameterStartIndex = if ((let Some(lastLiteral) <- lastLiteral.flatMap {
                            f => f as RoutePatternLiteralPart
                        })) {
                            newLastIndex + lastLiteral.content.size
                        } else if ((let Some(lastLiteral) <- lastLiteral.flatMap {
                            f => f as RoutePatternSeparatorPart
                        })) {
                            newLastIndex + lastLiteral.content.size
                        } else {
                            throw UnsupportedException()
                        }
                        let parameterTextLength = lastIndex - parameterStartIndex
                        (parameterStartIndex, parameterTextLength)
                    }
                }

                let parameterValueSpan = requestSegment[parameterStartIndex..parameterStartIndex + parameterTextLength]

                if (parameterValueSpan.size == 0) {
                    return false
                } else {
                    outValues.add(parameter.name, parameterValueSpan)
                }

                parameterNeedsValue = None
                lastLiteral = None
            }

            lastIndex = newLastIndex
            indexOfLastSegmentUsed--
        }

        if (lastIndex == 0 || routeSegment.parts[0].isParameter) {
            for ((key, value) in outValues) {
                values[key] = value
            }
            return true
        }

        return false
    }
}

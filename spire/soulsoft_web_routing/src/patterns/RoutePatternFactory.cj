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
import soulsoft_web_routing.constraints.*
import soulsoft_web_routing.abstractions.*

private let EmptyHashMapValue = HashMap<String, ?String>(0)
private let EmptyParameterParts = ArrayList<RoutePatternParameterPart>(0)

/**
 * @brief 提供创建和组合路由模式的工厂方法。
 */
public class RoutePatternFactory {

    /**
     * @brief 解析路由模式字符串。
     * @param rawText 路由模式字符串。
     * @return 解析后的路由模式。
     */
    public static func parse(rawText: String): RoutePattern {
        RoutePatternParser.parse(rawText)
    }

    /**
     * @brief 解析路由模式字符串并附加必需值。
     * @param rawText 路由模式字符串。
     * @param requiredValues 路由必需值字典。
     * @return 解析后的路由模式。
     */
    public static func parse(rawText: String, requiredValues: RouteValueDictionary): RoutePattern {
        let original = RoutePatternParser.parse(rawText)
        return patternCore(original.rawText, original.defaults, wrap(original.parameterPolicies), requiredValues,
            original.pathSegments)
    }

    /**
     * @brief 解析路由模式字符串并附加默认值与参数策略。
     * @param rawText 路由模式字符串。
     * @param defaults 额外的默认值。
     * @param parameterPolicies 额外的参数策略字典。
     * @return 解析后的路由模式。
     */
    public static func parse(
        rawText: String,
        defaults: ?RouteValueDictionary,
        parameterPolicies: ?RouteValueDictionary
    ): RoutePattern {
        let original = RoutePatternParser.parse(rawText)
        return patternCore(original.rawText, toReadOnly(defaults), createPolicyReferences(parameterPolicies), None,
            original.pathSegments)
    }

    /**
     * @brief 解析路由模式字符串并附加默认值、参数策略和必需值。
     * @param rawText 路由模式字符串。
     * @param defaults 额外的默认值。
     * @param parameterPolicies 额外的参数策略字典。
     * @param requiredValues 额外的必需值字典。
     * @return 解析后的路由模式。
     */
    public static func parse(
        rawText: String,
        defaults: ?RouteValueDictionary,
        parameterPolicies: ?RouteValueDictionary,
        requiredValues: ?RouteValueDictionary
    ): RoutePattern {
        let original = RoutePatternParser.parse(rawText)
        return patternCore(original.rawText, toReadOnly(defaults), createPolicyReferences(parameterPolicies),
            requiredValues, original.pathSegments)
    }

    /**
     * @brief 从路径段集合创建路由模式。
     * @param segments 路径段集合。
     * @return 创建得到的路由模式。
     */
    public static func pattern(segments: Collection<RoutePatternPathSegment>): RoutePattern {
        patternCore(String.empty, None, HashMap<String, List<RoutePatternParameterPolicyReference>>(), None, segments)
    }

    /**
     * @brief 从原始文本和路径段集合创建路由模式。
     * @param rawText 路由原始文本。
     * @param segments 路径段集合。
     * @return 创建得到的路由模式。
     */
    public static func pattern(rawText: String, segments: Collection<RoutePatternPathSegment>): RoutePattern {
        patternCore(rawText, None, HashMap<String, List<RoutePatternParameterPolicyReference>>(), None, segments)
    }

    /**
     * @brief 从默认值、参数策略和路径段集合创建路由模式。
     * @param defaults 默认值字典。
     * @param parameterPolicies 参数策略字典。
     * @param segments 路径段集合。
     * @return 创建得到的路由模式。
     */
    public static func pattern(
        defaults: ?RouteValueDictionary,
        parameterPolicies: ?RouteValueDictionary,
        segments: Collection<RoutePatternPathSegment>
    ): RoutePattern {
        patternCore(String.empty, toReadOnly(defaults), createPolicyReferences(parameterPolicies), None, segments)
    }

    /**
     * @brief 从原始文本、默认值、参数策略和路径段集合创建路由模式。
     * @param rawText 路由原始文本。
     * @param defaults 默认值字典。
     * @param parameterPolicies 参数策略字典。
     * @param segments 路径段集合。
     * @return 创建得到的路由模式。
     */
    public static func pattern(
        rawText: ?String,
        defaults: ?RouteValueDictionary,
        parameterPolicies: ?RouteValueDictionary,
        segments: Collection<RoutePatternPathSegment>
    ): RoutePattern {
        patternCore(rawText ?? String.empty, toReadOnly(defaults), createPolicyReferences(parameterPolicies), None,
            segments)
    }

    /**
     * @brief 从路由片段集合创建路径段。
     * @param parts 路由片段集合。
     * @return 创建得到的路径段。
     */
    public static func segment(parts: Collection<RoutePatternPart>): RoutePatternPathSegment {
        RoutePatternPathSegment(parts |> collectArrayList)
    }

    /**
     * @brief 从路由片段数组创建路径段。
     * @param parts 路由片段数组。
     * @return 创建得到的路径段。
     */
    public static func segment(parts: Array<RoutePatternPart>): RoutePatternPathSegment {
        RoutePatternPathSegment(ArrayList<RoutePatternPart>(parts))
    }

    /**
     * @brief 创建字面量片段。
     * @param content 字面量内容。
     * @return 创建得到的字面量片段。
     * @throws IllegalArgumentException 当字面量包含非法字符时抛出。
     */
    public static func literalPart(content: String): RoutePatternLiteralPart {
        if (content.contains('?')) {
            throw IllegalArgumentException(
                "The literal section '${content}' is invalid. Literal sections cannot contain the '?' character.")
        }
        return literalPartCore(content)
    }

    /**
     * @brief 创建分隔符片段。
     * @param content 分隔符内容。
     * @return 创建得到的分隔符片段。
     */
    public static func separatorPart(content: String): RoutePatternSeparatorPart {
        return separatorPartCore(content)
    }

    /**
     * @brief 创建标准参数片段。
     * @param parameterName 参数名称。
     * @return 创建得到的参数片段。
     */
    public static func parameterPart(parameterName: String): RoutePatternParameterPart {
        validateParameterName(parameterName)
        return parameterPartCore(parameterName, None, RoutePatternParameterKind.Standard, [])
    }

    /**
     * @brief 创建带默认值的标准参数片段。
     * @param parameterName 参数名。
     * @param default 内联默认值。
     * @return 创建得到的参数片段。
     */
    public static func parameterPart(parameterName: String, default: ?String): RoutePatternParameterPart {
        validateParameterName(parameterName)
        return parameterPartCore(parameterName, default, RoutePatternParameterKind.Standard, [])
    }

    /**
     * @brief 创建带默认值和参数种类的参数片段。
     * @param parameterName 参数名。
     * @param default 内联默认值。
     * @param parameterKind 参数类型（Standard / Optional / CatchAll）。
     * @return 创建得到的参数片段。
     * @throws IllegalArgumentException 当可选参数配置默认值时抛出。
     */
    public static func parameterPart(
        parameterName: String,
        default: ?String,
        parameterKind: RoutePatternParameterKind
    ): RoutePatternParameterPart {
        validateParameterName(parameterName)
        if (default.isSome() && parameterKind == RoutePatternParameterKind.Optional) {
            throw IllegalArgumentException("An optional parameter cannot have default value.")
        }
        return parameterPartCore(parameterName, default, parameterKind, [])
    }

    /**
     * @brief 创建带策略数组的参数片段。
     * @param parameterName 参数名。
     * @param default 内联默认值。
     * @param parameterKind 参数类型（Standard / Optional / CatchAll）。
     * @param parameterPolicies 参数约束引用列表（Array）。
     * @return 创建得到的参数片段。
     * @throws IllegalArgumentException 当可选参数配置默认值时抛出。
     */
    public static func parameterPart(
        parameterName: String,
        default: ?String,
        parameterKind: RoutePatternParameterKind,
        parameterPolicies: Array<RoutePatternParameterPolicyReference>
    ): RoutePatternParameterPart {
        validateParameterName(parameterName)
        if (default.isSome() && parameterKind == RoutePatternParameterKind.Optional) {
            throw IllegalArgumentException("An optional parameter cannot have default value.")
        }
        return parameterPartCore(parameterName, default, parameterKind, parameterPolicies)
    }

    /**
     * @brief 创建带策略集合的参数片段。
     * @param parameterName 参数名。
     * @param default 内联默认值。
     * @param parameterKind 参数类型（Standard / Optional / CatchAll）。
     * @param parameterPolicies 参数约束引用集合（Collection）。
     * @return 创建得到的参数片段。
     * @throws IllegalArgumentException 当可选参数配置默认值时抛出。
     */
    public static func parameterPart(
        parameterName: String,
        default: ?String,
        parameterKind: RoutePatternParameterKind,
        parameterPolicies: Collection<RoutePatternParameterPolicyReference>
    ): RoutePatternParameterPart {
        validateParameterName(parameterName)
        if (default.isSome() && parameterKind == RoutePatternParameterKind.Optional) {
            throw IllegalArgumentException("An optional parameter cannot have default value.")
        }
        return parameterPartCore(parameterName, default, parameterKind, parameterPolicies |> collectArray)
    }

    /**
     * @brief 从字符串创建约束策略引用。
     * @param content 约束文本。
     * @return 创建得到的参数策略引用。
     * @throws IllegalArgumentException 当内容为空时抛出。
     */
    public static func constraint(content: String): RoutePatternParameterPolicyReference {
        if (content.isEmpty()) {
            throw IllegalArgumentException("content must not be empty.")
        }
        return parameterPolicyCore(content)
    }

    /**
     * @brief 从约束实例创建参数策略引用。
     * @param constraint 路由约束实例。
     * @return 创建得到的参数策略引用。
     */
    public static func constraint(constraint: IRouteConstraint): RoutePatternParameterPolicyReference {
        return parameterPolicyCore(constraint)
    }

    /**
     * @brief 从字符串创建参数策略引用。
     * @param parameterPolicy 参数策略文本。
     * @return 创建得到的参数策略引用。
     */
    public static func parameterPolicy(parameterPolicy: String): RoutePatternParameterPolicyReference {
        parameterPolicyCore(parameterPolicy)
    }

    /**
     * @brief 从参数策略实例创建参数策略引用。
     * @param parameterPolicy 参数策略实例。
     * @return 创建得到的参数策略引用。
     */
    public static func parameterPolicy(parameterPolicy: IParameterPolicy): RoutePatternParameterPolicyReference {
        return parameterPolicyCore(parameterPolicy)
    }

    /**
     * @brief 合并两个路由模式。
     * @param left 左侧路由模式（可为 None，表示无前缀）。
     * @param right 右侧路由模式。
     * @return 合并后的 RoutePattern。
     * @throws RoutePatternException 当合并过程中出现重复参数或冲突键时抛出。
     */
    public static func combine(left: ?RoutePattern, right: RoutePattern): RoutePattern {
        if (left.isNone()) {
            return right
        }
        let l = left.getOrThrow()

        let rawText = trimTrailingSlash(l.rawText) + "/" + trimLeadingSlash(right.rawText)

        // 合并参数，检查重名（大小写不敏感）
        let paramNames = HashSet<String>()
        let allParams = ArrayList<RoutePatternParameterPart>()
        for (i in 0..l.parameters.size) {
            let p = l.parameters[i]
            if (!paramNames.add(p.name.toAsciiLower())) {
                throw RoutePatternException(rawText, "Route contains a repeated parameter '${p.name}'.")
            }
            allParams.add(p)
        }
        for (i in 0..right.parameters.size) {
            let p = right.parameters[i]
            if (!paramNames.add(p.name.toAsciiLower())) {
                throw RoutePatternException(rawText, "Route contains a repeated parameter '${p.name}'.")
            }
            allParams.add(p)
        }

        // 合并路径段
        let allSegments = ArrayList<RoutePatternPathSegment>()
        for (i in 0..l.pathSegments.size) {
            allSegments.add(l.pathSegments[i])
        }
        for (i in 0..right.pathSegments.size) {
            allSegments.add(right.pathSegments[i])
        }

        let defaults = combineMaps(l.defaults, right.defaults, rawText, "defaults")
        let requiredValues = combineMaps(l.requiredValues, right.requiredValues, rawText, "requiredValues")
        let parameterPolicies = combinePolicies(l.parameterPolicies, right.parameterPolicies, rawText)

        return RoutePattern(rawText, defaults, parameterPolicies, requiredValues, allParams, allSegments)
    }

    // ──────────────────────────────────────────────────────────────────────
    // private core helpers
    // ──────────────────────────────────────────────────────────────────────

    private static func literalPartCore(content: String): RoutePatternLiteralPart {
        return RoutePatternLiteralPart(content)
    }

    private static func separatorPartCore(content: String): RoutePatternSeparatorPart {
        return RoutePatternSeparatorPart(content)
    }

    private static func parameterPolicyCore(parameterPolicy: String): RoutePatternParameterPolicyReference {
        return RoutePatternParameterPolicyReference(parameterPolicy)
    }

    private static func parameterPolicyCore(parameterPolicy: IParameterPolicy): RoutePatternParameterPolicyReference {
        return RoutePatternParameterPolicyReference(parameterPolicy)
    }

    private static func parameterPartCore(
        parameterName: String,
        default: ?String,
        parameterKind: RoutePatternParameterKind,
        parameterPolicies: Array<RoutePatternParameterPolicyReference>
    ): RoutePatternParameterPart {
        return parameterPartCore(parameterName, default, parameterKind, parameterPolicies, true)
    }

    private static func parameterPartCore(
        parameterName: String,
        default: ?String,
        parameterKind: RoutePatternParameterKind,
        parameterPolicies: Array<RoutePatternParameterPolicyReference>,
        encodeSlashes: Bool
    ): RoutePatternParameterPart {
        return RoutePatternParameterPart(parameterName, default, parameterKind, parameterPolicies, encodeSlashes)
    }

    /**
     * 校验参数名合法性，非法时抛出 IllegalArgumentException。
     */
    private static func validateParameterName(name: String): Unit {
        if (name.isEmpty() || (RoutePatternParser.InvalidParameterNameChars |> any {f => name.contains(f)})) {
            throw IllegalArgumentException(
                "The route parameter name '${name}' is invalid. Route parameter names must be non-empty and cannot contain these characters: '{{', '}}', '/'. The '?' character marks a parameter as optional, and can occur only at the end of the parameter. The '*' character marks a parameter as catch-all, and can occur only at the start of the parameter.")
        }
    }

    /**
     * 将 ?RouteValueDictionary 形式的 parameterPolicies 转换为内部格式。
     */
    private static func createPolicyReferences(parameterPolicies: ?RouteValueDictionary): HashMap<String, List<RoutePatternParameterPolicyReference>> {
        let result = HashMap<String, List<RoutePatternParameterPolicyReference>>()
        if (let Some(policies) <- parameterPolicies) {
            for ((key, value) in policies) {
                if (!value.isEmpty()) {
                    let refs = ArrayList<RoutePatternParameterPolicyReference>()
                    refs.add(parameterPolicyCore(RegexRouteConstraint("^(" + value + ")$")))
                    result.add(key, refs)
                }
            }
        }
        return result
    }

    /**
     * 将 ReadOnlyMap 形式的 parameterPolicies 转换为可变 HashMap（用于 parse 后合并）。
     */
    private static func wrap(parameterPolicies: ReadOnlyMap<String, ReadOnlyList<RoutePatternParameterPolicyReference>>): HashMap<String,
        List<RoutePatternParameterPolicyReference>> {
        let result = HashMap<String, List<RoutePatternParameterPolicyReference>>()
        for ((key, values) in parameterPolicies) {
            result.add(key, ArrayList<RoutePatternParameterPolicyReference>(values))
        }
        return result
    }

    /**
     * 合并两个 ReadOnlyMap<String, ?String>（defaults 或 requiredValues）。
     *
     * 若同一键在两端存在不同值则抛出异常；其中一端为空时直接返回另一端。
     */
    private static func combineMaps(
        left: ReadOnlyMap<String, ?String>,
        right: ReadOnlyMap<String, ?String>,
        rawText: String,
        dictionaryName: String
    ): ReadOnlyMap<String, ?String> {
        if (left.size == 0) {
            return right
        }
        if (right.size == 0) {
            return left
        }

        let combined = HashMap<String, ?String>(left.size + right.size)
        for ((key, value) in left) {
            combined.add(key, value)
        }
        for ((key, rightValue) in right) {
            if (let Some(leftValue) <- combined.get(key)) {
                if (leftValue != rightValue) {
                    throw IllegalArgumentException(
                        "Route '${rawText}': '${dictionaryName}' contains key '${key}' with conflicting values in left and right patterns.")
                }
            } else {
                combined.add(key, rightValue)
            }
        }
        return combined
    }

    /**
     * 合并两个 parameterPolicies 映射（ReadOnlyMap<String, ReadOnlyList<...>>）。
     *
     * 对齐 C# CombineDictionaries 行为：
     *   - 同键且为同一引用（refEq）→ 保留已有值，不报错
     *   - 同键但引用不同          → 抛出 IllegalArgumentException
     *
     * C# 注释原文："Technically, the ParameterPolicies could probably be merged
     * because it's a list, but it makes little sense to add policy for the same
     * parameter in both the left and right part of the combined pattern."
     * 因此与 defaults/requiredValues 使用同一 CombineDictionaries 泛型实现，
     * 仅在值不等（非同引用）时抛异常。
     */
    private static func combinePolicies(
        left: ReadOnlyMap<String, ReadOnlyList<RoutePatternParameterPolicyReference>>,
        right: ReadOnlyMap<String, ReadOnlyList<RoutePatternParameterPolicyReference>>,
        rawText: String
    ): ReadOnlyMap<String, ReadOnlyList<RoutePatternParameterPolicyReference>> {
        if (left.size == 0) {
            return right
        }
        if (right.size == 0) {
            return left
        }

        let combined = HashMap<String, ReadOnlyList<RoutePatternParameterPolicyReference>>(left.size + right.size)
        for ((key, value) in left) {
            combined.add(key, value)
        }
        for ((key, rightValue) in right) {
            if (let Some(leftValue) <- combined.get(key)) {
                if (!refEq((leftValue as Object).getOrThrow(), (rightValue as Object).getOrThrow())) {
                    throw IllegalArgumentException(
                        "Route '${rawText}': 'parameterPolicies' contains key '${key}' with conflicting policy lists in left and right patterns.")
                }
            } else {
                combined.add(key, rightValue)
            }
        }
        return combined
    }

    /**
     * 将 ?RouteValueDictionary 显式转换为 ?ReadOnlyMap<String, ?String>。
     *
     * RouteValueDictionary 存储 String 值，转换时包为 Some(String) 以适配路由模式元数据类型。
     */
    private static func toReadOnly(d: ?RouteValueDictionary): ?ReadOnlyMap<String, ?String> {
        match (d) {
            case Some(m) =>
                let result = HashMap<String, ?String>(m.size)
                for ((k, v) in m) {
                    result.add(k, v)
                }
                Some<ReadOnlyMap<String, ?String>>(result)
            case None => None
        }
    }

    /** 移除字符串末尾的 '/' 字符（最多移除一个）。 */
    private static func trimTrailingSlash(s: String): String {
        if (s.size > 0 && s[s.size - 1] == b'/') {
            return s[0..s.size - 1]
        }
        return s
    }

    /** 移除字符串开头的 '/' 字符（最多移除一个）。 */
    private static func trimLeadingSlash(s: String): String {
        if (s.size > 0 && s[0] == b'/') {
            return s[1..s.size]
        }
        return s
    }

    // ──────────────────────────────────────────────────────────────────────
    // patternCore（主构建逻辑，不变）
    // ──────────────────────────────────────────────────────────────────────

    private static func patternCore(
        rawText: String,
        defaults: ?ReadOnlyMap<String, ?String>,
        parameterPolicyReferences: HashMap<String, List<RoutePatternParameterPolicyReference>>,
        requiredValues: ?RouteValueDictionary,
        segments: Collection<RoutePatternPathSegment>
    ): RoutePattern {
        var updatedDefaults: ?HashMap<String, ?String> = None

        func visitPart(part: RoutePatternPart): RoutePatternPart {
            if (!part.isParameter) {
                return part
            }

            let parameter = (part as RoutePatternParameterPart).getOrThrow()
            var default = parameter.default

            if (let Some(Some(newDefault)) <- updatedDefaults.flatMap {f => f.get(parameter.name)}) {
                if (let Some(default) <- parameter.default && default != newDefault) {
                    throw UnsupportedException(
                        "The route parameter '${parameter.name}' has both an inline default value and an explicit default value specified. A route parameter cannot contain an inline default value when a default value is specified explicitly. Consider removing one of them.")
                }

                if (parameter.isOptional) {
                    throw UnsupportedException("An optional parameter cannot have default value.")
                }

                default = newDefault
            }
            if (let Some(default) <- parameter.default) {
                if (updatedDefaults.isNone()) {
                    updatedDefaults = HashMap<String, ?String>()
                }
                if (let Some(d) <- updatedDefaults) {
                    d[parameter.name] = default
                }
            }

            var parameterConstraints: ?ArrayList<RoutePatternParameterPolicyReference> = None
            if ((parameterPolicyReferences.size == 0 || !parameterPolicyReferences.contains(parameter.name)) &&
                parameter.parameterPolicies.size > 0) {
                parameterConstraints = ArrayList<RoutePatternParameterPolicyReference>(parameter.parameterPolicies.size)
                parameterPolicyReferences.add(parameter.name, parameterConstraints.getOrThrow())
            }

            if (parameter.parameterPolicies.size > 0) {
                parameterConstraints?.add(all: parameter.parameterPolicies)
            }

            if (parameter.default == default && parameter.parameterPolicies.size == 0 &&
                (parameterConstraints?.size ?? 0) == 0) {
                return part
            }

            return parameterPartCore(parameter.name, default, parameter.parameterKind,
                parameterConstraints?.toArray() ?? [], parameter.encodeSlashes)
        }

        func visitSegment(segment: RoutePatternPathSegment): RoutePatternPathSegment {
            var updatedParts: ?ArrayList<RoutePatternPart> = None
            for (i in 0..segment.parts.size) {
                let part = segment.parts[i]
                let updatedPart = visitPart(part)

                if (!refEq(part, updatedPart)) {
                    if (updatedParts.isNone()) {
                        updatedParts = segment.parts |> collectArrayList
                    }

                    updatedParts.flatMap {f => f[i] = updatedPart}
                }
            }

            if (updatedParts.isNone()) {
                return segment
            }
            return RoutePatternPathSegment(updatedParts ?? ArrayList<RoutePatternPart>())
        }

        if ((let Some(defaults) <- defaults) && defaults.size > 0) {
            updatedDefaults = HashMap<String, ?String>(defaults.size)
            for ((key, value) in defaults) {
                updatedDefaults?.add(key, value)
            }
        }

        var parameters: ?ArrayList<RoutePatternParameterPart> = None
        let updatedSegments = segments.toArray()
        for (i in 0..updatedSegments.size) {
            let pattern = updatedSegments[i]
            let segment = visitSegment(pattern)
            updatedSegments[i] = segment

            for (j in 0..segment.parts.size) {
                let part = segment.parts[j]
                if (let parameter: RoutePatternParameterPart <- part) {
                    parameters = parameters ?? ArrayList<RoutePatternParameterPart>()
                    parameters?.add(parameter)
                }
            }
        }

        if (let Some(requiredValues) <- requiredValues) {
            for ((key, value) in requiredValues) {
                // 1. required value 为 null/空（对应 C# Equals("", value)）
                var found = RouteValueEqualityComparer.default.equals(None, value)

                // 2. 路由模式中存在同名参数（大小写不敏感）
                if (!found && let Some(parameters) <- parameters) {
                    for (index in 0..parameters.size) {
                        let parameter = parameters[index]
                        if (key.equalsIgnoreAsciiCase(parameter.name)) {
                            found = true
                            break
                        }
                    }
                }

                // 3. 与已有 default 值匹配（null/"" 等价，大小写不敏感）
                if (!found) {
                    if (let Some(defaults) <- updatedDefaults) {
                        if (let Some(defaultValue) <- defaults.get(key)) {
                            if (RouteValueEqualityComparer.default.equals(value, defaultValue)) {
                                found = true
                            }
                        }
                    }
                }

                if (!found) {
                    throw UnsupportedException(
                        "No corresponding parameter or default value could be found for the required value'${key}=${value}'. A non-null required value must correspond to a route parameter or the route pattern must have a matching default value.")
                }
            }
        }

        let parameterPolicies = parameterPolicyReferences |>
            map {f => (f[0], (f[1] as ReadOnlyList<RoutePatternParameterPolicyReference>).getOrThrow())} |>
            collectHashMap

        return RoutePattern(rawText, updatedDefaults ?? EmptyHashMapValue, parameterPolicies,
            if (let Some(requiredValues) <- requiredValues) {
                let rvMap = HashMap<String, ?String>(requiredValues.size)
                for ((k, v) in requiredValues) {
                    rvMap.add(k, v)
                }
                rvMap
            } else {
                EmptyHashMapValue
            }, parameters ?? EmptyParameterParts, updatedSegments |> collectArrayList)
    }
}

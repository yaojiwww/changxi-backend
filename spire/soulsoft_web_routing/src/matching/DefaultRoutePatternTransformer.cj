// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_routing.matching

import std.collection.*
import soulsoft_web_http.*
import soulsoft_web_routing.patterns.*
import soulsoft_web_routing.abstractions.*

/**
 * RoutePatternTransformer 的默认实现，依赖 ParameterPolicyFactory 完成约束验证。
 *
 * 核心逻辑：
 *   对每个 required value 依次判断（null-ish / RequiredValueAny / 对应参数 / 对应 default），
 *   任一条件不满足则拒绝；全部通过后构建新的 RoutePattern，移除与 required value
 *   冲突的 inline default，并合并原有 requiredValues。
 */
class DefaultRoutePatternTransformer <: RoutePatternTransformer {
    private let _policyFactory: ParameterPolicyFactory

    init(policyFactory: ParameterPolicyFactory) {
        _policyFactory = policyFactory
    }

    /**
     * 尝试将 requiredValues 替换到 original 路由模式中。
     *
     * 四种通过条件（按顺序）：
     *   1. required value 为 null/空 → 对应键不能是参数，且已有 default 必须也为 null/空
     *   2. required value 是 RequiredValueAny 哨兵 → 对应键若无参数，已有 default 不能为非空
     *   3. required value 对应一个参数 → 验证参数约束
     *   4. required value 与已有 default 相同 → 验证约束
     *
     * @param original 原始路由模式。
     * @param requiredValues 要替换的 required values 字典（会被修改以合并原有值）。
     * @return 替换成功返回新的 RoutePattern，失败返回 None。
     */
    public override func substituteRequiredValues(
        original: RoutePattern,
        requiredValues: RouteValueDictionary
    ): ?RoutePattern {
        // ——— 第一遍：校验阶段 ———
        for ((key, value) in requiredValues) {
            if (isNullish(value)) {
                // 情况 1：null/空值
                if (original.getParameter(key).isSome()) {
                    // 路由参数不能被 required 为 null
                    return None
                }
                if (let Some(Some(defaultValue)) <- original.defaults.get(key)) {
                    if (!isNullish(Some(defaultValue))) {
                        // 已有非空 default，与 null required value 冲突
                        return None
                    }
                }
            } else if (RoutePattern.isRequiredValueAny(value)) {
                // 情况 2：RequiredValueAny 哨兵
                if (original.getParameter(key).isNone()) {
                    if (let Some(Some(defaultValue)) <- original.defaults.get(key)) {
                        if (!isNullish(Some(defaultValue))) {
                            // 非参数 default 比 *any* 更严格，不允许
                            return None
                        }
                    }
                }
            } else if (let Some(parameter) <- original.getParameter(key)) {
                // 情况 3：对应参数
                if (!matchesConstraints(original, parameter, key, requiredValues)) {
                    return None
                }
            } else if (let Some(Some(defaultValue)) <- original.defaults.get(key)) {
                // 情况 4：与已有 default 值相同
                if (value == defaultValue) {
                    if (!matchesConstraints(original, None, key, requiredValues)) {
                        return None
                    }
                } else {
                    // default 存在但值不匹配，拒绝
                    return None
                }
            } else {
                // 对应键在路由中完全不存在
                return None
            }
        }

        // ——— 第二遍：构建阶段（惰性初始化，仅在有变更时创建新结构）———
        var updatedParameters: ?ArrayList<RoutePatternParameterPart> = None
        var updatedSegments: ?ArrayList<RoutePatternPathSegment> = None
        var updatedDefaults: ?HashMap<String, ?String> = None

        for ((key, value) in requiredValues) {
            if (let Some(parameter) <- original.getParameter(key)) {
                // 若 required value 不是 *any*，且与已有 default 不同，则移除 inline default
                if (!RoutePattern.isRequiredValueAny(value)) {
                    if (let Some(Some(defaultValue)) <- original.defaults.get(key)) {
                        if (value != defaultValue) {
                            if (updatedDefaults.isNone()) {
                                let copy = HashMap<String, ?String>(original.defaults.size)
                                for ((k, v) in original.defaults) {
                                    copy.add(k, v)
                                }
                                updatedDefaults = copy
                                updatedSegments = ArrayList<RoutePatternPathSegment>(original.pathSegments)
                                updatedParameters = ArrayList<RoutePatternParameterPart>(original.parameters)
                            }
                            updatedDefaults?.remove(key)
                            removeParameterDefault(
                                updatedSegments.getOrThrow(),
                                updatedParameters.getOrThrow(),
                                parameter
                            )
                        }
                    }
                }
            }
        }

        // 合并原有 requiredValues（不覆盖本次传入的值）
        for ((key, value) in original.requiredValues) {
            requiredValues.addIfAbsent(key, value ?? String.empty)
        }

        // 将 RouteValueDictionary（String 值）转为路由模式元数据所需的 ReadOnlyMap<String, ?String>
        let rvMap = HashMap<String, ?String>(requiredValues.size)
        for ((k, v) in requiredValues) {
            rvMap.add(k, Some(v))
        }

        return RoutePattern(
            original.rawText,
            updatedDefaults ?? original.defaults,
            original.parameterPolicies,
            rvMap,
            updatedParameters ?? original.parameters,
            updatedSegments ?? original.pathSegments
        )
    }

    /**
     * 验证 requiredValues[key] 是否满足路由参数的所有 IRouteConstraint 约束。
     *
     * 情况 4（parameter 为 None）时使用合成的 ParameterPart 参与验证，
     * 与情况 3 保持一致，对齐 C# 原版行为。
     *
     * @param pattern        路由模式。
     * @param parameter      对应的参数部分（情况 4 时为 None）。
     * @param key            路由键名。
     * @param requiredValues 当前 required values（直接传递给约束验证）。
     * @return 所有约束均通过返回 true，任一约束失败返回 false。
     */
    private func matchesConstraints(
        pattern: RoutePattern,
        parameter: ?RoutePatternParameterPart,
        key: String,
        requiredValues: RouteValueDictionary
    ): Bool {
        if (let Some(policies) <- pattern.parameterPolicies.get(key)) {
            let param = parameter ?? RoutePatternParameterPart(
                key,
                None,
                RoutePatternParameterKind.Standard,
                []
            )
            for (i in 0..policies.size) {
                if (let constraint: IRouteConstraint <- _policyFactory.create(param, policies[i])) {
                    if (!constraint.isMatch(None, key, requiredValues)) {
                        return false
                    }
                }
            }
        }
        return true
    }

    /**
     * 从 segments 和 parameters 列表中移除指定参数的 inline default 值，
     * 用新建的无 default 参数替换并更新 segments 列表。
     *
     * 由于同一参数在路由中只出现一次，找到后立即返回。
     *
     * @param segments   可变路径段列表（原地修改）。
     * @param parameters 可变参数列表（原地修改）。
     * @param parameter  需要移除 default 的目标参数。
     */
    private static func removeParameterDefault(
        segments: ArrayList<RoutePatternPathSegment>,
        parameters: ArrayList<RoutePatternParameterPart>,
        parameter: RoutePatternParameterPart
    ): Unit {
        for (i in 0..segments.size) {
            let segment = segments[i]
            for (j in 0..segment.parts.size) {
                if (refEq(parameter, segment.parts[j])) {
                    // 重建去除 default 的参数
                    let updatedParameter = RoutePatternFactory.parameterPart(
                        parameter.name,
                        None,
                        parameter.parameterKind,
                        parameter.parameterPolicies
                    )
                    let updatedParts = ArrayList<RoutePatternPart>(segment.parts)
                    updatedParts[j] = updatedParameter
                    segments[i] = RoutePatternFactory.segment(updatedParts)

                    // 同步更新 parameters 列表
                    for (k in 0..parameters.size) {
                        if (refEq(parameter, parameters[k])) {
                            parameters[k] = updatedParameter
                            break
                        }
                    }
                    return
                }
            }
        }
    }

    /**
     * 判断 required value 是否为 null/空（与 null 等价）。
     *
     * @param value 待判断的值。
     * @return None 或 Some("") 时返回 true。
     */
    private static func isNullish(value: ?String): Bool {
        match (value) {
            case None => true
            case Some(v) => v.size == 0
        }
    }
}

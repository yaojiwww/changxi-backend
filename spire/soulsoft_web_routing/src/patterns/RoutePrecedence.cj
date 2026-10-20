// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_routing.patterns

import std.math.numeric.Decimal

/**
 * 路由优先级计算工具，对应 C# 的 RoutePrecedence。
 *
 * Inbound（入站）优先级用于路由匹配排序：数值越小优先级越高。
 * Outbound（出站）优先级用于 URL 生成排序：数值越大优先级越高。
 *
 * 算法：每个 segment 对应一个优先级位数（1-5），
 * 合并公式为 digit₀ + digit₁/10 + digit₂/100 + …（十进制小数）。
 *
 * 与 C# decimal 的对应关系：
 *   std.math.numeric.Decimal 为任意精度十进制数，精度上不受 28 位限制，
 *   MAX_SEGMENT_COUNT = 28 与 C# 保持一致。
 *
 * Inbound 位数含义（1 = 最高优先）：
 *   1 — 字面量 / 有非空 required value 的参数
 *   2 — 带约束的参数 / 多子段复合段
 *   3 — 无约束普通参数
 *   4 — 带约束的 catch-all 参数
 *   5 — 无约束 catch-all 参数
 *
 * Outbound 位数含义（5 = 最高优先）：
 *   5 — 字面量
 *   4 — 多子段复合段 / 带约束的普通参数
 *   3 — 无约束普通参数
 *   2 — 带约束的 catch-all 参数
 *   1 — 无约束 catch-all 参数
 */
protected class RoutePrecedence {

    // 与 C# 对齐：segment 超过 28 时视为不支持
    private static let MAX_SEGMENT_COUNT = 28

    /**
     * 计算路由模式的入站优先级（用于路由匹配排序）。
     *
     * @param routePattern 路由模式。
     * @return 入站优先级（Decimal，对应 C# decimal）。
     */
    public static func computeInbound(routePattern: RoutePattern): Decimal {
        validateSegmentLength(routePattern.pathSegments.size)
        var precedence = Decimal(0)
        var divisor = Decimal(1)
        for (i in 0..routePattern.pathSegments.size) {
            let segment = routePattern.pathSegments[i]
            let digit = Decimal(computeInboundPrecedenceDigit(routePattern, segment))
            precedence = precedence + digit / divisor
            divisor = divisor * Decimal(10)
        }
        return precedence
    }

    /**
     * 计算路由模式的出站优先级（用于 URL 生成排序）。
     *
     * @param routePattern 路由模式。
     * @return 出站优先级（Decimal，对应 C# decimal）。
     */
    public static func computeOutbound(routePattern: RoutePattern): Decimal {
        validateSegmentLength(routePattern.pathSegments.size)
        var precedence = Decimal(0)
        var divisor = Decimal(1)
        for (i in 0..routePattern.pathSegments.size) {
            let segment = routePattern.pathSegments[i]
            let digit = Decimal(computeOutboundPrecedenceDigit(segment))
            precedence = precedence + digit / divisor
            divisor = divisor * Decimal(10)
        }
        return precedence
    }

    /**
     * 计算单个路径段的入站优先级位数（1-5）。
     *
     * 有非空 required value 的参数与字面量等价，优先级位数为 1。
     *
     * @param routePattern 路由模式（用于查询 requiredValues）。
     * @param pathSegment  路径段。
     * @return 优先级位数（1 最高，5 最低）。
     */
    public static func computeInboundPrecedenceDigit(
        routePattern: RoutePattern,
        pathSegment: RoutePatternPathSegment
    ): Int64 {
        if (pathSegment.parts.size > 1) {
            // 复合段（多子段）与带约束参数同级
            return 2
        }

        let part = pathSegment.parts[0]

        if (part.isLiteral) {
            return 1
        } else if (let parameterPart: RoutePatternParameterPart <- part) {
            // 有非空 required value 的参数按字面量处理（对应 C# required value 机制）
            if (let Some(requiredValue) <- routePattern.requiredValues.get(parameterPart.name)) {
                if (!RouteValueEqualityComparer.default.equals(requiredValue, None)) {
                    return 1
                }
            }

            // 5（unconstrained catch-all）或 3（unconstrained parameter）
            var digit: Int64 = if (parameterPart.isCatchAll) { 5 } else { 3 }

            // 有约束时降低优先级位数（数值减 1 → 优先级提升）
            // 带约束参数 → 2，带约束 catch-all → 4
            if (parameterPart.parameterPolicies.size > 0) {
                digit--
            }

            return digit
        } else {
            throw UnsupportedException()
        }
    }

    /**
     * 计算单个路径段的出站优先级位数（1-5）。
     *
     * @param pathSegment 路径段。
     * @return 优先级位数（5 最高，1 最低）。
     */
    private static func computeOutboundPrecedenceDigit(pathSegment: RoutePatternPathSegment): Int64 {
        if (pathSegment.parts.size > 1) {
            // 复合段与带约束参数同级
            return 4
        }

        let part = pathSegment.parts[0]

        if (part.isLiteral) {
            return 5
        } else if (let parameterPart: RoutePatternParameterPart <- part) {
            // 1（unconstrained catch-all）或 3（unconstrained parameter）
            var digit: Int64 = if (parameterPart.isCatchAll) { 1 } else { 3 }

            // 有约束时提升优先级位数（数值加 1 → 优先级提升）
            // 带约束参数 → 4，带约束 catch-all → 2
            if (parameterPart.parameterPolicies.size > 0) {
                digit++
            }

            return digit
        } else {
            throw UnsupportedException()
        }
    }

    /**
     * 校验 segment 数量不超过上限（超过时 Float64 精度不足以区分各位）。
     *
     * @param count segment 数量。
     */
    private static func validateSegmentLength(count: Int64): Unit {
        if (count > MAX_SEGMENT_COUNT) {
            throw UnsupportedException(
                "Route exceeds the maximum number of allowed segments of ${MAX_SEGMENT_COUNT} and is unable to be processed.")
        }
    }
}

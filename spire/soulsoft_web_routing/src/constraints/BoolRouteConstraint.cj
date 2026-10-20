// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_routing.constraints

import std.convert.*
import soulsoft_web_http.*
import soulsoft_web_routing.abstractions.*

/**
 * @brief 表示布尔类型路由约束。
 */
public class BoolRouteConstraint <: IRouteConstraint & IParameterLiteralNodeMatchingPolicy & ICachableParameterPolicy {
    /**
     * @brief 检查字面量值是否满足布尔约束。
     * @param _ 未使用的参数名称。
     * @param literal 路由字面量值。
     * @return 满足布尔解析规则时返回 true。
     */
    public func matchesLiteral(_: String, literal: ?String): Bool {
        if (let Some(v) <- literal) {
            return checkConstraintCore(v)
        }
        return false
    }

    /**
     * @brief 检查路由值字典中的值是否满足布尔约束。
     * @param _ 当前 HTTP 上下文。
     * @param routeKey 路由值键名。
     * @param values 路由值字典。
     * @return 满足布尔解析规则时返回 true。
     */
    public func isMatch(_: ?HttpContext, routeKey: String, values: RouteValueDictionary): Bool {
        if (let Some(v) <- values.get(routeKey)) {
            return checkConstraintCore(v)
        }
        return false
    }

    private func checkConstraintCore(value: String): Bool {
        return Bool.tryParse(value.toAsciiLower()).isSome()
    }

    /**
     * @brief 返回当前约束的调试字符串。
     * @return 约束名称。
     */
    public func toString(): String {
        "BoolRouteConstraint"
    }
}

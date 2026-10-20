// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_routing.constraints

import std.regex.*
import soulsoft_web_http.*
import soulsoft_web_routing.abstractions.*

/**
 * @brief 表示基于正则表达式的路由约束。
 * @description 当路由值存在且非空时，使用给定正则表达式验证其内容。
 */
public class RegexRouteConstraint <: IRouteConstraint {
    private let _pattern: String
    private let _regex: Regex

    /**
     * @brief 创建一个正则表达式路由约束。
     * @param regexPattern 正则表达式字符串。
     */
    public init(regexPattern: String) {
        _pattern = regexPattern
        _regex = Regex(regexPattern, [IgnoreCase])
    }

    /**
     * @brief 返回原始正则表达式字符串。
     * @return 约束使用的正则表达式。
     */
    public prop pattern: String {
        get() {
            _pattern
        }
    }

    /**
     * @brief 检查路由值字典中的值是否满足正则表达式约束。
     * @param _ 当前 HTTP 上下文。
     * @param routeKey 路由值键名。
     * @param values 路由值字典。
     * @return 匹配正则表达式时返回 true。
     */
    public func isMatch(_: ?HttpContext, routeKey: String, values: RouteValueDictionary): Bool {
        if (let Some(value) <- values.get(routeKey)) {
            return _regex.matches(value)
        }
        return false
    }
}

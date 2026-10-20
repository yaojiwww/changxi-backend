// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_routing.patterns

import std.collection.*
import std.math.numeric.Decimal

private let EMPTY_DEFAULTS = HashMap<String, ?String>(0)

/**
 * 用于 requiredValues 中标记"任意非空值均可匹配"的哨兵字符串。
 *
 * 不应将此值与普通路由值混用；请通过 RoutePattern.isRequiredValueAny() 判断。
 * 注：C# 原版使用独立 class 实例作为哨兵（引用相等），CJ 中以此特殊字符串替代。
 */
private let REQUIRED_VALUE_ANY_SENTINEL = "\u{200B}RouteValueAny\u{200B}"

/**
 * @brief 表示解析后的路由模式。
 */
public class RoutePattern {
    private let _rawText: String
    private let _defaults: ?ReadOnlyMap<String, ?String>
    private let _parameterPolicies: ReadOnlyMap<String, ReadOnlyList<RoutePatternParameterPolicyReference>>
    private let _requiredValues: ReadOnlyMap<String, ?String>
    private let _parameters: ReadOnlyList<RoutePatternParameterPart>
    private let _pathSegments: ReadOnlyList<RoutePatternPathSegment>
    private var _inboundPrecedence = Decimal(0)
    private var _outboundPrecedence = Decimal(0)

    /**
     * @brief 创建解析后的路由模式实例。
     * @param rawText 原始路由模板文本。
     * @param defaults 路由参数默认值映射。
     * @param parameterPolicies 路由参数策略映射。
     * @param requiredValues 路由必需值映射。
     * @param parameters 路由参数片段集合。
     * @param pathSegments 路由路径段集合。
     */
    protected RoutePattern(rawText: String, defaults: ?ReadOnlyMap<String, ?String>,
        parameterPolicies: ReadOnlyMap<String, ReadOnlyList<RoutePatternParameterPolicyReference>>,
        requiredValues: ReadOnlyMap<String, ?String>, parameters: ReadOnlyList<RoutePatternParameterPart>,
        pathSegments: ReadOnlyList<RoutePatternPathSegment>) {
        _rawText = rawText
        _defaults = defaults
        _parameterPolicies = parameterPolicies
        _requiredValues = requiredValues
        _parameters = parameters
        _pathSegments = pathSegments
        // 构造时缓存优先级，避免每次匹配/生成 URL 时重复计算
        _inboundPrecedence = RoutePrecedence.computeInbound(this)
        _outboundPrecedence = RoutePrecedence.computeOutbound(this)
    }

    /**
     * @brief 用于显示的路由 URL 文本。
     */
    public var displayText: ?String = None

    /**
     * @brief 返回 requiredValues 中表示任意非空值的哨兵值。
     * @return requiredValues 的任意值哨兵字符串。
     */
    public static prop requiredValueAny: String {
        get() {
            REQUIRED_VALUE_ANY_SENTINEL
        }
    }

    /**
     * @brief 检查给定值是否为 RequiredValueAny 哨兵。
     * @param value 待判断的 required value。
     * @return 若为哨兵字符串返回 true，否则返回 false。
     */
    public static func isRequiredValueAny(value: ?String): Bool {
        if (let Some(v) <- value) {
            return v == REQUIRED_VALUE_ANY_SENTINEL
        }
        return false
    }

    /**
     * @brief 按名称查找路由参数片段。
     * @param name 参数名称。
     * @return 匹配的参数片段；不存在时返回 None。
     */
    public func getParameter(name: String): ?RoutePatternParameterPart {
        for (index in 0.._parameters.size) {
            let parameter = _parameters[index]
            if (parameter.name == name) {
                return parameter
            }
        }
        return None
    }

    /**
     * @brief 返回原始路由模板文本。
     * @return 原始路由模板字符串。
     */
    public prop rawText: String {
        get() {
            _rawText
        }
    }

    /**
     * @brief 返回路由参数默认值字典。
     * @return 参数默认值映射。
     */
    public prop defaults: ReadOnlyMap<String, ?String> {
        get() {
            _defaults ?? EMPTY_DEFAULTS
        }
    }

    /**
     * @brief 返回路由参数策略字典。
     * @return 参数策略映射。
     */
    public prop parameterPolicies: ReadOnlyMap<String, ReadOnlyList<RoutePatternParameterPolicyReference>> {
        get() {
            _parameterPolicies
        }
    }

    /**
     * @brief 返回路由必需值字典。
     * @return 必需值映射。
     */
    public prop requiredValues: ReadOnlyMap<String, ?String> {
        get() {
            _requiredValues
        }
    }

    /**
     * @brief 返回路由中定义的参数片段列表。
     * @return 参数片段集合。
     */
    public prop parameters: ReadOnlyList<RoutePatternParameterPart> {
        get() {
            _parameters
        }
    }

    /**
     * @brief 返回路由的路径段列表。
     * @return 路径段集合。
     */
    public prop pathSegments: ReadOnlyList<RoutePatternPathSegment> {
        get() {
            _pathSegments
        }
    }

    /**
     * @brief 返回路由的入站优先级。
     * @return 路由匹配排序使用的入站优先级值。
     */
    public prop inboundPrecedence: Decimal {
        get() {
            _inboundPrecedence
        }
    }

    /**
     * @brief 返回路由的出站优先级。
     * @return URL 生成排序使用的出站优先级值。
     */
    public prop outboundPrecedence: Decimal {
        get() {
            _outboundPrecedence
        }
    }

    protected func debuggerToString(): String {
        RoutePatternDebugStringFormatter.format(this)
    }
}

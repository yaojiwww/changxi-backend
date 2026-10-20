// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_routing.patterns

import soulsoft_web_routing.constraints.*

/**
 * @brief 表示路由模式中的参数片段。
 */
public class RoutePatternParameterPart <: RoutePatternPart {
    private let _name: String
    private let _default: ?String
    private let _parameterKind: RoutePatternParameterKind
    private let _parameterPolicies: Array<RoutePatternParameterPolicyReference>
    private let _encodeSlashes: Bool

    /**
     * @brief 创建一个路由参数片段。
     * @param name 参数名称。
     * @param default 参数默认值。
     * @param parameterKind 参数种类。
     * @param parameterPolicies 参数策略集合。
     * @param encodeSlashes 是否编码斜杠。
     */
    protected init(name: String, default: ?String, parameterKind: RoutePatternParameterKind,
        parameterPolicies: Array<RoutePatternParameterPolicyReference>, encodeSlashes: Bool) {
        super(RoutePatternPartKind.Parameter)
        _name = name
        _default = default
        _parameterKind = parameterKind
        _parameterPolicies = parameterPolicies
        _encodeSlashes = encodeSlashes
    }

    /**
     * @brief 创建一个默认启用斜杠编码的路由参数片段。
     * @param name 参数名称。
     * @param default 参数默认值。
     * @param kind 参数种类。
     * @param policies 参数策略集合。
     */
    protected init(name: String, default: ?String, kind: RoutePatternParameterKind,
        policies: Array<RoutePatternParameterPolicyReference>) {
        this(name, default, kind, policies, true)
    }

    /**
     * @brief 返回当前参数片段的名称。
     * @return 参数名称。
     */
    public prop name: String {
        get() {
            _name
        }
    }

    /**
     * @brief 返回当前参数片段的默认值。
     * @return 参数默认值；不存在时返回 None。
     */
    public prop default: ?String {
        get() {
            _default
        }
    }

    /**
     * @brief 返回当前参数片段的种类。
     * @return 参数种类。
     */
    public prop parameterKind: RoutePatternParameterKind {
        get() {
            _parameterKind
        }
    }

    /**
     * @brief 返回当前参数片段绑定的参数策略列表。
     * @return 参数策略引用数组。
     */
    public prop parameterPolicies: Array<RoutePatternParameterPolicyReference> {
        get() {
            _parameterPolicies
        }
    }

    /**
     * @brief 返回当前参数片段是否编码斜杠。
     * @return 需要编码斜杠时返回 true。
     */
    public prop encodeSlashes: Bool {
        get() {
            _encodeSlashes
        }
    }

    /**
     * @brief 检查当前参数片段是否为捕获所有参数。
     * @return 为捕获所有参数时返回 true。
     */
    public prop isCatchAll: Bool {
        get() {
            parameterKind.isCatchAll()
        }
    }

    /**
     * @brief 检查当前参数片段是否为可选参数。
     * @return 为可选参数时返回 true。
     */
    public prop isOptional: Bool {
        get() {
            parameterKind.isOptional()
        }
    }

    protected func debuggerToString() {
        let builder = StringBuilder()
        builder.append('{')

        if (isCatchAll) {
            builder.append('*')
            if (!encodeSlashes) {
                builder.append('*')
            }
        }

        builder.append(name)

        for (index in 0..parameterPolicies.size) {
            let ref = parameterPolicies[index]
            builder.append(':')
            if (let Some(content) <- ref.content) {
                // 字符串形式（如 "int"、"range(1,100)"、"regex([0-9]+)"）
                builder.append(content)
            } else if (let Some(policy) <- ref.parameterPolicy) {
                if (let regexConstraint: RegexRouteConstraint <- policy) {
                    // RegexRouteConstraint 特殊展示为 regex(pattern)
                    builder.append("regex(")
                    builder.append(regexConstraint.pattern)
                    builder.append(')')
                } else {
                    builder.append(policy)
                }
            }
        }

        if (let Some(default) <- default.flatMap {f => f as ToString}) {
            builder.append('=')
            builder.append(default)
        }

        if (isOptional) {
            builder.append('?')
        }

        builder.append('}')
        return builder.toString()
    }
}

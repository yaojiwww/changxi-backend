// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_routing.matching

import std.collection.*
import soulsoft_web_routing.patterns.*
import soulsoft_web_routing.constraints.*
import soulsoft_web_routing.abstractions.*

/**
 * @brief 定义参数策略创建工厂的抽象基类。
 */
public abstract class ParameterPolicyFactory {
    /**
     * @brief 根据内联文本创建参数策略。
     * @param parameter 路由参数片段。
     * @param inlineText 策略内联文本。
     * @return 创建得到的参数策略。
     */
    public func create(parameter: RoutePatternParameterPart, inlineText: String): IParameterPolicy
    /**
     * @brief 根据现有参数策略实例创建参数策略。
     * @param parameter 路由参数片段。
     * @param parameterPolicy 现有参数策略实例。
     * @return 创建得到的参数策略。
     */
    public func create(parameter: RoutePatternParameterPart, parameterPolicy: IParameterPolicy): IParameterPolicy

    /**
     * @brief 根据参数策略引用创建参数策略。
     * @param parameter 路由参数片段。
     * @param reference 参数策略引用。
     * @return 创建得到的参数策略。
     */
    public func create(parameter: RoutePatternParameterPart, reference: RoutePatternParameterPolicyReference): IParameterPolicy {
        if (let Some(parameterPolicy) <- reference.parameterPolicy) {
            return create(parameter, parameterPolicy)
        }

        if (let Some(content) <- reference.content) {
            return create(parameter, content)
        }

        throw UnsupportedException()
    }
}

protected class DefaultParameterPolicyFactory <: ParameterPolicyFactory {
    public func create(parameter: RoutePatternParameterPart, inlineText: String): IParameterPolicy {
        if (inlineText == "int") {
            return IntRouteConstraint()
        }
        if (inlineText == "bool") {
            return BoolRouteConstraint()
        }
        if (inlineText == "float") {
            return FloatRouteConstraint()
        }
        // regex(pattern) — 解析括号内的正则表达式
        if (inlineText.startsWith("regex(") && inlineText.endsWith(")")) {
            let pattern = inlineText[6..inlineText.size - 1]
            return RegexRouteConstraint(pattern)
        }
        return throw UnsupportedException(
            "The constraint reference '${inlineText}' could not be resolved to a type. Register the constraint type with 'RouteOptions.constraintMap'.")
    }

    public func create(parameter: RoutePatternParameterPart, parameterPolicy: IParameterPolicy): IParameterPolicy {
        return parameterPolicy
    }
}

/*
对 ParameterPolicyFactory 的缓存包装层，对应 C# DfaMatcherBuilder.CachingParameterPolicyFactory。
仅缓存实现了 ICachableParameterPolicy 的无状态约束实例（按 inlineText 作为键）。
有状态约束（可能含评估计数等）不会被缓存，每次调用仍走 _inner 创建新实例。
DfaMatcherBuilder 是瞬态服务，每个实例持有独立的缓存。
*/
protected class CachingParameterPolicyFactory <: ParameterPolicyFactory {
    private let _inner: ParameterPolicyFactory
    private let _cache: HashMap<String, IParameterPolicy>

    init(inner: ParameterPolicyFactory) {
        _inner = inner
        _cache = HashMap<String, IParameterPolicy>()
    }

    public func create(parameter: RoutePatternParameterPart, inlineText: String): IParameterPolicy {
        // 缓存键大小写敏感：约束前缀（如 "regex"）不区分大小写，但参数（如正则内容）可能区分
        if (let Some(cached) <- _cache.get(inlineText)) {
            // 命中缓存：将已有实例交给 inner 处理（inner 可以根据 parameter 做可选包装等）
            return _inner.create(parameter, cached)
        }

        let policy = _inner.create(parameter, inlineText)

        // 仅缓存无状态约束（实现了 ICachableParameterPolicy 的）
        if (policy is ICachableParameterPolicy) {
            _cache[inlineText] = policy
        }

        return policy
    }

    public func create(parameter: RoutePatternParameterPart, parameterPolicy: IParameterPolicy): IParameterPolicy {
        return _inner.create(parameter, parameterPolicy)
    }
}

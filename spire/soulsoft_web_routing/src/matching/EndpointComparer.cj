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
import soulsoft_web_routing.http.*

/**
 * @brief 定义端点优先级比较接口。
 */
public interface IEndpointComparer {
    /**
     * @brief 比较两个端点的排序优先级。
     * @param x 第一个端点。
     * @param y 第二个端点。
     * @return 端点优先级比较结果。
     */
    func compare(x: Endpoint, y: Endpoint): Ordering
}

/**
 * @brief 定义可提供端点比较器的策略接口。
 */
public interface IEndpointComparerPolicy {
    /**
     * @brief 返回当前策略提供的端点比较器。
     * @return 端点比较器实例。
     */
    prop comparer: IEndpointComparer
}

/**
 * 端点比较器，对应 C# EndpointComparer。
 *
 * 构造时接收所有 IEndpointComparerPolicy 实现，按以下优先级链式比较：
 *   1. PrecedenceComparer（inboundPrecedence，内置首位）
 *   2. 各策略注入的比较器（按注册顺序）
 *
 * 实现 Comparable<EndpointComparer> 允许对比较器对象本身排序（按策略维度数量）。
 * 后续新增比较维度只需让对应策略实现 IEndpointComparerPolicy 即可，无需修改本类。
 */
protected class EndpointComparer <: IEndpointComparer {
    private let _comparers: Array<IEndpointComparer>

    public init(policies: Array<IEndpointComparerPolicy>) {
        let list = ArrayList<IEndpointComparer>()
        // PrecedenceComparer 始终是第一维比较
        list.add(PrecedenceComparer.instance)
        for (i in 0..policies.size) {
            list.add(policies[i].comparer)
        }
        _comparers = list.toArray()
    }

    /**
     * 比较两个端点的路由优先级。
     * RouteEndpoint 始终优先于普通 Endpoint；
     * 两者均为 RouteEndpoint 时依次调用各策略比较器。
     */
    public func compare(x: Endpoint, y: Endpoint): Ordering {
        if (x is RouteEndpoint && y is RouteEndpoint) {
            for (i in 0.._comparers.size) {
                let cmp = _comparers[i].compare(x, y)
                if (cmp != Ordering.EQ) {
                    return cmp
                }
            }
            return Ordering.EQ
        } else if (x is RouteEndpoint) {
            return Ordering.LT
        } else if (y is RouteEndpoint) {
            return Ordering.GT
        }
        return Ordering.EQ
    }
}

/**
 * 对应 C# EndpointComparer.PrecedenceComparer（内嵌私有类）。
 * 按 inboundPrecedence 升序排序：值越小优先级越高（更具体的路由先匹配）。
 */
protected class PrecedenceComparer <: IEndpointComparer {
    static let instance: IEndpointComparer = PrecedenceComparer()

    public func compare(x: Endpoint, y: Endpoint): Ordering {
        if (let rx: RouteEndpoint <- x && let ry: RouteEndpoint <- y) {
            return rx.routePattern.inboundPrecedence.compare(ry.routePattern.inboundPrecedence)
        } else if (x is RouteEndpoint) {
            return Ordering.LT
        } else if (y is RouteEndpoint) {
            return Ordering.GT
        }
        return Ordering.EQ
    }
}

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_routing

import std.sync.*
import soulsoft_web_routing.matching.*

/**
 * @brief 提供基于端点数据源执行路由匹配的中间件。
 */
public class EndpointRoutingMiddleware <: IMiddleware {
    private let _lock = Mutex()
    private let _matcherFactory: MatcherFactory
    private let _endpointDataSource: EndpointDataSource
    private var _initializationTask: ?Future<Matcher> = None

    /**
     * @brief 创建一个端点路由匹配中间件。
     * @param builder 路由端点构建器。
     * @param matcherFactory 匹配器工厂。
     */
    public init(builder: EndpointRouteBuilder, matcherFactory: MatcherFactory) {
        _matcherFactory = matcherFactory
        _endpointDataSource = CompositeEndpointDataSource(builder.dataSources)
    }

    /**
     * @brief 对当前请求执行端点匹配。
     * @param context 当前 HTTP 上下文。
     * @param next 下一个请求委托。
     */
    public func invoke(context: HttpContext, next: RequestDelegate): Unit {
        let matcher = getOrCreateTask().get()
        if (context.getEndpoint().isNone()) {
            matcher.invoke(context)
        }
        next(context)
    }

    /*
    锁内只做 spawn（微秒级），DFA 状态机构建在 Future 内异步完成。
    其他并发线程在锁外调用 .get() 等待同一个 Future，不阻塞 Mutex。
     */
    private func getOrCreateTask(): Future<Matcher> {
        if (let Some(task) <- _initializationTask) {
            return task
        }
        synchronized(_lock) {
            if (let Some(task) <- _initializationTask) {
                return task
            }
            let task = spawn {
                let matcher = _matcherFactory.createMatcher(_endpointDataSource)
                // matcher.debuggerToString() |> println
                return matcher
            }
            _initializationTask = task
            return task
        }
    }
}

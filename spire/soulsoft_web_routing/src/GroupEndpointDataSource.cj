// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_routing

import std.collection.*
import soulsoft_web_routing.patterns.*

/**
 * 路由组的端点数据源
 *
 * 注册在外部 EndpointRouteBuilder.dataSources 中，负责：
 *   1. 将分组前缀（partialPrefix）合并到组内所有端点的路由模式
 *   2. 将分组约定（groupConventions）传递给组内数据源的 getGroupedEndpoints
 *   3. 支持嵌套分组（递归传递 context.prefix 和 context.conventions）
 */
class GroupEndpointDataSource <: EndpointDataSource {
    private let _groupBuilder: RouteGroupBuilder

    init(groupBuilder: RouteGroupBuilder) {
        _groupBuilder = groupBuilder
    }

    /**
     * @brief 返回当前路由组生成的端点列表。
     * @return 应用分组前缀和约定后的端点集合。
     */
    public prop endpoints: ReadOnlyList<Endpoint> {
        get() {
            // 顶层调用：无外部前缀，无外部约定
            getGroupedEndpointsWithNullablePrefix(
                None,
                ArrayList<(EndpointBuilder) -> Unit>(),
                _groupBuilder.services
            )
        }
    }

    /**
     * @brief 根据路由组上下文生成端点列表。
     * @param context 路由组上下文。
     * @return 应用外部前缀和约定后的端点集合。
     */
    public override func getGroupedEndpoints(context: RouteGroupContext): ReadOnlyList<Endpoint> {
        getGroupedEndpointsWithNullablePrefix(context.prefix, context.conventions, context.services)
    }

    private func getGroupedEndpointsWithNullablePrefix(
        outerPrefix: ?RoutePattern,
        outerConventions: ArrayList<(EndpointBuilder) -> Unit>,
        services: IServiceProvider
    ): ReadOnlyList<Endpoint> {
        // 合并外部前缀（来自祖先组）与本组前缀
        let fullPrefix = RoutePatternFactory.combine(outerPrefix, _groupBuilder.partialPrefix)

        // 合并约定：外部约定在前（低优先级），本组约定在后
        let combinedConventions = ArrayList<(EndpointBuilder) -> Unit>()
        for (c in outerConventions) {
            combinedConventions.add(c)
        }
        for (c in _groupBuilder.groupConventions) {
            combinedConventions.add(c)
        }

        let context = RouteGroupContext(Some(fullPrefix), combinedConventions, services)
        let result = ArrayList<Endpoint>()
        for (dataSource in _groupBuilder.dataSources) {
            let endpoints = dataSource.getGroupedEndpoints(context)
            for (endpoint in endpoints) {
                result.add(endpoint)
            }
        }
        return result
    }
}

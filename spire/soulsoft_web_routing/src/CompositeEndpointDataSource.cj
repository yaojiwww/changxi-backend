// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_routing

import std.sync.*
import std.collection.*

/**
 * @brief 表示聚合多个端点数据源的组合数据源。
 * @description 该类型会按需汇总所有内部数据源暴露的端点列表，并缓存聚合结果。
 */
public class CompositeEndpointDataSource <: EndpointDataSource {
    private let _lock = Mutex()
    private var _endpoints: ?ArrayList<Endpoint> = None
    private let _endpointDataSources: Collection<EndpointDataSource>

    init(endpointDataSources: Collection<EndpointDataSource>) {
        _endpointDataSources = endpointDataSources
    }

    /**
     * @brief 返回组合后的端点列表。
     * @return 所有内部端点数据源导出的端点集合。
     */
    public prop endpoints: ReadOnlyList<Endpoint> {
        get() {
            initialize()
            return _endpoints.getOrThrow()
        }
    }

    private func initialize() {
        if (_endpoints.isSome()) {
            return
        } else {
            synchronized(_lock) {
                if (_endpoints.isSome()) {
                    return
                }
                updateEndpoints()
            }
        }
    }

    private func updateEndpoints() {
        let endpoints = ArrayList<Endpoint>()
        for (endpoint in _endpointDataSources |> flatMap {m => m.endpoints}) {
            endpoints.add(endpoint)
        }
        _endpoints = endpoints
    }
}

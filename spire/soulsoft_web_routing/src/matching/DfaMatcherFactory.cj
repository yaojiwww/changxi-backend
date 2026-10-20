// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_routing.matching

import std.collection.*
import soulsoft_web_routing.http.*
import soulsoft_extensions_injection.*

protected class DfaMatcherFactory <: MatcherFactory {
    private let _services: IServiceProvider

    public init(services: IServiceProvider) {
        _services = services
    }

    public func createMatcher(dataSource: EndpointDataSource): Matcher {
        let policies = _services.getAll<INodeBuilderPolicy>() |> collectArrayList
        let endpointSelector = _services.getOrThrow<EndpointSelector>()
        let parameterPolicyFactory = _services.getOrThrow<ParameterPolicyFactory>()
        
        //创建dfa构建器
        let builder = DfaMatcherBuilder(endpointSelector, parameterPolicyFactory, policies)

        //添加终结点
        for (endpoint in dataSource.endpoints |> filterMap {f => f as RouteEndpoint}) {
            builder.addEndpoint(endpoint)
        }
        return builder.build()
    }
}

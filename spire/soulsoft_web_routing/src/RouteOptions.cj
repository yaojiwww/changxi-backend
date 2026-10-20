// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_routing

import std.collection.*

/**
 * @brief 表示端点路由系统的配置选项。
 */
public class RouteOptions {
    private let _endpointDataSources = HashSet<EndpointDataSource>()

    /**
     * @brief 返回当前注册的端点数据源集合。
     * @return 端点数据源集合。
     */
    public prop endpointDataSources: HashSet<EndpointDataSource> {
        get() {
            _endpointDataSources
        }
    }
}

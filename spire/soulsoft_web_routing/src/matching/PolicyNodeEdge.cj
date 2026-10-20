// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_routing.matching

import soulsoft_web_http.*
import std.collection.*

/**
 * @brief 表示策略节点上的一条边及其目标端点集合。
 */
public struct PolicyNodeEdge {
    /**
     * @brief 创建一条策略节点边。
     * @param state 当前边关联的状态对象。
     * @param endpoints 当前边可到达的端点集合。
     */
    public PolicyNodeEdge(let state: IEdgeState, let endpoints: ReadOnlyList<Endpoint>) {
    }
}

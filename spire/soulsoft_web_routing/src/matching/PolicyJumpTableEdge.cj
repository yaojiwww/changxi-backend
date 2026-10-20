// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_routing.matching

/**
 * @brief 表示策略跳转表中的一条边。
 */
public struct PolicyJumpTableEdge {
    /**
     * @brief 创建一条策略跳转表边。
     * @param state 当前边关联的状态对象。
     * @param destination 当前边指向的目标索引。
     */
    public PolicyJumpTableEdge(public let state: IEdgeState, public let destination: Int64) {

    }
}

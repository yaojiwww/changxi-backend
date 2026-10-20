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

/**
 * @brief 定义 DFA 策略节点构建接口。
 */
public interface INodeBuilderPolicy {
    /**
     * @brief 检查当前策略是否适用于给定端点列表。
     * @param endpoints 待评估的端点列表。
     * @return 适用时返回 true。
     */
    func appliesToEndpoints(endpoints: ReadOnlyList<Endpoint>): Bool

    /**
     * @brief 为给定端点列表生成策略边。
     * @param endpoints 待生成策略边的端点列表。
     * @return 生成的策略边集合。
     */
    func getEdges(endpoints: ReadOnlyList<Endpoint>): ReadOnlyList<PolicyNodeEdge>

    /**
     * @brief 根据策略边构建策略跳转表。
     * @param exitDestination 退出目标状态索引。
     * @param policyEntries 策略跳转表边集合。
     * @return 构建后的策略跳转表。
     */
    func buildJumpTable(exitDestination: Int64, policyEntries: ReadOnlyList<PolicyJumpTableEdge>): PolicyJumpTable
}

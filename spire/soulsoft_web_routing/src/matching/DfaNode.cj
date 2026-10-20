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

protected class DfaNode {
    private let _label: String
    private var _pathDepth: Int64
    private var _catchAll: ?DfaNode
    private var _parameters: ?DfaNode
    private var _matches: ?ArrayList<Endpoint> = None
    private var _nodeBuilder: ?INodeBuilderPolicy = None
    private var _literals: ?HashMap<String, DfaNode> = None
    private var _policyEdges: ?HashMap<IEdgeState, DfaNode> = None

    public init(label!: String, pathDepth!: Int64 = -1, catchAll!: ?DfaNode = None, parameters!: ?DfaNode = None) {
        _label = label
        _catchAll = catchAll
        _pathDepth = pathDepth
        _parameters = parameters
    }

    public prop label: String {
        get() {
            _label
        }
    }

    public prop pathDepth: Int64 {
        get() {
            _pathDepth
        }
    }

    public mut prop catchAll: ?DfaNode {
        get() {
            _catchAll
        }
        set(value) {
            _catchAll = value
        }
    }

    public mut prop parameters: ?DfaNode {
        get() {
            _parameters
        }
        set(value) {
            _parameters = value
        }
    }

    public prop matches: ?ArrayList<Endpoint> {
        get() {
            _matches
        }
    }

    public prop policyEdges: ?HashMap<IEdgeState, DfaNode> {
        get() {
            _policyEdges
        }
    }

    public prop literals: ?HashMap<String, DfaNode> {
        get() {
            _literals
        }
    }

    public mut prop nodeBuilder: ?INodeBuilderPolicy {
        get() {
            _nodeBuilder
        }
        set(value) {
            _nodeBuilder = value
        }
    }

    public func addMatch(endpoint: Endpoint) {
        if (let Some(matches) <- _matches) {
            matches.add(endpoint)
        } else {
            _matches = ArrayList<Endpoint>([endpoint])
        }
    }

    public func addMatches(endpoints: Collection<Endpoint>) {
        if (let Some(matches) <- _matches) {
            matches.add(all: endpoints)
        } else {
            _matches = ArrayList<Endpoint>(endpoints)
        }
    }

    public func addPolicyEdge(state: IEdgeState, node: DfaNode) {
        if (let Some(policyEdges) <- _policyEdges) {
            policyEdges.add(state, node)
        } else {
            _policyEdges = HashMap<IEdgeState, DfaNode>([(state, node)])
        }
    }

    public func addLiteral(literal: String, node: DfaNode) {
        if (let Some(literals) <- _literals) {
            literals[literal] = node
        } else {
            _literals = HashMap<String, DfaNode>([(literal, node)])
        }
    }

    public func visit(visitor: (DfaNode) -> Unit): Unit {
        if (let Some(literals) <- _literals) {
            for ((_, value) in literals) {
                value.visit(visitor)
            }
        }

        //!refEq(this, parameter)是为了防止递归
        if (let Some(parameters) <- _parameters && !refEq(this, parameters)) {
            parameters.visit(visitor)
        }

        //!refEq(this, catchAll)是为了防止递归
        if (let Some(catchAll) <- _catchAll && !refEq(this, catchAll)) {
            catchAll.visit(visitor)
        }

        if (let Some(policyEdges) <- _policyEdges && !refEq(this, policyEdges)) {
            for ((_, edge) in policyEdges) {
                edge.visit(visitor)
            }
        }

        visitor(this)
    }

     // 打印 DFA 节点树形结构
    public func print() {
        var result = StringBuilder()
        printWithIndent(result, "", true, HashSet<Int64>())
        result.toString() |> println
    }

    // 递归打印带缩进的节点信息
    private func printWithIndent(sb: StringBuilder, indent: String, isLast: Bool, visited: HashSet<Int64>): Unit {

        // 打印当前节点
        let prefix = if (isLast) { "└── " } else { "├── " }
        sb.append("${indent}${prefix}${_label}")
        sb.append(" [深度: ${_pathDepth}")

        // 添加匹配端点信息
        if (let Some(matches) <- _matches) {
            sb.append(", 匹配数: ${matches.size}")
        }
        sb.append("]\n")

        // 准备子节点缩进
        let childIndent = if (isLast) { indent + "    " } else { indent + "│   " }
        var childCount = 0

        // 统计子节点数量
        if (let Some(literals) <- _literals) {
            childCount += literals.size
        }
        if (let Some(parameters) <- _parameters && !refEq(this, parameters)) {
            childCount++
        }
        if (let Some(catchAll) <- _catchAll && !refEq(this, catchAll)) {
            childCount++
        }
        if (let Some(policyEdges) <- _policyEdges) {
            childCount += policyEdges.size
        }

        var currentChild = 0

        // 打印字面量子节点
        if (let Some(literals) <- _literals) {
            for ((key, node) in literals) {
                currentChild++
                sb.append("${childIndent}├── [字面量: ${key}]\n")
                node.printWithIndent(sb, childIndent + "│   ", currentChild == childCount, visited)
            }
        }

        // 打印参数节点
        if (let Some(parameters) <- _parameters && !refEq(this, parameters)) {
            currentChild++
            sb.append("${childIndent}├── [参数节点]\n")
            parameters.printWithIndent(sb, childIndent + "│   ", currentChild == childCount, visited)
        }

        // 打印捕获所有节点
        if (let Some(catchAll) <- _catchAll && !refEq(this, catchAll)) {
            currentChild++
            sb.append("${childIndent}├── [捕获所有]\n")
            catchAll.printWithIndent(sb, childIndent + "│   ", currentChild == childCount, visited)
        }

        // 打印策略边节点
        if (let Some(policyEdges) <- _policyEdges) {
            for ((state, node) in policyEdges) {
                currentChild++
                sb.append("${childIndent}├── [策略边: ${state.toString()}]\n")
                node.printWithIndent(sb, childIndent + "│   ", currentChild == childCount, visited)
            }
        }
    }
}

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_routing.matching

import std.sync.*
import std.sort.*
import std.collection.*
import soulsoft_web_http.*
import soulsoft_web_routing.http.*
import soulsoft_web_routing.patterns.*
import soulsoft_web_routing.abstractions.*

private let EMPTY_ENDPOINT_LIST = ArrayList<Endpoint>()

protected class DfaMatcherBuilder {
    private var _stateIndex = 0
    private let _endpointSelector: EndpointSelector
    private let _assignments = HashMap<String, Int64>()
    private let _endpoints = ArrayList<RouteEndpoint>()
    private let _slots = ArrayList<(String, String)>()

    private let _captures = ArrayList<(String, Int64, Int64)>()
    private let _nodeBuilders: ReadOnlyList<INodeBuilderPolicy>
    private let _parameterPolicyFactory: ParameterPolicyFactory
    private let _constraints = ArrayList<(String, IRouteConstraint)>()
    private let _complexSegments = ArrayList<(RoutePatternPathSegment, Int64)>()
    private let _comparer: EndpointComparer

    init(endpointSelector: EndpointSelector, parameterPolicyFactory: ParameterPolicyFactory,
        nodeBuilders: ReadOnlyList<INodeBuilderPolicy>) {
        _nodeBuilders = nodeBuilders
        _endpointSelector = endpointSelector
        // DfaMatcherBuilder 是瞬态服务，每个实例持有独立的约束缓存
        _parameterPolicyFactory = CachingParameterPolicyFactory(parameterPolicyFactory)
        _comparer = buildComparer(nodeBuilders)
    }

    public func addEndpoint(endpoint: RouteEndpoint) {
        _endpoints.add(endpoint)
    }

    // 从 INodeBuilderPolicy 列表中过滤出实现了 IEndpointComparerPolicy 的策略，构造 EndpointComparer
    private static func buildComparer(nodeBuilders: ReadOnlyList<INodeBuilderPolicy>): EndpointComparer {
        let policies = ArrayList<IEndpointComparerPolicy>()
        for (i in 0..nodeBuilders.size) {
            if (let p: IEndpointComparerPolicy <- nodeBuilders[i]) {
                policies.add(p)
            }
        }
        return EndpointComparer(policies.toArray())
    }

    public func build(): DfaMatcher {
        let root = buildDfaTree()
        //构建状态机
        let stateCount = AtomicInt64(1)
        let maxSegmentCount = AtomicInt64(0)
        root.visit {
            node =>
                stateCount.fetchAdd(1)
                maxSegmentCount.swap(max(maxSegmentCount.load(), node.pathDepth))
        }
        _stateIndex = 0
        let exitDestination = stateCount.load() - 1
        //默认全部设置为退出状态
        let exitState = DfaState(JumpTableBuilder.build(exitDestination, exitDestination, None), None)
        let states = Array<DfaState>(stateCount.load(), repeat: exitState)
        addNode(root, exitDestination, states)
        // maxSegmentCount + 1 ：捕获最深路由段之后的额外内容（如 catch-all 尾段）
        return DfaMatcher(_endpointSelector, states, maxSegmentCount.load() + 1)
    }

    private func buildDfaTree() {
        let root = DfaNode(label: "/", pathDepth: 0)
        let work = ArrayList<DfaBuilderWorkerWorkItem>(_endpoints.size)

        //初始化工作队列
        var maxDepth = 0
        for (index in 0.._endpoints.size) {
            let endpoint = _endpoints[index]
            let precedenceDigit = DfaBuilderWorker.getPrecedenceDigitAtDepth(endpoint, 0)
            work.add(DfaBuilderWorkerWorkItem(endpoint, precedenceDigit, ArrayList<DfaNode>([root])))
            maxDepth = max(maxDepth, endpoint.routePattern.pathSegments.size)
        }

        let dfaWorker = DfaBuilderWorker(work, _parameterPolicyFactory)

        for (depth in 0..maxDepth + 1) {
            dfaWorker.processLevel(depth)
        }
        //构建策略节点
        root.visit(applyPolicies)
        return root
    }

    private func addNode(node: DfaNode, exitDestination: Int64, states: Array<DfaState>): Int64 {
        // 对齐 C# ApplyPolicies line 886：node.Matches.Sort(_comparer)
        // EndpointComparer.compare 内含降序语义（ry.compare(rx)），高 inboundPrecedence 排在前面
        if (let Some(matches) <- node.matches) {
            sort(matches, by: {a: Endpoint, b: Endpoint => _comparer.compare(a, b)})
        }

        let currentStateIndex = _stateIndex
        // 默认跳转和退出跳转目标，初始为退出状态
        var currentDefaultDestination = exitDestination
        var currentExitDestination = exitDestination

        func transition(next: DfaNode): Int64 {
            // 如果跳转目标是自己，直接返回当前索引
            if (refEq(node, next)) {
                return _stateIndex
            } else {
                _stateIndex++
                return addNode(next, exitDestination, states)
            }
        }

        // 路径跳转项
        let pathEntries = if (let Some(literals) <- node.literals) {
            let entries = Array<(String, Int64)>(literals.size, repeat: (String.empty, 0))

            //生成跳转项
            for ((i, (key, value)) in literals |> enumerate) {
                entries[i] = (key, transition(value))
            }

            entries
        } else {
            Option<Array<(String, Int64)>>.None
        }

        // 只有catchall参数时，默认和退出都跳到该分支
        if (let Some(parameters) <- node.parameters && let Some(catchAll) <- node.catchAll && refEq(parameters, catchAll)) {
            currentDefaultDestination = transition(parameters)
            currentExitDestination = currentDefaultDestination
        } else if (let Some(parameters) <- node.parameters && let Some(catchAll) <- node.catchAll) {
            //当catchall参数和parameters参数都存在，但是不相等
            currentDefaultDestination = transition(parameters)
            currentExitDestination = transition(catchAll)
        } else if (let Some(parameters) <- node.parameters) {
            //当只有parameters参数存在，默认跳到参数
            currentDefaultDestination = transition(parameters)
        } else if (let Some(catchAll) <- node.catchAll) {
            // 只有catchall分支时，默认和退出都跳到catchall
            currentDefaultDestination = transition(catchAll)
            currentExitDestination = currentDefaultDestination
        }

        //构建策略分支集合
        let policyEntries: ?ArrayList<PolicyJumpTableEdge> = if (let Some(policyEdges) <- node.policyEdges &&
            policyEdges.size > 0) {
            let entries = ArrayList<PolicyJumpTableEdge>(policyEdges.size)
            for ((key, value) in policyEdges) {
                entries.add(PolicyJumpTableEdge(key, transition(value)))
            }
            entries
        } else {
            None
        }

        //生成候选集
        var candidates = createCandidates(node.matches)

        //生成当前状态
        let pathJumpTable = JumpTableBuilder.build(currentDefaultDestination, currentExitDestination, pathEntries) //路径跳转表
        let policyJumpTable = buildPolicyJumpTable(currentExitDestination, node.nodeBuilder, policyEntries)
        states[currentStateIndex] = DfaState(pathJumpTable, policyJumpTable, candidates)
        return currentStateIndex
    }

    private func applyPolicies(node: DfaNode): Unit {
        //跳过非终端节点
        if ((node.matches?.size ?? 0) == 0) {
            return
        }

        if (let Some(matches) <- node.matches) {
            sort(matches, by: {a: Endpoint, b: Endpoint => _comparer.compare(a, b)})
        }

        // 当前工作项
        var work = ArrayList<DfaNode>([node])
        //前一个工作项
        var previousWork: ?ArrayList<DfaNode> = None

        //使用每个策略构建器，计算

        for (index in 0.._nodeBuilders.size) {
            let nodeBuilder = _nodeBuilders[index]
            //准备下一个工作项，复用上一个工作列表边
            let nextWork = if (let Some(previousWork) <- previousWork) {
                previousWork.clear()
                previousWork
            } else {
                ArrayList<DfaNode>()
            }

            //使用当前策略构建器，处理当前工作项
            for (index in 0..work.size) {
                let parent = work[index]
                if (!nodeBuilder.appliesToEndpoints(parent.matches ?? ArrayList<Endpoint>())) {
                    //节点构建器不适用于当前节点，交由下一个节点构建器处理
                    nextWork.add(parent)
                    continue
                }

                // 该节点构建器确实适用于此节点，因此需要为每条边创建新节点
                // 然后将其附加到父节点上。
                let edges = nodeBuilder.getEdges(parent.matches ?? EMPTY_ENDPOINT_LIST)
                for (index in 0..edges.size) {
                    let edge = edges[index]
                    //新建节点
                    let next = DfaNode(label: "${parent.label} ${edge.state}")

                    if (edge.endpoints.size > 0) {
                        next.addMatches(edge.endpoints)
                    }
                    //待后续节点构建器处理
                    nextWork.add(next)
                    parent.addPolicyEdge(edge.state, next)
                }

                parent.nodeBuilder = nodeBuilder

                //父节点不再有匹配项，因此不被视为终端节点
                parent.matches?.clear()
            }

            //切换到下一层
            previousWork = work
            work = nextWork
        }
    }

    private func buildPolicyJumpTable(exitDestination: Int64, nodeBuilder: ?INodeBuilderPolicy,
        policyEntries: ?ArrayList<PolicyJumpTableEdge>): ?PolicyJumpTable {
        if (let Some(policyEntries) <- policyEntries && let Some(nodeBuilder) <- nodeBuilder) {
            return nodeBuilder.buildJumpTable(exitDestination, policyEntries)
        }
        return None
    }

    private func createCandidates(endpoints: ?ArrayList<Endpoint>): Array<Candidate> {
        if (let Some(endpoints) <- endpoints) {
            if (endpoints.size == 0) {
                return []
            }
            let candidates = ArrayList<Candidate>(endpoints.size)
            var score = 0
            // 以第一个端点为基准，只在优先级边界（不同 inboundPrecedence）才递增 score，
            // 相同优先级的端点共享同一 score，防止同级路由被错误区分
            var exemplar = endpoints[0]
            candidates.add(createCandidate(exemplar, score))
            for (index in 1..endpoints.size) {
                let endpoint = endpoints[index]
                if (_comparer.compare(exemplar, endpoint) != Ordering.EQ) {
                    score++
                    exemplar = endpoint
                }
                candidates.add(createCandidate(endpoint, score))
            }
            return candidates |> collectArray
        } else {
            return []
        }
    }

    private func createCandidate(endpoint: Endpoint, score: Int64): Candidate {
        if (let routeEndpoint: RouteEndpoint <- endpoint) {
            _slots.clear()
            _captures.clear()
            _assignments.clear()
            _constraints.clear()
            _complexSegments.clear()

            for ((key, value) in routeEndpoint.routePattern.defaults) {
                _assignments.add(key, _assignments.size)
                _slots.add((key, value ?? ""))
            }

            var catchAll: ?(parameterName: String, segmentIndex: Int64, slotIndex: Int64) = None

            // 简单路径段
            for (i in 0..routeEndpoint.routePattern.pathSegments.size) {
                let segment = routeEndpoint.routePattern.pathSegments[i]
                if (!segment.isSimple) {
                    continue
                }

                if (let parameterPart: RoutePatternParameterPart <- segment.parts[0]) {
                    var slotIndex = if (let Some(slotIndex) <- _assignments.get(parameterPart.name)) {
                        slotIndex
                    } else {
                        _assignments.size
                    }

                    if (!_assignments.contains(parameterPart.name)) {
                        slotIndex = _assignments.size
                        _assignments.add(parameterPart.name, slotIndex)
                        if (let Some(value) <- routeEndpoint.routePattern.requiredValues.get(parameterPart.name)) {
                            _slots.add((parameterPart.name, value ?? String.empty))
                        } else if (parameterPart.default.isSome() || parameterPart.isCatchAll) {
                            _slots.add((parameterPart.name, parameterPart.default ?? String.empty))
                        } else {
                            _slots.add((String.empty, String.empty))
                        }
                    }

                    if (routeEndpoint.routePattern.requiredValues.get(parameterPart.name).isSome()) {
                    // Don't capture a parameter if it has a required value
                    // There is no need because a parameter with a required value is matched as a literal
                    } else if (parameterPart.isCatchAll) {
                        catchAll = (parameterPart.name, i, slotIndex)
                    } else {
                        _captures.add((parameterPart.name, i, slotIndex))
                    }
                }
            }

            // 复杂路径段
            for (i in 0..routeEndpoint.routePattern.pathSegments.size) {
                let segment = routeEndpoint.routePattern.pathSegments[i]
                if (segment.isSimple) {
                    continue
                }
                _complexSegments.add((segment, i))
            }

            // 计算参数约束
            for ((parameterName, references) in routeEndpoint.routePattern.parameterPolicies) {
                if (let Some(parameterPart) <- routeEndpoint.routePattern.getParameter(parameterName)) {
                    for (reference in references) {
                        let parameterPolicy = _parameterPolicyFactory.create(parameterPart, reference)
                        if (let routeConstraint: IRouteConstraint <- parameterPolicy) {
                            _constraints.add((parameterName, routeConstraint))
                        }
                    }
                }
            }

            let slots = _slots.toArray()
            let captures = _captures.toArray()
            let constraints = _constraints.toArray()
            let complexSegments = _complexSegments.toArray()
            return Candidate(endpoint, score, slots, captures, constraints, complexSegments, catchAll)
        } else {
            return Candidate(endpoint, score, [], [], [], [], None)
        }
    }
}

class DfaBuilderWorker {
    private var _workCount: Int64
    private var _work: ArrayList<DfaBuilderWorkerWorkItem>
    private var _previousWork: ArrayList<DfaBuilderWorkerWorkItem>
    private let _parameterPolicyFactory: ParameterPolicyFactory

    init(work: ArrayList<DfaBuilderWorkerWorkItem>, parameterPolicyFactory: ParameterPolicyFactory) {
        _work = work
        _workCount = work.size
        _parameterPolicyFactory = parameterPolicyFactory
        _previousWork = ArrayList<DfaBuilderWorkerWorkItem>()
    }

    public func processLevel(depth: Int64) {
        let nextWork = _previousWork
        var nextWorkCount = 0
        sort(_work[0.._workCount])

        //处理当前工作队列
        for (i in 0.._workCount) {
            let (endpoint, parents) = _work[i].deconstruct()

            //确定该Dfa节点下是否可以挂载Endpoint
            if (!hasAdditionalRequiredSegments(endpoint, depth)) {
                for (i in 0..parents.size) {
                    let parent = parents[i]
                    parent.addMatch(endpoint)
                }
            }

            //准备下一层工作项
            let nextParents: ArrayList<DfaNode> = if (nextWorkCount < nextWork.size) {
                let nextParents = nextWork[nextWorkCount].parents
                //内存复用
                nextParents.clear()
                let precedenceDigit = getPrecedenceDigitAtDepth(endpoint, depth + 1)
                nextWork[nextWorkCount] = DfaBuilderWorkerWorkItem(endpoint, precedenceDigit, nextParents)
                nextParents
            } else {
                //新建工作项内存
                let nextParents = ArrayList<DfaNode>()
                let precedenceDigit = getPrecedenceDigitAtDepth(endpoint, depth + 1)
                nextWork.add(DfaBuilderWorkerWorkItem(endpoint, precedenceDigit, nextParents))
                nextParents
            }

            //处理当前段落
            if (let Some(segment) <- getCurrentSegment(endpoint, depth)) {

                //处理路径段
                processSegment(segment, endpoint, parents, nextParents)

                if (nextParents.size > 0) {
                    nextWorkCount++
                }
            }
        }

        _previousWork = _work
        _work = nextWork
        _workCount = nextWorkCount
    }

    private func processSegment(segment: RoutePatternPathSegment, endpoint: RouteEndpoint, parents: ArrayList<DfaNode>,
        nextParents: ArrayList<DfaNode>) {
        for (i in 0..parents.size) {
            let parent = parents[i]
            let part = segment.parts[0]
            let parameterPart = part as RoutePatternParameterPart
            if (segment.isSimple && let literalPart: RoutePatternLiteralPart <- part) {
                addLiteralNode(nextParents, parent, literalPart.content)
            } else if (segment.isSimple && let Some(parameterPart) <- parameterPart && parameterPart.isCatchAll) {
                //通配参数段
                // 将父节点的孩子节点挂载到当前节点，并且移动到下一层
                if (let Some(literals) <- parent.literals) {
                    nextParents.add(all: literals.values())
                }

                // 将父节点的孩子节点挂载到当前节点，并且移动到下一层
                if (let Some(parameters) <- parent.parameters) {
                    nextParents.add(parameters)
                }

                //通配参数的后续参数节点都将是自身
                if (parent.catchAll.isNone()) {
                    parent.catchAll = DfaNode(label: "${parent.label}{*...}/", pathDepth: parent.pathDepth + 1)
                    parent.catchAll?.catchAll = parent.catchAll
                    parent.catchAll?.parameters = parent.catchAll
                }

                parent.catchAll?.addMatch(endpoint)
            } else if (segment.isSimple && let Some(parameterPart) <- parameterPart && let Some(requiredValue) <- getRequiredValue(
                endpoint.routePattern, parameterPart)) {
                // 处理{controller=home}/{action=index}/{id?}
                addRequiredLiteralValue(endpoint, nextParents, parent, parameterPart, requiredValue);
            } else if (segment.isSimple && let Some(parameterPart) <- parameterPart) {
                // 简单参数路径段:{id:int}
                if (parent.parameters.isNone()) {
                    parent.parameters = DfaNode(label: "${parent.label}{*...}/", pathDepth: parent.pathDepth + 1)
                }
                //如果父节点存在文本分支
                if (let Some(literals) <- parent.literals) {
                    // 如果参数存在约束，那么将文本分支中满足约束条件的加入到下一层，来提高效率
                    let parameterPolicyReferences = endpoint.routePattern.parameterPolicies.get(parameterPart.name)
                    if (let Some(parameterPolicyReferences) <- parameterPolicyReferences) {
                        addParentsWithMatchingLiteralConstraints(nextParents, parent, parameterPart,
                            parameterPolicyReferences)
                    } else {
                        // 如果参数没有约束，则所有文本分支都需要遍历，因为无法确认
                        nextParents.add(all: literals.values())
                    }
                }
                nextParents.add(parent.parameters.getOrThrow())
            } else {
                // 复合段（complex segment，如 v{version}、{file}.{ext}）：
                if (parent.parameters.isNone()) {
                    parent.parameters = DfaNode(label: "${parent.label}{...}/", pathDepth: parent.pathDepth + 1)
                }
                if (let Some(literals) <- parent.literals) {
                    nextParents.add(all: literals.values())
                }
                nextParents.add(parent.parameters.getOrThrow())
            }
        }
    }

    private func addRequiredLiteralValue(endpoint: RouteEndpoint, nextParents: ArrayList<DfaNode>, parent: DfaNode,
        parameterPart: RoutePatternParameterPart, requiredValue: String) {
        var literalValue = requiredValue

        // 若参数上配置了 IOutboundParameterTransformer（如 slug 转换器），
        // 则先对 requiredValue 做转换，保证 DFA 节点使用与实际 URL 一致的字面量。
        if (let Some(policyRefs) <- endpoint.routePattern.parameterPolicies.get(parameterPart.name)) {
            for (i in 0..policyRefs.size) {
                let policy = _parameterPolicyFactory.create(parameterPart, policyRefs[i])
                if (let Some(transformer) <- (policy as IOutboundParameterTransformer)) {
                    if (let Some(transformed) <- transformer.transformOutbound(literalValue)) {
                        literalValue = transformed
                    }
                    break
                }
            }
        }

        addLiteralNode(nextParents, parent, literalValue)
    }

    private func addLiteralNode(nextParents: ArrayList<DfaNode>, parent: DfaNode, literal: String) {
        // trie 键统一小写，与 DfaMatcher.invoke 中 lowercasePath 查找对齐，实现大小写不敏感匹配
        let normalizedLiteral = literal.toAsciiLower()
        if (let Some(next) <- parent.literals.flatMap {f => f.get(normalizedLiteral)}) {
            nextParents.add(next)
        } else {
            let next = DfaNode(label: "${parent.label}${normalizedLiteral}/", pathDepth: parent.pathDepth + 1)
            parent.addLiteral(normalizedLiteral, next)
            nextParents.add(next)
        }
    }

    /*
    返回指定深度的路径段
     */
    private static func getCurrentSegment(endpoint: RouteEndpoint, depth: Int64): ?RoutePatternPathSegment {
        if (depth < endpoint.routePattern.pathSegments.size) {
            return endpoint.routePattern.pathSegments[depth]
        }

        if (endpoint.routePattern.pathSegments.size == 0) {
            return None
        }

        let lastSegment = endpoint.routePattern.pathSegments[endpoint.routePattern.pathSegments.size - 1]

        if (lastSegment.isSimple && let parameterPart: RoutePatternParameterPart <- lastSegment.parts[0] && parameterPart
            .isCatchAll) {
            return lastSegment
        }

        return None
    }

    /*
    判定后续是否还有必须处理的路径段
     */
    private func hasAdditionalRequiredSegments(endpoint: RouteEndpoint, depth: Int64) {
        for (index in depth..endpoint.routePattern.pathSegments.size) {
            let segment = endpoint.routePattern.pathSegments[index]

            if (!segment.isSimple) {
                // Complex segments always require more processing
                return true
            }

            if (let parameterPart: RoutePatternParameterPart <- segment.parts[0]) {
                // 标准参数
                if (!parameterPart.isOptional && !parameterPart.isCatchAll && parameterPart.default.isNone()) {
                    return true
                }
            } else {
                return true
            }
        }

        return false
    }

    private func addParentsMatchingComplexSegment(endpoint: RouteEndpoint, nextParents: ArrayList<DfaNode>,
        segment: RoutePatternPathSegment, parent: DfaNode, parameterPart: RoutePatternParameterPart) {
        let routeValues = RouteValueDictionary()
        let literals = parent.literals.getOrThrow()
        for (literal in literals.keys()) {
            if (RoutePatternMatcher.matchComplexSegment(segment, literal, routeValues)) {
                var passedAllPolicies = true

                for (index in 0..segment.parts.size) {
                    let segmentPart = segment.parts[index]
                    if (let partParameter: RoutePatternParameterPart <- segmentPart) {
                        if (let Some(parameterValue) <- routeValues.get(partParameter.name)) {
                            let parameterPolicyReferences = endpoint
                                .routePattern
                                .parameterPolicies
                                .get(partParameter.name)
                            if (let Some(parameterPolicyReferences) <- parameterPolicyReferences) {
                                for (index in 0..parameterPolicyReferences.size) {
                                    let reference = parameterPolicyReferences[index]
                                    let parameterPolicy = _parameterPolicyFactory.create(parameterPart, reference)
                                    if (let constraint: IParameterLiteralNodeMatchingPolicy <- parameterPolicy &&
                                        !constraint.matchesLiteral(partParameter.name, parameterValue)) {
                                        passedAllPolicies = false
                                        break
                                    }
                                }
                            }
                        } else {
                            continue
                        }
                    } else {
                        continue
                    }
                }

                if (passedAllPolicies) {
                    nextParents.add(literals[literal])
                }
            }
            routeValues.clear()
        }
    }

    /*
    根据参数策略，优化分支路径
     */
    private func addParentsWithMatchingLiteralConstraints(nextParents: ArrayList<DfaNode>, parent: DfaNode,
        parameterPart: RoutePatternParameterPart,
        parameterPolicyReferences: ReadOnlyList<RoutePatternParameterPolicyReference>) {
        let literals = parent.literals.getOrThrow()
        // 用于标记每个分支是否匹配
        let hasFailingPolicy = Array<Bool>(literals.size, repeat: false)

        for (index in 0..parameterPolicyReferences.size) {
            let reference = parameterPolicyReferences[index]
            let parameterPolicy = _parameterPolicyFactory.create(parameterPart, reference)
            if (let constraint: IParameterLiteralNodeMatchingPolicy <- parameterPolicy) {
                var allFailed = true // 假定全部路径匹配失败
                for ((index, literal) in literals.keys() |> enumerate) {
                    if (!hasFailingPolicy[index] && !constraint.matchesLiteral(parameterPart.name, literal)) {
                        hasFailingPolicy[index] = true // 表示失败
                    }

                    // 如果存在一个路径匹配成功
                    if (!hasFailingPolicy[index]) {
                        allFailed = false
                    }
                }

                // 假设成立
                if (allFailed) {
                    return
                }
            }
        }

        for ((index, literal) in literals.values() |> enumerate) {
            if (!hasFailingPolicy[index]) {
                nextParents.add(literal)
            }
        }
    }

    internal static func getPrecedenceDigitAtDepth(endpoint: RouteEndpoint, depth: Int64): Int64 {
        if (let Some(segment) <- getCurrentSegment(endpoint, depth)) {
            return RoutePrecedence.computeInboundPrecedenceDigit(endpoint.routePattern, segment)
        }
        return 0
    }

    private static func getRequiredValue(routePattern: RoutePattern, parameterPart: RoutePatternParameterPart): ?String {
        if (let Some(Some(value)) <- routePattern.requiredValues.get(parameterPart.name) && value != String.empty) {
            return value
        } else {
            return None
        }
    }
}

struct DfaBuilderWorkerWorkItem <: Comparable<DfaBuilderWorkerWorkItem> {
    DfaBuilderWorkerWorkItem(let endpoint: RouteEndpoint, let precedenceDigit: Int64, let parents: ArrayList<DfaNode>) {
    }

    public func deconstruct() {
        return (endpoint, parents)
    }

    public func compare(that: DfaBuilderWorkerWorkItem) {
        if (precedenceDigit > that.precedenceDigit) {
            Ordering.GT
        } else if (precedenceDigit < that.precedenceDigit) {
            Ordering.LT
        }
        return Ordering.EQ
    }
}

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_routing.matching

import soulsoft_web_http.*
import soulsoft_web_routing.http.*
import soulsoft_web_routing.patterns.*
import soulsoft_web_routing.abstractions.*

protected class DfaMatcher <: Matcher {
    private let _isDefaultEndpointSelector: Bool

    DfaMatcher(let endpointSelector: EndpointSelector, let states: Array<DfaState>, let maxSegmentCount: Int64) {
        _isDefaultEndpointSelector = endpointSelector is DefaultEndpointSelector
    }

    public func invoke(context: HttpContext) {
        // path 保留原始大小写，用于后续提取路由参数值（捕获段、catch-all、复杂段）
        // lowercasePath 仅用于 DFA 节点跳转，实现路径匹配忽略大小写
        // 两者偏移量一致（toAsciiLower 不改变字节长度），可共用同一组 segments 索引
        let path = context.request.path.value
        let lowercasePath = path.toAsciiLower()
        let segments = FastPathTokenizer.tokenize(lowercasePath, maxSegmentCount)

        //查找候选集
        let candidates = findCandidateSet(context, lowercasePath, segments)
        if (candidates.size == 0) {
            return
        }

        // 优化
        if (candidates.size == 1 && candidates[0].flags == CandidateFlags.None && _isDefaultEndpointSelector) {
            context.setEndpoint(candidates[0].endpoint)
            return
        }

        //筛选最终的候选结果
        let candidateStates = Array<CandidateState>(candidates.size,
            repeat: CandidateState(NotfoundEndpoint.empty, 0, false, None))

        var i = 0
        while (i < candidates.size) {
            let candidate = candidates[i]

            // 每个候选使用独立的路由值字典，防止多候选间互相污染
            var candidateValues: ?RouteValueDictionary = None

            // 计算参数
            if (candidate.flags.has(CandidateFlags.HasSlots)) {
                var slots = Array<(String, String)>(candidate.slots.size, repeat: (String.empty, ""))

                if (candidate.flags.has(CandidateFlags.HasDefaults)) {
                    var j = 0
                    while (j < candidate.slots.size) {
                        slots[j] = candidate.slots[j]
                        j++
                    }
                }

                if (candidate.flags.has(CandidateFlags.HasCaptures)) {
                    processCaptures(slots, candidate.captures, path, segments)
                }

                if (candidate.flags.has(CandidateFlags.HasCatchAll)) {
                    processCatchAll(slots, candidate.catchAll, path, segments)
                }

                candidateValues = RouteValueDictionary.fromArray(slots)
            }

            var isValid = true
            if (candidate.flags.has(CandidateFlags.HasComplexSegments)) {
                if (candidateValues.isNone()) {
                    candidateValues = RouteValueDictionary()
                }
                if (!processComplexSegments(candidate.endpoint, candidate.complexSegments, candidateValues.getOrThrow(),
                    path, segments)) {
                    isValid = false
                }
            }

            if (candidate.flags.has(CandidateFlags.HasConstraints)) {
                if (candidateValues.isNone()) {
                    candidateValues = RouteValueDictionary()
                }
                if (!processConstraints(context, candidate.endpoint, candidate.constraints, candidateValues.getOrThrow())) {
                    isValid = false
                }
            }

            candidateStates[i] = CandidateState(candidate.endpoint, candidate.score, isValid, candidateValues)
            i++
        }
        //选举
        endpointSelector.select(context, CandidateSet(candidateStates))
    }

    private func findCandidateSet(context: HttpContext, path: String, segments: Array<PathSegment>): Array<Candidate> {
        var destination: Int64 = 0

        //1. 使用路径跳转
        var index = 0
        while (index < segments.size) {
            let segment = segments[index]
            let segmentText = path[segment.start..segment.end]
            destination = states[destination].pathTransitions.getDestination(segmentText)
            index++
        }

        //2. 使用策略跳转
        while (let Some(policyTransitions) <- states[destination].policyTransitions) {
            destination = policyTransitions.getDestination(context)
        }

        //3. 得到最终状态
        let state = states[destination]
        return state.candidates
    }

    private func processComplexSegments(endpoint: Endpoint, complexSegments: Array<(RoutePatternPathSegment, Int64)>,
        values: RouteValueDictionary, path: String, segments: Array<PathSegment>): Bool {
        var index = 0
        while (index < complexSegments.size) {
            let (complexSegment, segmentIndex) = complexSegments[index]
            let segment = segments[segmentIndex]
            let segmentText = path[segment.start..segment.end]
            if (!RoutePatternMatcher.matchComplexSegment(complexSegment, segmentText, values)) {
                return false
            }
            index++
        }

        return true
    }

    private func processCatchAll(slots: Array<(String, String)>, catchAll: ?(String, Int64, Int64), path: String,
        segments: Array<PathSegment>) {
        if (let Some((name, segmentIndex, slotIndex)) <- catchAll) {
            if (segmentIndex < segments.size) {
                let segment = segments[segmentIndex]
                slots[slotIndex] = (name, path[segment.start..])
            } else {
                // catch-all 匹配零内容：参数已匹配但内容为空，写入 "" 而非保留 None
                // 对应 ASP.NET Core 中 routeValues["path"] = null（键存在，值为空）的语义
                slots[slotIndex] = (name, "")
            }
        }
    }

    private func processCaptures(slots: Array<(String, String)>, captures: Array<(String, Int64, Int64)>, path: String,
        segments: Array<PathSegment>) {
        var index = 0
        while (index < captures.size) {
            let (parameterName, segmentIndex, slotIndex) = captures[index]
            if (segmentIndex < segments.size) {
                let segment = segments[segmentIndex]
                if (segment.length > 0) {
                    let segmentText = path[segment.start..segment.end]
                    slots[slotIndex] = (parameterName, segmentText)
                }
            }
            index++
        }
    }

    private func processConstraints(context: HttpContext, endpoint: Endpoint,
        constraints: Array<(String, IRouteConstraint)>, values: RouteValueDictionary): Bool {
        var index = 0
        while (index < constraints.size) {
            let (routeKey, constraint) = constraints[index]
            if (!constraint.isMatch(context, routeKey, values)) {
                return false
            }
            index++
        }
        return true
    }

    public func debuggerToString(): String {
        let sb = StringBuilder()
        sb.append("=== DFA State Machine [${states.size} states] ===\n")
        for (i in 0..states.size) {
            sb.append("\n${states[i].debuggerToString(i)}\n")
        }
        return sb.toString()
    }
}

class NotfoundEndpoint <: Endpoint {
    public static let empty = NotfoundEndpoint()

    init() {
        super({
            context => context.response.statusCode = StatusCodes.NotFound
        }, EndpointMetadataCollection.empty, None)
    }

    public override func toString(): String {
        "Notfound"
    }
}

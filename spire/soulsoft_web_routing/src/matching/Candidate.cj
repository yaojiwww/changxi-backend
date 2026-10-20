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

/**
 * @brief 表示 DFA 匹配阶段的候选端点信息。
 */
public struct Candidate {
    /**
     * @brief 返回当前候选端点包含的匹配特征标记。
     */
    public let flags: CandidateFlags

    Candidate(public let endpoint: Endpoint, public let score: Int64, public let slots: Array<(String, String)>,
        public let captures: Array<(String, Int64, Int64)>, public let constraints: Array<(String, IRouteConstraint)>,
        public let complexSegments: Array<(RoutePatternPathSegment, Int64)>,
        public let catchAll: ?(String, Int64, Int64)) {
        var flags = CandidateFlags.None
        for ((key, _) in slots) {
            if (!key.isEmpty()) {
                flags = flags | CandidateFlags.HasDefaults
            }
        }

        if (captures.size > 0) {
            flags = flags | CandidateFlags.HasCaptures
        }

        if (catchAll.isSome()) {
            flags = flags | CandidateFlags.HasCatchAll
        }

        if (complexSegments.size > 0) {
            flags = flags | CandidateFlags.HasComplexSegments
        }

        if (constraints.size > 0) {
            flags = flags | CandidateFlags.HasConstraints
        }
        this.flags = flags
    }

    func debuggerToString(): String {
        let sb = StringBuilder()
        sb.append("score=${score}")
        if (let routeEndpoint: RouteEndpoint <- endpoint) {
            sb.append("  ${routeEndpoint.routePattern.rawText}")
        } else {
            sb.append("  ${endpoint.toString()}")
        }
        if (let Some((name, segIdx, slotIdx)) <- catchAll) {
            sb.append("  catchAll=(${name}, seg=${segIdx}, slot=${slotIdx})")
        }
        for ((name, segIdx, slotIdx) in captures) {
            sb.append("  cap=(${name}, seg=${segIdx}, slot=${slotIdx})")
        }
        return sb.toString()
    }
}

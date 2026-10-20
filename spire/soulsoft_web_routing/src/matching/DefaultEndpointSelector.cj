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
import soulsoft_web_routing.http.*

protected class DefaultEndpointSelector <: EndpointSelector {
    public func select(context: HttpContext, set: CandidateSet): Unit {
        if (set.candidates.size == 0) {
            return
        } else if (set.candidates.size == 1) {
            let state = set.candidates[0]
            if (state.isValid) {
                setEndpoint(context, state)
                return
            }
        } else {
            if (let Some(state) <- processFinalCandidates(set)) {
                setEndpoint(context, state)
            }
        }
    }

    private func setEndpoint(context: HttpContext, state: CandidateState) {
        context.setEndpoint(state.endpoint)
        // 将选中候选的路由值写回请求上下文
        if (let Some(values) <- state.values) {
            context.request.routeValues.add(all: values)
        }
    }

    private func processFinalCandidates(candidateState: CandidateSet): ?CandidateState {
        var foundScore: ?Int64 = None
        var result: ?CandidateState = None

        for (state in candidateState.candidates) {
            if (!state.isValid) {
                continue
            }

            if (let Some(fs) <- foundScore) {
                if (fs < state.score) {
                    // 当前候选优先级低于已找到的，停止遍历
                    break
                } else {
                    // fs == state.score：同分歧义，收集所有同分有效候选后抛出
                    reportAmbiguity(candidateState, fs)
                }
            } else {
                // 首个有效候选，暂存
                foundScore = state.score
                result = state
            }
        }
        return result
    }

    // 收集与 ambiguousScore 同分的所有有效候选端点，拼接 displayName 后抛 AmbiguousMatchException
    // 对齐 C# DefaultEndpointSelector.ReportAmbiguity：仅报告真正冲突的同分候选，排除低优先级端点
    private static func reportAmbiguity(candidateState: CandidateSet, ambiguousScore: Int64): Unit {
        var matches: ?ArrayList<Endpoint> = None
        for (state in candidateState.candidates) {
            if (state.isValid && state.score == ambiguousScore) {
                if (matches.isNone()) {
                    matches = ArrayList<Endpoint>()
                }
                matches?.add(state.endpoint)
            }
        }

        if (let Some(matches) <- matches) {
            let names = matches |> map {e: Endpoint => e.toString()} |> collectArray
            let message = "The request matched multiple endpoints. Matches:\n${String.join(names, delimiter: "\n")}"
            throw AmbiguousMatchException(message)
        }
    }
}

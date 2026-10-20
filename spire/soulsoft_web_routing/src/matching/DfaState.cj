// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_routing.matching

import std.collection.*

struct DfaState {
    DfaState(let pathTransitions: JumpTable, let policyTransitions: ?PolicyJumpTable, let candidates: Array<Candidate>) {
    }

    internal func debuggerToString(index: Int64): String {
        let sb = StringBuilder()
        sb.append("[${index}]  jump:${pathTransitions.debuggerToString()}")
        if (let Some(p) <- policyTransitions) {
            sb.append("  policy:${p.debuggerToString()}")
        }
        if (candidates.size == 0) {
            sb.append("\n     candidates: (none)")
        } else {
            sb.append("\n     candidates:")
            for (i in 0..candidates.size) {
                sb.append("\n       #${i}  ${candidates[i].debuggerToString()}")
            }
        }
        return sb.toString()
    }
}

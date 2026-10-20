// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_injection

enum CallSiteResultCacheLocation <: Comparable<CallSiteResultCacheLocation> {
    Root
    | Scope
    | Dispose
    | Other

    private prop value: Int64 {
        get() {
            match (this) {
                case Root => 0
                case Scope => 1
                case Dispose => 2
                case Other => 3
            }
        }
    }

    public func compare(that: CallSiteResultCacheLocation) {
        let a = value
        let b = that.value
        if (a == b) {
            Ordering.EQ
        } else if (a >= b) {
            Ordering.GT
        } else {
            Ordering.LT
        }
    }
}

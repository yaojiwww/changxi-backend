// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_routing.matching

/*
跳转表构建
 */
protected class JumpTableBuilder {
    protected static func build(defaultDestination: Int64, exitDestination: Int64, entries: ?Array<(String, Int64)>): JumpTable {
        if (let Some(entries) <- entries) {
            if (entries.size == 1) {
                return SingleEntryJumpTable(defaultDestination, exitDestination, entries[0])
            }

            // 条目数 ≤10 时，线性扫描比 HashMap 更快：无哈希计算开销，数组内存连续 CPU 预取友好
            // 参考：ASP.NET Core JumpTableBuilder 阈值策略
            if (entries.size <= 10) {
                return LinearSearchJumpTable(defaultDestination, exitDestination, entries)
            }

            return DictionaryJumpTable(defaultDestination, exitDestination, entries)
        }

        return ZeroEntryJumpTable(defaultDestination, exitDestination)
    }
}
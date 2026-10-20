// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_routing.matching

protected class FastPathTokenizer {
    public static func tokenize(path: String, maxSegmentCount: Int64): Array<PathSegment> {
        // 根路径或空路径无段
        if (path.size <= 1) {
            return []
        }

        // 第一遍：统计有效段数
        // 以 '/' 为分隔符线性扫描，空段（连续 '//' 或末尾 '/'）不计入
        var count = 0
        var start = 1
        for (i in 1..path.size) {
            if (path[i] == b'/') {
                if (i > start) {
                    count++
                }
                start = i + 1
            }
        }
        // 末尾无 '/' 时的剩余段（非空才计入）
        if (start < path.size) {
            count++
        }

        // 超出 maxSegmentCount 的段静默截断
        count = min(count, maxSegmentCount)

        if (count == 0) {
            return []
        }

        // 第二遍：填充数组，达到 count 后停止（截断多余段）
        let segments = Array<PathSegment>(count, repeat: PathSegment(0, 0))
        var segmentIndex = 0
        start = 1
        for (i in 1..path.size) {
            if (path[i] == b'/') {
                if (i > start) {
                    segments[segmentIndex] = PathSegment(start, i)
                    segmentIndex++
                    if (segmentIndex >= count) {
                        break
                    }
                }
                start = i + 1
            }
        }
        if (segmentIndex < count) {
            segments[segmentIndex] = PathSegment(start, path.size)
        }

        return segments
    }
}

protected struct PathSegment {
    PathSegment(public let start: Int64, public let end: Int64) {
    }

    public prop length: Int64 {
        get() {
            end - start
        }
    }
}

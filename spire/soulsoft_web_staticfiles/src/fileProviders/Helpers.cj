// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_staticfiles.fileProviders

import std.fs.*

import stdx.encoding.url.*

// ─── FileSystemInfoHelper ──────────────────────────────────────────────────

class FileSystemInfoHelper {
    /// 判断文件/目录是否应被过滤排除
    public static func isExcluded(info: FileInfo, filters: ExclusionFilters): Bool {
        if (filters == ExclusionFilters.None) {
            return false
        }
        // DotPrefixed：以 '.' 开头的文件或目录（如 .git、.env）
        if (info.name.startsWith(".") && filters.hasFlag(ExclusionFilters.DotPrefixed)) {
            return true
        }
        // Hidden / System：依赖平台文件属性，仓颉 FileInfo 暂不暴露该属性，保留扩展点
        return false
    }
}

// ─── PathUtils ─────────────────────────────────────────────────────────────

class PathUtils {
    /// 检查路径是否包含路径穿越（防止 ../../ 攻击）
    public static func pathNavigatesAboveRoot(path: String): Bool {
        var depth = 0
        let segments = path.split("/")
        for (segment in segments) {
            if (segment == "." || segment.isEmpty()) {
                continue
            } else if (segment == "..") {
                depth--
                if (depth < 0) {
                    return true
                }
            } else {
                depth++
            }
        }
        return false
    }

    /// 确保路径以 '/' 结尾
    public static func ensureTrailingSlash(path: String): String {
        if (!path.isEmpty() && !path.endsWith("/") && !path.endsWith("\\")) {
            return "${path}/"
        }
        return path
    }
}
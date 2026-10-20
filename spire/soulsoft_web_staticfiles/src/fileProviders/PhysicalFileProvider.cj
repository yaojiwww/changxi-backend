// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_staticfiles.fileProviders

import std.fs.*

/**
 * @brief 提供基于物理文件系统的文件访问能力。
 */
public class PhysicalFileProvider <: IFileProvider {
    // 根路径（末尾保证有 '/'）
    private let _root: String
    private let _filters: ExclusionFilters

    /**
     * @brief 使用默认过滤规则创建物理文件提供器。
     * @param path 作为根目录的物理路径。
     */
    public init(path: String) {
        _root = PathUtils.ensureTrailingSlash(path).toAsciiLower()
        _filters = ExclusionFilters.Sensitive
    }

    /**
     * @brief 使用指定过滤规则创建物理文件提供器。
     * @param path 作为根目录的物理路径。
     * @param filters 要应用的排除过滤标志。
     */
    public init(path: String, filters: ExclusionFilters) {
        _root = PathUtils.ensureTrailingSlash(path)
        _filters = filters
    }

    /**
     * @brief 根据相对路径获取文件信息。
     * @param file 要查询的文件路径。
     * @return 对应的文件信息；未找到或被排除时返回不存在的文件对象。
     */
    public func getFileInfo(file: String): IFileInfo {
        if (file.isEmpty()) {
            return NotFoundFileInfo(file)
        }
        if (let Some(fullPath) <- getFullPath(file)) {
            if (exists(fullPath)) {
                let info = FileInfo(fullPath)
                if (!FileSystemInfoHelper.isExcluded(info, _filters)) {
                    return PhysicalFileInfo(info)
                }
            }
        }
        return NotFoundFileInfo(file)
    }

    /**
     * @brief 根据相对路径获取目录内容。
     * @param subPath 要查询的目录路径。
     * @return 对应的目录内容；未找到或被排除时返回不存在的目录内容对象。
     */
    public func getDirectoryContents(subPath: String): IDirectoryContents {
        if (let Some(fullPath) <- getFullPath(subPath)) {
            if (exists(fullPath)) {
                let info = FileInfo(fullPath)
                if (info.isDirectory() && !FileSystemInfoHelper.isExcluded(info, _filters)) {
                    return PhysicalDirectoryInfo(info, _filters)
                }
            }
        }
        return NotFoundDirectoryContents.instance
    }

    /// 解析子路径为绝对路径，若路径穿越或无效则返回 None
    private func getFullPath(subPath: String): ?String {
        if (PathUtils.pathNavigatesAboveRoot(subPath)) {
            return None
        }
        // 去掉前导 '/'（URL 相对路径约定）
        let relative = subPath.trimStart("/")
        let fullPath = "${_root}${relative}"
        // 防止符号链接等绕过根路径限制
        if (!fullPath.startsWith(_root)) {
            return None
        }
        return fullPath
    }

    private func isUnderneathRoot(fullPath: String) {
        fullPath.startsWith(_root)
    }
}

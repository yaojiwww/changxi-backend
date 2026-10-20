// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_staticfiles.fileProviders

/**
 * @brief 将多个文件提供器组合为一个顺序查询的文件提供器。
 */
public class CompositeFileProvider <: IFileProvider {
    private let _providers: Array<IFileProvider>

    /**
     * @brief 使用多个文件提供器创建组合文件提供器。
     * @param providers 按查询优先级排列的文件提供器集合。
     */
    public init(providers: Collection<IFileProvider>) {
        _providers = providers.toArray()
    }

    /**
     * @brief 按顺序从组合提供器中查询文件信息。
     * @param path 要查询的文件路径。
     * @return 第一个匹配到的文件信息；未找到时返回不存在的文件对象。
     */
    public func getFileInfo(path: String): IFileInfo {
        for (p in _providers) {
            let file = p.getFileInfo(path)
            if (file.exists) {
                return file
            }
        }
        return NotFoundFileInfo(path)
    }

    /**
     * @brief 按顺序从组合提供器中查询目录内容。
     * @param subPath 要查询的目录路径。
     * @return 第一个存在的目录内容；未找到时返回不存在的目录内容对象。
     */
    public func getDirectoryContents(subPath: String): IDirectoryContents {
        for (p in _providers) {
            let dir = p.getDirectoryContents(subPath)
            if (dir.exists) {
                return dir
            }
        }
        return NotFoundDirectoryContents.instance
    }
}

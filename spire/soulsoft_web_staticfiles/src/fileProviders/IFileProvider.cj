// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_staticfiles.fileProviders

/**
 * @brief 提供按路径访问文件和目录内容的能力。
 */
public interface IFileProvider {
    /**
     * @brief 根据路径获取文件信息。
     * @param path 要查询的文件路径。
     * @return 对应的文件信息；未找到时返回不存在的文件对象。
     */
    func getFileInfo(path: String): IFileInfo
    /**
     * @brief 根据路径获取目录内容。
     * @param subPath 要查询的目录路径。
     * @return 对应的目录内容；未找到时返回不存在的目录内容对象。
     */
    func getDirectoryContents(subPath: String): IDirectoryContents
}

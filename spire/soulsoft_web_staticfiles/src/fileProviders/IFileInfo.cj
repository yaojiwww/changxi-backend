// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_staticfiles.fileProviders

import std.io.*
import std.time.*

/**
 * @brief 描述可供静态文件中间件访问的文件信息。
 */
public interface IFileInfo {    
    /**
     * @brief 返回文件或目录名称。
     * @return 当前项的名称。
     */
    prop name: String
    /**
     * @brief 返回当前项的大小。
     * @return 当前项的字节大小；目录或未知大小时由实现定义。
     */
    prop size: Int64
    /**
     * @brief 返回当前项是否存在。
     * @return 如果当前项存在则返回 true，否则返回 false。
     */
    prop exists: Bool
    /**
     * @brief 返回当前项是否为目录。
     * @return 如果当前项是目录则返回 true，否则返回 false。
     */
    prop isDirectory: Bool
    /**
     * @brief 返回当前项对应的物理路径。
     * @return 当前项的物理路径；不可用时返回空。
     */
    prop physicalPath: ?String
    /**
     * @brief 返回当前项的最后修改时间。
     * @return 当前项的最后修改时间。
     */
    prop lastModified: DateTime
    /**
     * @brief 创建用于读取当前项内容的输入流。
     * @return 读取当前项内容的输入流。
     */
    func createReadStream(): InputStream
}

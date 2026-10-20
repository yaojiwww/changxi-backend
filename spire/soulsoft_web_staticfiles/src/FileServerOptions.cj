// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_staticfiles

/**
 * @brief 表示文件服务器中间件的组合配置选项。
 * @description 该类型会让默认文件选项与静态文件选项共享同一个 SharedOptions 实例。
 */
public class FileServerOptions <: SharedOptionsBase {
    /**
     * @brief 返回静态文件中间件的子配置。
     */
    public let staticFileOptions: StaticFileOptions

    /**
     * @brief 返回默认文件中间件的子配置。
     */
    public let defaultFilesOptions: DefaultFilesOptions

    /**
     * @brief 获取或修改是否启用默认文件中间件。
     */
    public var enableDefaultFiles: Bool = true

    /**
     * @brief 获取或修改是否启用目录浏览。
     */
    public var enableDirectoryBrowsing: Bool = false

    /**
     * @brief 创建文件服务器组合选项。
     */
    public init() {
        super(SharedOptions())
        staticFileOptions = StaticFileOptions(sharedOptions)
        defaultFilesOptions = DefaultFilesOptions(sharedOptions)
    }
}

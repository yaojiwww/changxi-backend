// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_staticfiles

/**
 * @brief 提供注册文件服务器中间件的扩展方法。
 */
public interface FileServerExtensions {
    /**
     * @brief 使用默认配置注册文件服务器中间件。
     */
    func useFileServer(): Unit {
        useFileServer(FileServerOptions())
    }
    /**
     * @brief 使用指定选项注册文件服务器中间件。
     * @param options 文件服务器选项。
     */
    func useFileServer(options: FileServerOptions): Unit
    /**
     * @brief 使用配置回调注册文件服务器中间件。
     * @param configureOptions 用于配置文件服务器选项的回调。
     */
    func useFileServer(configureOptions: (FileServerOptions) -> Unit): Unit {
        let options = FileServerOptions()
        configureOptions(options)
        useFileServer(options)
    }
}

extend ApplicationBuilder <: FileServerExtensions {
    /**
     * @brief 使用指定选项注册文件服务器中间件。
     * @param options 文件服务器选项。
     */
    public func useFileServer(options: FileServerOptions): Unit {
        // requestPath / fileProvider 已通过 SharedOptions 共享引用自动同步，无需手动拷贝。
        if (options.enableDefaultFiles) {
            useDefaultFiles(options.defaultFilesOptions)
        }
        useStaticFiles(options.staticFileOptions)
    }
}

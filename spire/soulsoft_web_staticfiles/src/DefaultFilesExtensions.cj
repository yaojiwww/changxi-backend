// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_staticfiles

import soulsoft_extensions_options.*

/**
 * @brief 提供注册默认文件中间件的扩展方法。
 */
public interface DefaultFilesExtensions {
    /**
     * @brief 使用默认配置注册默认文件中间件。
     */
    func useDefaultFiles(): Unit
    /**
     * @brief 使用指定选项注册默认文件中间件。
     * @param options 默认文件选项。
     */
    func useDefaultFiles(options: DefaultFilesOptions): Unit
    /**
     * @brief 使用配置回调注册默认文件中间件。
     * @param configureOptions 用于配置默认文件选项的回调。
     */
    func useDefaultFiles(configureOptions: (DefaultFilesOptions) -> Unit): Unit
}

extend ApplicationBuilder <: DefaultFilesExtensions {
    /**
     * @brief 使用默认配置注册默认文件中间件。
     */
    public func useDefaultFiles(): Unit {
        let options = DefaultFilesOptions()
        useDefaultFiles(options)
    }

    /**
     * @brief 使用配置回调注册默认文件中间件。
     * @param configureOptions 用于配置默认文件选项的回调。
     */
    public func useDefaultFiles(configureOptions: (DefaultFilesOptions) -> Unit): Unit {
        let options = DefaultFilesOptions()
        configureOptions(options)
        useDefaultFiles(options)
    }

    /**
     * @brief 使用指定选项注册默认文件中间件。
     * @param options 默认文件选项。
     */
    public func useDefaultFiles(options: DefaultFilesOptions): Unit {
        use<DefaultFilesMiddleware>(Options.create(options))
    }
}

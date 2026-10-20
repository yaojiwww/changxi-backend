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
 * @brief 提供注册静态文件中间件的扩展方法。
 */
public interface StaticFileExtensions {
    /**
     * @brief 使用默认配置注册静态文件中间件。
     */
    func useStaticFiles(): Unit {
        useStaticFiles(StaticFileOptions())
    }
    /**
     * @brief 使用指定选项注册静态文件中间件。
     * @param options 静态文件选项。
     */
    func useStaticFiles(options: StaticFileOptions): Unit
    /**
     * @brief 使用配置回调注册静态文件中间件。
     * @param configureOptions 用于配置静态文件选项的回调。
     */
    func useStaticFiles(configureOptions: (StaticFileOptions) -> Unit): Unit {
        let options = StaticFileOptions()
        configureOptions(options)
        useStaticFiles(options)
    }
}

extend ApplicationBuilder <: StaticFileExtensions {
    /**
     * @brief 使用指定选项注册静态文件中间件。
     * @param options 静态文件选项。
     */
    public func useStaticFiles(options: StaticFileOptions): Unit {
        use<StaticFileMiddleware>(Options.create(options))
    }
}

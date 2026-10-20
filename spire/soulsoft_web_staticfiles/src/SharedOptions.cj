// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_staticfiles

import soulsoft_web_staticfiles.fileProviders.*

/**
 * @brief 表示多个静态文件中间件共享的选项状态。
 * @description FileServerOptions 在构造时会将同一个共享实例传给各个子选项，因此对请求路径和文件提供器的修改会自动同步。
 */
public class SharedOptions {
    private var _requestPath = PathString(String.empty)

    /**
     * @brief 获取或修改映射到静态资源的相对请求路径。
     * @return 当前配置的请求路径。
     * @throws IllegalArgumentException 当路径以斜杠结尾时抛出。
     */
    public mut prop requestPath: PathString {
        get() {
            _requestPath
        }
        set(value) {
            if (value.hasValue && value.value.endsWith('/')) {
                throw IllegalArgumentException("Request path must not end in a slash.")
            }
            _requestPath = value
        }
    }

    /**
     * @brief 获取或修改用于定位资源的文件提供器。
     */
    public var fileProvider: ?IFileProvider = None

    /**
     * @brief 获取或修改是否在目录请求末尾追加斜杠后重定向。
     */
    public var redirectToAppendTrailingSlash: Bool = true
}

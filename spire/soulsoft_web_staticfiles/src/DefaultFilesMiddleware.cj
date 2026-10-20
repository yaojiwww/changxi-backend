// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_staticfiles

import soulsoft_extensions_options.*
import soulsoft_web_staticfiles.fileProviders.*

class DefaultFilesMiddleware <: IMiddleware {
    private let _options: DefaultFilesOptions
    private let _fileProvider: IFileProvider

    public init(options: IOptions<DefaultFilesOptions>, environment: IWebHostEnvironment) {
        _options = options.value
        _fileProvider = _options.fileProvider ?? PhysicalFileProvider(environment.webRootPath)
    }

    public func invoke(context: HttpContext, next: RequestDelegate): Unit {
        if (context.getEndpoint().isNone() && Helpers.isGetOrHeadMethod(context.request.method) && let Some(subPath) <- Helpers
            .tryMatchPath(context, _options.requestPath, true)) {
            let dirContents = _fileProvider.getDirectoryContents(subPath.value)
            if (dirContents.exists) {
                // 检查是否有匹配的默认文件
                for (defaultFile in _options.defaultFileNames) {
                    let file = _fileProvider.getFileInfo(subPath.value + defaultFile)
                    // tryMatchPath 保证 subPath 始终以 "/" 结尾
                    if (file.exists) {
                        // 路径不以 / 结尾时重定向，防止相对链接失效
                        if (_options.redirectToAppendTrailingSlash && !Helpers.pathEndsInSlash(context.request.path)) {
                            Helpers.redirectToPathWithSlash(context)
                            return
                        }
                        // 重写请求路径，由后续 StaticFileMiddleware 提供文件
                        context.request.path = PathString(
                            Helpers.getPathValueWithSlash(context.request.path) + defaultFile)
                        break
                    }
                }
            }
        }
        next(context)
    }
}

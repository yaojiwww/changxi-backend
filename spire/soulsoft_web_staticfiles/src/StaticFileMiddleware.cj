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

class StaticFileMiddleware <: IMiddleware {
    private let _options: StaticFileOptions
    private let _fileProvider: IFileProvider
    private let _contentTypeProvider: IContentTypeProvider

    public init(options: IOptions<StaticFileOptions>, environment: IWebHostEnvironment) {
        _options = options.value
        _fileProvider = _options.fileProvider ?? PhysicalFileProvider(environment.webRootPath)
        _contentTypeProvider = _options.contentTypeProvider ?? ContentTypeProvider()
    }

    public func invoke(context: HttpContext, next: RequestDelegate): Unit {
        if (!validateNoEndpointDelegate(context)) {
            next(context)
        } else if (!validateMethod(context)) {
            next(context)
        } else if (let Some(subPath) <- validatePath(context) && let Some(contentType) <- lookupContentType(subPath)) {
            tryServeStaticFile(context, contentType, subPath, next)
        } else {
            next(context)
        }
    }

    // Returns true when there is no endpoint (i.e. routing has not matched a delegate),
    // meaning this middleware should attempt to serve the request.
    // In Cangjie, Endpoint always carries a delegate, so any matched endpoint means skip.
    private func validateNoEndpointDelegate(context: HttpContext): Bool {
        context.getEndpoint().isNone()
    }

    private func validateMethod(context: HttpContext): Bool {
        Helpers.isGetOrHeadMethod(context.request.method)
    }

    private func validatePath(context: HttpContext): ?PathString {
        return Helpers.tryMatchPath(context, _options.requestPath, false)
    }

    private func lookupContentType(path: PathString): ?String {
        if (let Some(contentType) <- _contentTypeProvider.getContentType(path.value)) {
            return contentType
        }

        if (_options.serveUnknownFileTypes) {
            return _options.defaultContentType ?? "application/octet-stream"
        }

        return None
    }

    private func tryServeStaticFile(context: HttpContext, contentType: String, subPath: PathString,
        next: RequestDelegate) {
        let fileInfo = _fileProvider.getFileInfo(subPath.value)
        var fileContext = StaticFileContent(fileInfo, contentType, context.request.method, _options.onPrepareResponse)
        if (fileContext.lookupFileInfo()) {
            fileContext.serveStaticFile(context, next)
        } else {
            next(context)
        }
    }
}

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_openapi

import std.io.*
import std.fs.*
import soulsoft_web_http.*
import soulsoft_web_hosting.*

/**
 * @brief 提供 OpenAPI UI 静态资源中间件。
 */
public class OpenApiUIMiddleware <: IMiddleware {
    private static let _openApiRootPath = PathString("/openapi")
    private let _env: IWebHostEnvironment

    /**
     * @brief 创建 OpenAPI UI 中间件实例。
     * @param evn 当前 Web 主机环境。
     */
    public init(evn: IWebHostEnvironment) {
        _env = evn
    }

    /**
     * @brief 处理 OpenAPI UI 相关请求。
     * @param context 当前 HTTP 上下文。
     * @param next 下一个请求委托。
     */
    public func invoke(context: HttpContext, next: RequestDelegate): Unit {
        let remainingPath = if (let Some(path) <- context.request.path.startsWithSegments(
            OpenApiUIMiddleware._openApiRootPath
        )) {
            path
        } else {
            next(context)
            return
        }

        if (context.request.path == "/openapi") {
            context.response.redirect("/openapi/index.html")
            return
        }

        let path = if (let Some(path) <- resolveAssetPath(remainingPath)) {
            path
        } else {
            next(context)
            return
        }

        if (exists(path) && isPathWithinRoot(path)) {
            try (fs = File(path, OpenMode.Read)) {
                let data = readToEnd(fs)
                context.response.write(data)
            }
        } else {
            next(context)
        }
    }

    private func resolveAssetPath(remainingPath: PathString): ?Path {
        let relativePath = if (remainingPath == "/" || !remainingPath.hasValue) {
            "index.html"
        } else {
            let candidate = remainingPath.value.trimStart('/')
            if (!isSafeRelativePath(candidate)) {
                return None
            }
            candidate
        }

        let openApiRoot = Path(_env.webRootPath).join("openapi")
        return openApiRoot.join(relativePath).normalize()
    }

    private func isSafeRelativePath(relativePath: String): Bool {
        if (relativePath.isEmpty() || relativePath.startsWith('/') || relativePath.endsWith('/')) {
            return false
        }

        for (segment in relativePath.split('/')) {
            if (segment.isEmpty() || segment == "." || segment == "..") {
                return false
            }
        }

        return true
    }

    private func isPathWithinRoot(path: Path): Bool {
        try {
            let rootPath = canonicalize(Path(_env.webRootPath).join("openapi"))
            let targetPath = canonicalize(path)
            let rootPathString = rootPath.toString()
            let targetPathString = targetPath.toString()
            if (targetPathString == rootPathString) {
                return true
            }

            if (rootPathString == Path.Separator) {
                return targetPathString.startsWith(rootPathString)
            }

            let rootPathPrefix = if (rootPathString.endsWith(Path.Separator)) {
                rootPathString
            } else {
                "${rootPathString}${Path.Separator}"
            }
            return targetPathString.startsWith(rootPathPrefix)
        } catch (_: Exception) {
            return false
        }
    }
}

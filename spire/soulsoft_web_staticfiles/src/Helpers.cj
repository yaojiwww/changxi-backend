// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_staticfiles

class Helpers {
    public static func isGetOrHeadMethod(method: String) {
        return HttpMethods.isGet(method) || HttpMethods.isHead(method)
    }

    public static func pathEndsInSlash(path: PathString) {
        path.hasValue && path.value.endsWith("/")
    }

    public static func getPathValueWithSlash(path: PathString): String {
        if (!pathEndsInSlash(path)) {
            return "${path.value}/"
        }
        return path.value
    }

    public static func redirectToPathWithSlash(context: HttpContext): Unit {
        context.response.statusCode = StatusCodes.MovedPermanently
        let request = context.request
        // 末尾必须加`/`，所以需要重定向（不加`/`结尾不前端加载的相对路径就变了不是requestPath了）
        let location = if (!request.queryString.hasValue) {
            request.path.value + "/"
        } else {
            request.path.value + "/" + request.queryString.value
        }
        context.response.headers.location = [location]
    }

    public static func tryMatchPath(context: HttpContext, matchUrl: PathString, forDirectory: Bool): ?PathString {
        var path = context.request.path

        // 目录必须以'/'结尾    
        if (forDirectory && !pathEndsInSlash(path)) {
            path = PathString("${path.value}/")
        }

        if (let Some(subpath) <- path.startsWithSegments(matchUrl)) {
            return subpath
        }
        return None
    }
}

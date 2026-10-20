// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_healthchecks

import soulsoft_extensions_options.*

class HealthCheckMiddleware <: IMiddleware {
    private let _path: String
    private let _options: HealthCheckOptions
    private let _checkService: IHealthCheckService

    init(path: String, checkService: IHealthCheckService, options: IOptions<HealthCheckOptions>) {
        _path = path
        _options = options.value
        _checkService = checkService
    }

    public func invoke(context: HttpContext, _: RequestDelegate): Unit {
        let result = _checkService.checkHealth(_options.predicate)
        if (let Some(status) <- _options.resultStatusCodes.get(result.status)) {
            context.response.statusCode = status
        } else {
            let message = "No status code mapping found for HealthStatus value: ${result.status}." +
                "HealthCheckOptions.ResultStatusCodes must contain" + "an entry for ${result.status}."
            throw UnsupportedException(message)
        }
        // 是否允许缓存
        if (!_options.allowCachingResponses) {
            context.response.headers.cacheControl = ["no-store, no-cache"]
            context.response.headers.pragma = ["no-cache"]
            context.response.headers.expires = ["Thu, 01 Jan 1970 00:00:00 GMT"]
        }
        // 自定义响应
        _options.responseWriter(context, result)
    }
}

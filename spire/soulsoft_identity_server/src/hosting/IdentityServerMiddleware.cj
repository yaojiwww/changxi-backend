/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.hosting

import soulsoft_web_http.*
import soulsoft_identity_tokens.*
import soulsoft_identity_server.models.*
import soulsoft_identity_server.validation.*

/**
 * @brief 提供 Identity Server 请求处理中间件。
 */
public class IdentityServerMiddleware <: IMiddleware {
    private let _router: IEndpointRouter

    /**
     * @brief 创建 Identity Server 中间件。
     * @param router 端点路由器。
     */
    public init(router: IEndpointRouter) {
        _router = router
    }

    /**
     * @brief 处理当前请求并分发到 Identity Server 端点。
     * @param context 当前 HTTP 上下文。
     * @param next 下一个请求委托。
     */
    public func invoke(context: HttpContext, next: RequestDelegate): Unit {
        if (let Some(endpoint) <- _router.routing(context)) {
            try {
                let result = endpoint.handle(context)
                result.execute(context)
            } catch (ex: ValidationException) {
                context.response.statusCode = StatusCodes.BadRequest
                let result = ValidationErrorResult(ex.error, ex.description)
                context.response.writeAsJson(result.toJson())
            } catch (ex: SecurityTokenValidationException) {
                context.response.statusCode = StatusCodes.Unauthorized
                let wwwAuthenticateJson = "Bearer error=\"invalid_token\", error_description=\"${ex.message}\", charset=\"UTF-8\""
                context.response.headers.add("WWW-Authenticate", wwwAuthenticateJson)
            }
        } else {
            next(context)
        }
    }
}

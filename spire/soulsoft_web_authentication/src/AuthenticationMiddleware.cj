// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_authentication

import soulsoft_web_http.*

/**
 * @brief 提供请求级身份验证中间件。
 */
public class AuthenticationMiddleware <: IMiddleware {
    private let _schemes: IAuthenticationSchemeProvider

    /**
     * @brief 创建一个身份验证中间件实例。
     * @param schemes 身份验证方案提供器。
     */
    public init(schemes: IAuthenticationSchemeProvider) {
        _schemes = schemes
    }

    /**
     * @brief 在请求管道中执行身份验证处理。
     * @param context 当前 HTTP 上下文。
     * @param next 下一个请求委托。
     */
    public func invoke(context: HttpContext, next: RequestDelegate): Unit {
        // Set IAuthenticationFeature with original path information
        context.features.set<IAuthenticationFeature>(AuthenticationFeature(context.request.path))
        let handlers = context.services.getOrThrow<IAuthenticationHandlerProvider>()
        for (scheme in _schemes.getRequestHandlerSchemes()) {
            let handler = handlers.getHandler(context, scheme.name).flatMap {f => f as IAuthenticationRequestHandler}
            if (let Some(handler) <- handler) {
                if (handler.handleRequest()) {
                    return
                }
            }
        }

        if (let Some(defaultAuthenticate) <- _schemes.getDefaultAuthenticateScheme()) {
            let result = context.authenticate(defaultAuthenticate.name)
            if (let Some(user) <- result.principal) {
                context.user = user
            }
            if (result.succeeded) {
                let features = AuthenticationFeatures(result)
                context.features.set<IHttpAuthenticationFeature>(features)
                context.features.set<IAuthenticateResultFeature>(features)
            }
        }
        next(context)
    }
}

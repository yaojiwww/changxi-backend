// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_cors.infrastructure

import soulsoft_web_http.*
import soulsoft_web_routing.*
import soulsoft_extensions_logging.*
import soulsoft_web_cors.abstractions.*

/**
 * @brief 在请求管道中评估并应用 CORS 策略。
 */
public class CorsMiddleware <: IMiddleware {
    private let _logger: ILogger
    private var _policy: ?CorsPolicy = None
    private var _policyName: ?String = None
    private let _corsService: ICorsService
    private static let corsMiddlewareWithEndpointInvokedValue = Object()

    /**
     * @brief 创建一个使用默认策略解析逻辑的 CORS 中间件。
     * @param corsService 用于评估和应用策略的 CORS 服务。
     * @param loggerFactory 用于创建日志记录器的工厂。
     */
    public init(corsService: ICorsService, loggerFactory: ILoggerFactory) {
        _corsService = corsService
        _logger = loggerFactory.createLogger<CorsMiddleware>()
    }

    /**
     * @brief 创建一个使用指定策略名称的 CORS 中间件。
     * @param corsService 用于评估和应用策略的 CORS 服务。
     * @param loggerFactory 用于创建日志记录器的工厂。
     * @param policyName 要应用的 CORS 策略名称。
     */
    public init(corsService: ICorsService, loggerFactory: ILoggerFactory, policyName: String) {
        _corsService = corsService
        _policyName = policyName
        _logger = loggerFactory.createLogger<CorsMiddleware>()
    }

    /**
     * @brief 创建一个使用指定策略实例的 CORS 中间件。
     * @param corsService 用于评估和应用策略的 CORS 服务。
     * @param loggerFactory 用于创建日志记录器的工厂。
     * @param policy 要应用的 CORS 策略实例。
     */
    public init(corsService: ICorsService, loggerFactory: ILoggerFactory, policy: CorsPolicy) {
        _policy = policy
        _corsService = corsService
        _logger = loggerFactory.createLogger<CorsMiddleware>()
    }

    /**
     * @brief 在当前请求上解析并应用 CORS 策略。
     * @param context 当前 HTTP 请求上下文。
     * @param next 用于继续执行后续中间件的委托。
     */
    public func invoke(context: HttpContext, next: RequestDelegate): Unit {
        let endpoint = context.getEndpoint()

        if (endpoint.isSome()) {
            context.items["__CorsMiddlewareWithEndpointInvoked"] = corsMiddlewareWithEndpointInvokedValue
        }

        if (!context.request.headers.contains(HeaderNames.Origin)) {
            return next(context)
        }

        let corsMetadata = endpoint.flatMap {f => f.metadata.getMetadata<ICorsMetadata>()}

        if (corsMetadata.flatMap {f => f as IDisableCors}.isSome()) {
            let isOptionsRequest = HttpMethods.isOptions(context.request.method)

            let isCorsPreflightRequest = isOptionsRequest && context
                .request
                .headers
                .contains(HeaderNames.AccessControlRequestMethod)

            if (isCorsPreflightRequest) {
                // If this is a preflight request, and we disallow CORS, complete the request
                context.response.statusCode = StatusCodes.NoContent
                return
            }
            return next(context)
        }

        var corsPolicy = _policy
        var policyName = _policyName

        if (let Some(corsPolicyMetadata) <- corsMetadata.flatMap {f => f as ICorsPolicyMetadata}) {
            policyName = None
            corsPolicy = corsPolicyMetadata.policy
        } else if (let Some(enableCorsAttribute) <- corsMetadata.flatMap {f => f as IEnableCors} &&
            enableCorsAttribute.policyName.isSome()) {
            policyName = enableCorsAttribute.policyName
            corsPolicy = None
        }

        if (corsPolicy.isNone()) {
            let corsPolicyProvider = context.services.getOrThrow<ICorsPolicyProvider>()
            corsPolicy = corsPolicyProvider.getPolicy(context, policyName)
        }

        return evaluateAndApplyPolicy(context, next, corsPolicy)
    }

    private func evaluateAndApplyPolicy(context: HttpContext, next: RequestDelegate, corsPolicy: ?CorsPolicy): Unit {
        if (corsPolicy.isNone()) {
            _logger.info("No CORS policy found for the specified request.")
            return next(context)
        }

        let corsResult = _corsService.evaluatePolicy(context, corsPolicy.getOrThrow())

        if (corsResult.isPreflightRequest) {
            _corsService.applyResult(corsResult, context.response)
            context.response.statusCode = StatusCodes.NoContent
            return
        } else {
            context.response.onStarting {
                onResponseStarting(corsResult, context.response)
            }
            return next(context)
        }
    }

    private func onResponseStarting(corsResult: CorsResult, response: HttpResponse): Unit {
        try {
            _corsService.applyResult(corsResult, response)
        } catch (ex: Exception) {
            _logger.error(ex, "Failed to set CORS headers.")
        }
    }
}

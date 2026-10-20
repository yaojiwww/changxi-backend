// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_cors.infrastructure

import std.collection.*
import soulsoft_web_http.*
import soulsoft_extensions_options.*
import soulsoft_web_cors.abstractions.*

/**
 * @brief 提供 CORS 策略评估和响应头写入实现。
 */
public class CorsService <: ICorsService {
    private let _options: CorsOptions

    /**
     * @brief 创建一个 CORS 服务实例。
     * @param options CORS 选项访问器。
     */
    public init(options: IOptions<CorsOptions>) {
        _options = options.value
    }

    /**
     * @brief 使用指定名称的策略评估当前请求。
     * @param context 当前 HTTP 请求上下文。
     * @param policyName 要评估的 CORS 策略名称。
     * @return 返回策略评估结果。
     * @throws IllegalArgumentException 当指定名称的策略不存在时抛出。
     */
    public func evaluatePolicy(context: HttpContext, policyName: String): CorsResult {
        let policy = _options.getPolicy(policyName)
        if (policy.isNone()) {
            throw IllegalArgumentException("No policy found for the specified name '${policyName}'.")
        }
        return evaluatePolicy(context, policy.getOrThrow())
    }

    /**
     * @brief 使用指定策略评估当前请求。
     * @param context 当前 HTTP 请求上下文。
     * @param policy 要评估的 CORS 策略。
     * @return 返回策略评估结果。
     * @throws IllegalArgumentException 当策略同时允许任意源和凭据时抛出。
     */
    public func evaluatePolicy(context: HttpContext, policy: CorsPolicy): CorsResult {
        if (policy.allowAnyOrigin && policy.supportsCredentials) {
            throw IllegalArgumentException(
                "The CORS protocol does not allow specifying a wildcard (any) origin and credentials at the same time. Configure the CORS policy by listing individual origins if credentials needs to be supported.")
        }

        let requestHeaders = context.request.headers
        let origin = requestHeaders.origin.first

        let isOptionsRequest = HttpMethods.isOptions(context.request.method)
        let isPreflightRequest = isOptionsRequest && requestHeaders.accessControlRequestMethod.first.isSome()

        let corsResult = CorsResult()
        corsResult.isPreflightRequest = isPreflightRequest
        corsResult.isOriginAllowed = isOriginAllowed(policy, (origin ?? String.empty))

        if (isPreflightRequest) {
            evaluatePreflightRequest(context, policy, corsResult)
        } else {
            evaluateRequest(context, policy, corsResult)
        }
        return corsResult
    }

    /**
     * @brief 将 CORS 评估结果写入响应头。
     * @param result 要应用的 CORS 评估结果。
     * @param response 要写入头信息的 HTTP 响应。
     */
    public func applyResult(result: CorsResult, response: HttpResponse): Unit {
        if (!result.isOriginAllowed) {
            return
        }

        let headers = response.headers

        if (let Some(allowedOrigin) <- result.allowedOrigin) {
            headers.accessControlAllowOrigin = [allowedOrigin]
        }

        if (result.supportsCredentials) {
            headers.accessControlAllowCredentials = ["true"]
        }

        if (result.isPreflightRequest) {
            if (result.allowedHeaders.size > 0) {
                let values = String.join(result.allowedHeaders |> collectArray, delimiter: ',')
                headers.accessControlAllowHeaders = [values]
            }
            if (result.allowedMethods.size > 0) {
                let values = String.join(result.allowedMethods |> collectArray, delimiter: ',')
                headers.accessControlAllowMethods = [values]
            }
            if (let Some(preflightMaxAge) <- result.preflightMaxAge) {
                headers.accessControlMaxAge = [preflightMaxAge.toSeconds().toString()]
            }
        } else {
            if (result.allowedExposedHeaders.size > 0) {
                let values = String.join(result.allowedExposedHeaders |> collectArray, delimiter: ',')
                headers.accessControlExposeHeaders = [values]
            }
        }

        if (result.varyByOrigin) {
            headers.vary = ["Origin"]
        }
    }

    private func isOriginAllowed(policy: CorsPolicy, origin: String) {
        if (origin.isEmpty()) {
            return false
        }

        if (policy.allowAnyOrigin || policy.isOriginAllowed(origin)) {
            return true
        }

        return false
    }

    private func evaluatePreflightRequest(context: HttpContext, policy: CorsPolicy, result: CorsResult) {
        populateResult(context, policy, result)
    }

    private func evaluateRequest(context: HttpContext, policy: CorsPolicy, result: CorsResult) {
        populateResult(context, policy, result)
    }

    private func populateResult(context: HttpContext, policy: CorsPolicy, result: CorsResult) {
        let headers = context.request.headers

        if (policy.allowAnyOrigin) {
            result.allowedOrigin = CorsConstants.AnyOrigin
            result.varyByOrigin = policy.supportsCredentials
        } else {
            let origin = headers.origin.first
            result.allowedOrigin = origin
            result.varyByOrigin = policy.origins.size > 1 || !policy.isDefaultIsOriginAllowed
        }

        result.supportsCredentials = policy.supportsCredentials
        result.preflightMaxAge = policy.preflightMaxAge

        addHeaderValues(result.allowedExposedHeaders, policy.exposedHeaders)

        let allowedMethods = if (policy.allowAnyMethod) {
            if (result.isPreflightRequest) {
                headers.accessControlRequestMethod
            } else {
                [context.request.method]
            }
        } else {
            policy.methods
        }

        addHeaderValues(result.allowedMethods, allowedMethods)

        let allowedHeaders = if (policy.allowAnyHeader) {
            headers.getCommaSeparatedValues(HeaderNames.AccessControlRequestHeaders)
        } else {
            policy.headers
        }
        addHeaderValues(result.allowedHeaders, allowedHeaders)
    }

    private func addHeaderValues(target: List<String>, headerValues: Collection<String>) {
        if (headerValues.size == 0) {
            return
        }
        target.add(all: headerValues)
    }
}

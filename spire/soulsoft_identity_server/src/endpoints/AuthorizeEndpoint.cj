/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.endpoints

import std.collection.*
import soulsoft_web_http.*
import soulsoft_identity_claims.*
import soulsoft_identity_protocols_oidc.*
import soulsoft_identity_server.hosting.*
import soulsoft_identity_server.services.*
import soulsoft_identity_server.options.*
import soulsoft_identity_server.validation.*
import soulsoft_identity_server.endpoints.generators.*

/**
 * @brief 处理授权端点请求。
 */
public class AuthorizeEndpoint <: EndpointHandler {
    /**
     * @brief 使用授权依赖项创建授权端点处理器。
     * @param userSession 当前用户会话服务。
     * @param requestValidator 授权请求验证器。
     * @param generator 授权响应生成器。
     * @param options 身份服务选项。
     */
    public AuthorizeEndpoint(let userSession: IUserSession, let requestValidator: IAuthorizeRequestValidator,
        let generator: IAuthorizeResponseGenerator, let options: IdentityServerOptions) {}

    /**
     * @brief 处理授权端点请求。
     * @param context 当前 HTTP 上下文。
     * @return 返回授权端点执行结果。
     */
    public func handle(context: HttpContext): IEndpointResult {
        // 1. 提取参数
        let parameters = getParameters(context)
        if (parameters.isNone()) {
            return status(StatusCodes.UnsupportedMediaType)
        }

        // 2. 检查用户登录
        let user = userSession.getUser()
        if (user.isNone()) {
            return buildLoginRedirect(context)
        }

        // 3. 验证请求并处理
        return processAuthorizeRequest(user.getOrThrow(), parameters.getOrThrow(), context)
    }

    // ============ Request Handlers ============

    private func processAuthorizeRequest(user: ClaimsPrincipal, parameters: IValueProvider, context: HttpContext): IEndpointResult {
        try {
            let result = requestValidator.validate(user, parameters)
            return handleValidationResult(result, context)
        } catch (e: ValidationException) {
            return handleValidationError(e, parameters)
        }
    }

    private func handleValidationResult(result: ValidatedAuthorizeRequestResult, context: HttpContext): IEndpointResult {
        match (result) {
            case Success(validatedRequest) =>
                let response = generator.createResponse(validatedRequest)
                return AuthorizeResult(response, validatedRequest)
            case NeedConsent => return buildConsentRedirect(context)
        }
    }

    private func buildConsentRedirect(context: HttpContext): IEndpointResult {
        let requestUrl = buildReturnUrl(context)
        let query = QueryString.create(options.interaction.returnUrlParameter, requestUrl)
        return redirect(options.interaction.consentUrl + query.value)
    }

    private func handleValidationError(error: ValidationException, parameters: IValueProvider): IEndpointResult {
        if (let Some(redirectUri) <- parameters.get(OpenIdConnectParameterNames.RedirectUri)) {
            let state = parameters.get(OpenIdConnectParameterNames.State)
            return buildErrorRedirect(redirectUri, error.error, error.description, state)
        } else {
            return badRequest(error.error, error.description)
        }
    }

    // ============ Parameter Processing ============

    private func getParameters(context: HttpContext): ?IValueProvider {
        if (HttpMethods.isGet(context.request.method)) {
            return context.request.query
        } else if (HttpMethods.isPost(context.request.method)) {
            if (!context.request.hasFormContentType()) {
                return None
            }
            return context.request.form
        } else {
            return None
        }
    }

    // ============ Redirect Builders ============

    private func buildLoginRedirect(context: HttpContext): IEndpointResult {
        let returnUrl = buildReturnUrl(context)
        let targetUrl = options.interaction.loginUrl
        let queryString = QueryString.create(options.interaction.returnUrlParameter, returnUrl)
        return redirect("${targetUrl}${queryString.value}")
    }

    private func buildReturnUrl(context: HttpContext): String {
        let path = context.request.path.value
        let queryString = context.request.queryString.value
        return "${path}${queryString}"
    }

    private func buildErrorRedirect(redirectUri: String, error: String, errorDescription: ?String, state: ?String): IEndpointResult {
        let parameters = ArrayList<(String, String)>()
        parameters.add(("error", error))

        if (let Some(description) <- errorDescription) {
            parameters.add(("error_description", description))
        }

        if (let Some(stateValue) <- state) {
            parameters.add(("state", stateValue))
        }

        let queryString = QueryString.create(parameters)
        return redirect("${redirectUri}${queryString}")
    }
}

/**
 * @brief 表示授权端点的成功响应结果。
 */
public class AuthorizeResult <: IEndpointResult {
    /**
     * @brief 使用授权响应和验证结果创建端点结果。
     * @param response 授权响应数据。
     * @param result 已验证的授权请求。
     */
    public AuthorizeResult(let response: AuthorizeResponse, let result: ValidatedAuthorizeRequest) {
    }

    /**
     * @brief 将授权结果写入 HTTP 响应。
     * @param context 当前 HTTP 上下文。
     */
    public func execute(context: HttpContext): Unit {
        let parameters = buildResponseParameters()

        let responseMode = result.responseMode ?? "query"
        match (responseMode) {
            case "fragment" => respondWithFragment(context, parameters)
            case "form_post" => respondWithFormPost(context, parameters)
            case _ => respondWithQuery(context, parameters)
        }
    }

    private func buildResponseParameters(): ArrayList<(String, String)> {
        let parameters = ArrayList<(String, String)>()
        parameters.add(("code", response.code))

        if (let Some(state) <- result.state) {
            parameters.add(("state", state))
        }

        return parameters
    }

    private func respondWithQuery(context: HttpContext, parameters: ArrayList<(String, String)>): Unit {
        let queryString = QueryString.create(parameters)
        context.response.redirect("${result.redirectUri}${queryString}")
    }

    private func respondWithFragment(context: HttpContext, parameters: ArrayList<(String, String)>): Unit {
        let fragmentString = buildFragmentString(parameters)
        context.response.redirect("${result.redirectUri}#${fragmentString}")
    }

    private func buildFragmentString(parameters: ArrayList<(String, String)>): String {
        let parts = ArrayList<String>()
        for ((key, value) in parameters) {
            parts.add("${key}=${HttpUtility.urlEncode(value)}")
        }
        return String.join(parts.toArray(), delimiter: "&")
    }

    private func respondWithFormPost(context: HttpContext, parameters: ArrayList<(String, String)>): Unit {
        let html = buildFormPostHtml(result.redirectUri, parameters)
        context.response.statusCode = StatusCodes.Ok
        context.response.contentType = "text/html; charset=utf-8"
        context.response.write(html)
    }

    private func buildFormPostHtml(redirectUri: String, parameters: ArrayList<(String, String)>): String {
        let formInputs = buildFormInputs(parameters)
        return """
        <!DOCTYPE html>
        <html>
        <head><title>Submitting Form...</title></head>
        <body onload="document.forms[0].submit()">
            <form method="POST" action="${escapeHtml(
            redirectUri)}">
                ${String.join(formInputs.toArray(), delimiter: "\n")}
                <noscript>
                    <p>JavaScript is disabled. Please click the button below to continue.</p>
                    <button type="submit">Continue</button>
                </noscript>
            </form>
        </body>
        </html>
        """
    }

    private func buildFormInputs(parameters: ArrayList<(String, String)>): ArrayList<String> {
        let formInputs = ArrayList<String>()
        for ((key, value) in parameters) {
            formInputs.add("<input type=\"hidden\" name=\"${escapeHtml(key)}\" value=\"${escapeHtml(value)}\" />")
        }
        return formInputs
    }

    private func escapeHtml(value: String): String {
        return value
            .replace("&", "&amp;")
            .replace("<", "&lt;")
            .replace(">", "&gt;")
            .replace("\"", "&quot;")
            .replace("'", "&#39;")
    }
}

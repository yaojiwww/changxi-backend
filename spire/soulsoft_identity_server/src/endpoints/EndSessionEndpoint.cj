/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.endpoints

import std.collection.*
import soulsoft_web_http.*
import soulsoft_identity_tokens.*
import soulsoft_identity_server.hosting.*
import soulsoft_identity_server.services.*
import soulsoft_identity_server.validation.*

/**
 * @brief 处理结束会话端点请求。
 */
public class EndSessionEndpoint <: EndpointHandler {
    /**
     * @brief 使用会话服务和请求验证器创建结束会话端点处理器。
     * @param userSession 当前用户会话服务。
     * @param requestValidator 结束会话请求验证器。
     */
    public EndSessionEndpoint(let userSession: IUserSession, let requestValidator: IEndSessionRequestValidator) {
    }

    /**
     * @brief 处理结束会话请求。
     * @param context 当前 HTTP 上下文。
     * @return 返回结束会话执行结果。
     */
    public func handle(context: HttpContext): IEndpointResult {
        let parameters = getParameters(context)
        if (parameters.isNone()) {
            return status(StatusCodes.UnsupportedMediaType)
        }

        let user = userSession.getUser()
        if (user.isNone()) {
            return status(StatusCodes.Unauthorized)
        }
        let subject = user.getOrThrow()
        let validatedRequest = requestValidator.validate(parameters.getOrThrow(), subject)
        if (let Some(postLogoutRedirectUri) <- validatedRequest.postLogoutRedirectUri) {
            let redirectUrl = buildSuccessRedirect(postLogoutRedirectUri, validatedRequest.state)
            userSession.signOut(None)
            return redirect(redirectUrl)
        } else {
            return status(StatusCodes.Ok)
        }
    }

    private func buildSuccessRedirect(postLogoutRedirectUri: String, state: ?String): String {
        let params = ArrayList<(String, String)>()

        if (let Some(state) <- state) {
            params.add(("state", state))
        }

        let queryString = QueryString.create(params).value

        return "${postLogoutRedirectUri}${queryString}"
    }

    private func getParameters(context: HttpContext): ?IValueProvider {
        if (HttpMethods.isGet(context.request.method)) {
            return context.request.query
        }

        if (HttpMethods.isPost(context.request.method) && context.request.hasFormContentType()) {
            return context.request.form
        }

        return None
    }
}

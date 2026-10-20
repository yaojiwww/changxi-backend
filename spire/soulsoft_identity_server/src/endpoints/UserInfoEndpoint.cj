/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.endpoints

import soulsoft_web_http.*
import soulsoft_identity_tokens.*
import soulsoft_identity_tokens_jwt.*
import soulsoft_identity_server.options.*
import soulsoft_identity_server.hosting.*
import soulsoft_identity_server.services.*
import soulsoft_identity_server.validation.*
import soulsoft_identity_server.endpoints.generators.*

/**
 * @brief 处理用户信息端点请求。
 */
public class UserInfoEndpoint <: EndpointHandler {
    /**
     * @brief 使用用户信息请求依赖项创建端点处理器。
     * @param tokenParser 访问令牌解析器。
     * @param requestValidator 用户信息请求验证器。
     * @param responseGenerator 用户信息响应生成器。
     * @param options 身份服务选项。
     */
    public UserInfoEndpoint(let tokenParser: ITokenParser, let requestValidator: IUserInfoRequestValidator,
        let responseGenerator: IUserInfoResponseGenerator, let options: IdentityServerOptions) {
    }

    /**
     * @brief 处理用户信息请求。
     * @param context 当前 HTTP 上下文。
     * @return 返回用户信息响应结果。
     */
    public func handle(context: HttpContext): IEndpointResult {
        if (!HttpMethods.isGet(context.request.method) && !HttpMethods.isPost(context.request.method)) {
            return status(StatusCodes.MethodNotAllowed)
        }

        let accessToken = tokenParser.tryParse(context).getOrThrow {
            ValidationException(ValidationErrors.InvalidToken, "Failed to parse access token from request")
        }

        // 验证请求
        let validatedRequest = requestValidator.validate(accessToken)

        // 使用 Generator 生成 Claims
        let outputClaims = responseGenerator.createResponse(validatedRequest)

        // 构建 UserInfo 响应
        let result = JwtPayload(outputClaims).serializeToJson()

        return json(result)
    }
}

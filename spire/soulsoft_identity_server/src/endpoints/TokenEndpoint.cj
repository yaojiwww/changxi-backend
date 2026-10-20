/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.endpoints

import soulsoft_web_http.*
import soulsoft_identity_server.hosting.*
import soulsoft_identity_server.validation.*
import soulsoft_identity_server.endpoints.generators.*

/**
 * @brief 处理令牌端点请求。
 */
public class TokenEndpoint <: EndpointHandler {
    /**
     * @brief 使用令牌请求依赖项创建令牌端点处理器。
     * @param clientSecretValidator 客户端密钥验证器。
     * @param requestValidator 令牌请求验证器。
     * @param responseGenerator 令牌响应生成器。
     */
    public TokenEndpoint(let clientSecretValidator: IClientSecretValidator,
        let requestValidator: ITokenRequestValidator, let responseGenerator: ITokenResponseGenerator) {
    }

    /**
     * @brief 处理令牌端点请求。
     * @param context 当前 HTTP 上下文。
     * @return 返回令牌端点执行结果。
     */
    public func handle(context: HttpContext): IEndpointResult {
        if (!HttpMethods.isPost(context.request.method)) {
            return status(StatusCodes.MethodNotAllowed)
        }

        if (!context.request.hasFormContentType()) {
            return badRequest(ValidationErrors.InvalidRequest, "Content-Type must be application/x-www-form-urlencoded")
        }

        // 验证客户端凭证
        let clientSecretResult = clientSecretValidator.validate(context)

        // 验证 token 请求
        let parameters = context.request.form
        let tokenValidationResult = requestValidator.validate(clientSecretResult.client, parameters)

        // 生成令牌响应
        let tokenResponse = responseGenerator.createToken(tokenValidationResult)

        return json(tokenResponse.toJson())
    }
}

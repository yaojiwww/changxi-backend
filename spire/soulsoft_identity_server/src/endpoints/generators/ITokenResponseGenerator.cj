/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.endpoints.generators

import stdx.encoding.json.*
import soulsoft_identity_protocols_oidc.*
import soulsoft_identity_server.validation.*

/**
 * @brief 定义令牌响应生成器接口。
 */
public interface ITokenResponseGenerator {
    /**
     * @brief 根据验证通过的令牌请求创建响应。
     * @param request 验证通过的令牌请求。
     * @return 返回令牌响应对象。
     */
    func createToken(request: ValidatedTokenRequest): TokenResponse
}

/**
 * @brief 表示令牌响应结果。
 */
public class TokenResponse {
    /**
     * @brief 创建令牌响应结果。
     * @param accessToken 访问令牌字符串。
     * @param idToken 身份令牌字符串。
     * @param refreshToken 刷新令牌字符串。
     * @param expiresIn 过期秒数。
     * @param scopes 响应作用域数组。
     */
    public TokenResponse(public let accessToken: String, public let idToken: ?String, public let refreshToken: ?String,
        public let expiresIn: Int64, public let scopes: Array<String>) {
    }

    /**
     * @brief 将令牌响应转换为 JSON 对象。
     * @return 返回 JSON 对象。
     */
    public func toJson(): JsonObject {
        var obj = JsonObject()
        if (let Some(idToken) <- idToken) {
            obj.put(OpenIdConnectParameterNames.IdToken, JsonString(idToken))
        }
        obj.put(OpenIdConnectParameterNames.AccessToken, JsonString(accessToken))
        if (let Some(refreshToken) <- refreshToken) {
            obj.put(OpenIdConnectParameterNames.RefreshToken, JsonString(refreshToken))
        }
        obj.put(OpenIdConnectParameterNames.ExpiresIn, JsonInt(expiresIn))
        obj.put(OpenIdConnectParameterNames.TokenType, JsonString("Bearer"))
        if (scopes.size > 0) {
            let scopes = String.join(scopes, delimiter: ' ')
            obj.put(OpenIdConnectParameterNames.Scope, JsonString(scopes))
        }
        return obj
    }
}

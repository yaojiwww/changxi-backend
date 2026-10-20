/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.validation

import soulsoft_web_http.*
import soulsoft_identity_claims.*
import soulsoft_identity_server.models.*

/**
 * @brief 定义令牌请求验证器接口。
 */
public interface ITokenRequestValidator {
    /**
     * @brief 验证令牌请求参数。
     * @param client 当前客户端。
     * @param parameters 请求参数提供程序。
     * @return 返回验证后的令牌请求。
     */
    func validate(client: Client, parameters: IValueProvider): ValidatedTokenRequest
}

/**
 * @brief 表示验证通过的令牌请求。
 */
public class ValidatedTokenRequest {
    /**
     * @brief 创建验证通过的令牌请求。
     * @param client 当前客户端。
     * @param resources 请求对应的资源集合。
     * @param subject 当前主体。
     * @param grantType 授权类型。
     * @param refreshTokenHandle 刷新令牌句柄。
     * @param refreshToken 刷新令牌对象。
     */
    public ValidatedTokenRequest(public let client: Client, public let resources: ResourceCollection,
        public let subject: ClaimsPrincipal, public let grantType: String, public let refreshTokenHandle: ?String,
        public let refreshToken: ?RefreshToken) {
    }
}

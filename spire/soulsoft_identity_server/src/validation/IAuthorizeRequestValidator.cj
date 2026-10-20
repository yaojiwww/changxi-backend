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
 * @brief 定义授权请求验证器接口。
 */
public interface IAuthorizeRequestValidator {
    /**
     * @brief 验证授权请求。
     * @param user 当前用户主体。
     * @param parameters 请求参数提供程序。
     * @return 返回授权请求验证结果。
     */
    func validate(user: ClaimsPrincipal, parameters: IValueProvider): ValidatedAuthorizeRequestResult
}

/**
 * @brief 表示授权请求验证结果。
 */
public enum ValidatedAuthorizeRequestResult {
    /**
     * @brief 表示授权请求验证成功。
     */
    Success(ValidatedAuthorizeRequest)
    /**
     * @brief 表示当前请求需要用户同意。
     */
    | NeedConsent
}

/**
 * @brief 表示验证通过的授权请求。
 */
public class ValidatedAuthorizeRequest {
    /**
     * @brief 创建验证通过的授权请求。
     * @param state 状态参数。
     * @param scope 请求作用域。
     * @param nonce 随机数参数。
     * @param clientId 客户端标识。
     * @param redirectUri 回调地址。
     * @param responseType 响应类型。
     * @param responseMode 响应模式。
     * @param client 当前客户端。
     * @param subject 当前用户主体。
     * @param resources 请求对应的资源集合。
     * @param codeChallenge PKCE 挑战值。
     * @param codeChallengeMethod PKCE 挑战方法。
     */
    public ValidatedAuthorizeRequest(
        public let state!: ?String,
        public let scope!: String,
        public let nonce!: ?String,
        public let clientId!: String,
        public let redirectUri!: String,
        public let responseType!: String,
        public let responseMode!: ?String,
        public let client!: Client,
        public let subject!: ClaimsPrincipal,
        public let resources!: ResourceCollection,
        public let codeChallenge!: ?String,
        public let codeChallengeMethod!: ?String
    ) {
    }
}

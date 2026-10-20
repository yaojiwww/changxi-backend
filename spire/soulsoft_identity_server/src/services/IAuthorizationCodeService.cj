/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.services

import soulsoft_identity_server.models.*

/**
 * @brief 定义授权码服务接口。
 */
public interface IAuthorizationCodeService {
    /**
     * @brief 验证授权码请求。
     * @param request 授权码验证请求。
     * @return 返回验证通过的授权码对象。
     */
    func validate(request: AuthorizationCodeValidationRequest): AuthorizationCode
}

/**
 * @brief 表示授权码验证请求。
 */
public class AuthorizationCodeValidationRequest {
    /**
     * @brief 创建授权码验证请求。
     * @param code 授权码字符串。
     * @param client 当前客户端。
     * @param redirectUri 回调地址。
     * @param codeVerifier PKCE 验证值。
     */
    public AuthorizationCodeValidationRequest(public let code: String, public let client: Client,
        public let redirectUri: String, public let codeVerifier: ?String) {
    }
}

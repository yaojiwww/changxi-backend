/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.validation

import soulsoft_identity_claims.*
import soulsoft_identity_server.models.*

/**
 * @brief 定义用户信息请求验证器接口。
 */
public interface IUserInfoRequestValidator {
    /**
     * @brief 验证用户信息请求中的访问令牌。
     * @param accessToken 访问令牌字符串。
     * @return 返回验证通过的用户信息请求。
     */
    func validate(accessToken: String): ValidatedUserInfoRequest
}

/**
 * @brief 表示验证通过的用户信息请求。
 */
public class ValidatedUserInfoRequest {
    /**
     * @brief 创建验证通过的用户信息请求。
     * @param client 当前客户端。
     * @param subject 当前主体。
     */
    public ValidatedUserInfoRequest(public let client: Client, public let subject: ClaimsPrincipal) {}
}

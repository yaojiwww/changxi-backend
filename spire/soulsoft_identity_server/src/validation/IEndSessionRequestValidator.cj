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
 * @brief 定义结束会话请求验证器接口。
 */
public interface IEndSessionRequestValidator {
    /**
     * @brief 验证结束会话请求。
     * @param parameters 请求参数提供程序。
     * @param subject 当前主体。
     * @return 返回验证通过的结束会话请求。
     */
    func validate(parameters: IValueProvider, subject: ClaimsPrincipal): ValidatedEndSessionRequest
}

/**
 * @brief 表示验证通过的结束会话请求。
 */
public class ValidatedEndSessionRequest {
    /**
     * @brief 保存结束会话对应的客户端。
     */
    public let client: ?Client
    /**
     * @brief 保存登出后跳转地址。
     */
    public let postLogoutRedirectUri: ?String
    /**
     * @brief 保存结束会话状态值。
     */
    public let state: ?String
    /**
     * @brief 保存身份令牌提示。
     */
    public let idTokenHint: ?String

    /**
     * @brief 创建验证通过的结束会话请求。
     * @param client 当前客户端。
     * @param postLogoutRedirectUri 登出后跳转地址。
     * @param state 结束会话状态值。
     * @param idTokenHint 身份令牌提示。
     */
    public init(client: ?Client, postLogoutRedirectUri: ?String, state: ?String, idTokenHint: ?String) {
        this.client = client
        this.postLogoutRedirectUri = postLogoutRedirectUri
        this.state = state
        this.idTokenHint = idTokenHint
    }
}

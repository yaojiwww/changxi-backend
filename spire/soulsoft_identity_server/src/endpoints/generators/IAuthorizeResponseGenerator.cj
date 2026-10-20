/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.endpoints.generators

import soulsoft_identity_server.validation.*

/**
 * @brief 定义授权响应生成器接口。
 */
public interface IAuthorizeResponseGenerator {
    /**
     * @brief 根据验证通过的授权请求创建响应。
     * @param request 验证通过的授权请求。
     * @return 返回授权响应对象。
     */
    func createResponse(request: ValidatedAuthorizeRequest): AuthorizeResponse
}

/**
 * @brief 表示授权响应结果。
 */
public class AuthorizeResponse {
    /**
     * @brief 创建授权响应结果。
     * @param code 授权码。
     */
    public AuthorizeResponse(public let code: String) {}
}

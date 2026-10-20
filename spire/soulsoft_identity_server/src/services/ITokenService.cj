/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.services

import soulsoft_identity_claims.*
import soulsoft_identity_server.models.*

/**
 * @brief 定义令牌服务接口。
 */
public interface ITokenService {
    /**
     * @brief 创建访问令牌对象。
     * @param request 令牌创建请求。
     * @return 返回访问令牌对象。
     */
    func createAccessToken(request: TokenCreationRequest): Token
    /**
     * @brief 创建身份令牌对象。
     * @param request 令牌创建请求。
     * @return 返回身份令牌对象。
     */
    func createIdentityToken(request: TokenCreationRequest): Token
    /**
     * @brief 将令牌对象序列化为安全令牌字符串。
     * @param token 令牌对象。
     * @return 返回安全令牌字符串。
     */
    func createSecurityToken(token: Token): String
}

/**
 * @brief 表示令牌创建请求。
 */
public class TokenCreationRequest {
    /**
     * @brief 创建令牌请求。
     * @param claims 令牌声明集合。
     * @param client 当前客户端。
     * @param resources 当前资源集合。
     */
    public TokenCreationRequest(public let claims: Collection<Claim>, public let client: Client,
        public let resources: ResourceCollection) {
    }
}

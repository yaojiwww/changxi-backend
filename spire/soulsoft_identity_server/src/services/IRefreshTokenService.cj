/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.services

import soulsoft_identity_server.models.*

/**
 * @brief 定义刷新令牌服务接口。
 */
public interface IRefreshTokenService {
    /**
     * @brief 更新刷新令牌并返回新的句柄。
     * @param request 刷新令牌更新请求。
     * @return 返回新的刷新令牌句柄。
     */
    func updateRefreshToken(request: RefreshTokenUpdateRequest): String
    /**
     * @brief 创建新的刷新令牌句柄。
     * @param request 刷新令牌创建请求。
     * @return 返回刷新令牌句柄。
     */
    func createRefreshToken(request: RefreshTokenCreationRequest): String
}

/**
 * @brief 表示刷新令牌更新请求。
 */
public class RefreshTokenUpdateRequest {
    /**
     * @brief 创建刷新令牌更新请求。
     * @param refreshTokenHandle 刷新令牌句柄。
     * @param refreshToken 刷新令牌对象。
     * @param client 当前客户端。
     * @param resources 当前资源集合。
     */
    public RefreshTokenUpdateRequest(public let refreshTokenHandle: String, public let refreshToken: RefreshToken,
        public let client: Client, public let resources: ResourceCollection) {
    }
}

/**
 * @brief 表示刷新令牌创建请求。
 */
public class RefreshTokenCreationRequest {
    /**
     * @brief 创建刷新令牌创建请求。
     * @param accessToken 访问令牌对象。
     * @param client 当前客户端。
     * @param resources 当前资源集合。
     */
    public RefreshTokenCreationRequest(public let accessToken: Token, public let client: Client,
        public let resources: ResourceCollection) {
    }
}

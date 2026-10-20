/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.stores

import soulsoft_identity_server.models.*

/**
 * @brief 定义刷新令牌存储接口。
 */
public interface IRefreshTokenStore {
    /**
     * @brief 根据句柄查找刷新令牌。
     * @param key 刷新令牌句柄。
     * @return 返回刷新令牌对象；不存在时返回空。
     */
    func find(key: String): ?RefreshToken
    /**
     * @brief 存储刷新令牌并返回句柄。
     * @param token 刷新令牌对象。
     * @return 返回刷新令牌句柄。
     */
    func store(token: RefreshToken): String
    /**
     * @brief 更新指定句柄的刷新令牌。
     * @param key 刷新令牌句柄。
     * @param token 刷新令牌对象。
     */
    func update(key: String, token: RefreshToken): Unit
    /**
     * @brief 删除指定刷新令牌。
     * @param key 刷新令牌句柄。
     */
    func remove(key: String): Unit
}

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.stores

import soulsoft_identity_server.models.*

/**
 * @brief 定义授权码存储接口。
 */
public interface IAuthorizationCodeStore {
    /**
     * @brief 根据授权码句柄查找授权码对象。
     * @param code 授权码句柄。
     * @return 返回授权码对象；不存在时返回空。
     */
    func find(code: String): ?AuthorizationCode
    /**
     * @brief 存储授权码对象并返回句柄。
     * @param code 授权码对象。
     * @return 返回授权码句柄。
     */
    func store(code: AuthorizationCode): String
    /**
     * @brief 删除指定授权码。
     * @param code 授权码句柄。
     */
    func remove(code: String): Unit
}

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.stores

import soulsoft_identity_server.models.*

/**
 * @brief 定义用户同意存储接口。
 */
public interface IConsentStore {
    /**
     * @brief 存储用户同意记录。
     * @param consent 用户同意对象。
     */
    func store(consent: Consent): Unit
    /**
     * @brief 根据主体和客户端查找同意记录。
     * @param sub 主体标识。
     * @param clientId 客户端标识。
     * @return 返回匹配的同意记录；不存在时返回空。
     */
    func find(sub: String, clientId: String): ?Consent
    /**
     * @brief 删除指定主体和客户端的同意记录。
     * @param sub 主体标识。
     * @param clientId 客户端标识。
     */
    func remove(sub: String, clientId: String): Unit
}

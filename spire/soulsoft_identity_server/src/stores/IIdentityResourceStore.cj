/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.stores

import soulsoft_identity_server.models.*

/**
 * @brief 定义身份资源存储接口。
 */
public interface IIdentityResourceStore {
    /**
     * @brief 根据作用域集合查找身份资源。
     * @param scopes 作用域数组。
     * @return 返回匹配的身份资源集合。
     */
    func findAll(scopes: Array<String>): Collection<IdentityResource>
    /**
     * @brief 获取发现文档需要公开的身份作用域集合。
     * @return 返回作用域集合。
     */
    func getDiscoveryDocumentScopes(): Collection<String> 
    /**
     * @brief 获取发现文档需要公开的声明类型集合。
     * @return 返回声明类型集合。
     */
    func getDiscoveryDocumentClaimTypes(): Collection<String>
}

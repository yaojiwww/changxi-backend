/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.stores

import soulsoft_identity_server.models.*

/**
 * @brief 定义 API 资源存储接口。
 */
public interface IApiResourceStore {
    /**
     * @brief 根据作用域集合查找 API 资源。
     * @param scopes 作用域数组。
     * @return 返回匹配的 API 资源集合。
     */
    func findAll(scopes: Array<String>): Collection<ApiResource>
    /**
     * @brief 获取发现文档需要公开的声明类型集合。
     * @return 返回声明类型集合。
     */
    func getDiscoveryDocumentClaimTypes(): Collection<String>
}

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.services

import std.collection.*
import soulsoft_identity_server.stores.*
import soulsoft_identity_server.models.*

/**
 * @brief 提供资源聚合与查询服务。
 */
public class ResourceManager {
    /**
     * @brief 创建资源管理器。
     * @param apiScopeStore API 作用域存储。
     * @param apiResourceStore API 资源存储。
     * @param identityResourceStore 身份资源存储。
     */
    public ResourceManager(let apiScopeStore: IApiScopeStore, let apiResourceStore: IApiResourceStore,
        let identityResourceStore: IIdentityResourceStore) {
    }

    /**
     * @brief 根据作用域集合查找全部相关资源。
     * @param scopes 作用域数组。
     * @return 返回聚合后的资源集合。
     */
    public func findAll(scopes: Array<String>): ResourceCollection {
        let apiScopes = apiScopeStore.findAll(scopes)
        let apiResources = apiResourceStore.findAll(apiScopes |> map {f => f.name} |> collectArray)
        let identityResources = identityResourceStore.findAll(scopes)
        return createResources(apiScopes, apiResources, identityResources)
    }

    /**
     * @brief 获取发现文档需要公开的全部作用域集合。
     * @return 返回作用域集合。
     */
    public func getDiscoveryDocumentScopes(): Collection<String> {
        let list = ArrayList<String>()
        list.add(all: apiScopeStore.getDiscoveryDocumentScopes())
        list.add(all: identityResourceStore.getDiscoveryDocumentScopes())
        return list
    }

    /**
     * @brief 获取发现文档需要公开的全部声明类型集合。
     * @return 返回声明类型集合。
     */
    public func getDiscoveryDocumentClaimTypes(): Collection<String> {
        let list = ArrayList<String>()
        list.add(all: apiScopeStore.getDiscoveryDocumentClaimTypes())
        list.add(all: apiResourceStore.getDiscoveryDocumentClaimTypes())
        list.add(all: identityResourceStore.getDiscoveryDocumentClaimTypes())
        return list
    }

    private func createResources(apiScopes: Collection<ApiScope>, apiResources: Collection<ApiResource>,
        identityResources: Collection<IdentityResource>) {
        let resources = ArrayList<ResourceBase>()
        for (pattern in apiScopes) {
            resources.add(pattern)
        }
        for (pattern in apiResources) {
            resources.add(pattern)
        }
        for (pattern in identityResources) {
            resources.add(pattern)
        }
        return ResourceCollection(resources)
    }
}

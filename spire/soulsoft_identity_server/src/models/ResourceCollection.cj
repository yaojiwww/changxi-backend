/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.models

import std.collection.*
import stdx.serialization.serialization.*
import soulsoft_identity_protocols_oidc.*

/**
 * @brief 表示资源集合包装类型。
 */
public class ResourceCollection <: Collection<ResourceBase> {
    private let _items: Collection<ResourceBase>

    /**
     * @brief 使用资源集合创建包装对象。
     * @param items 资源集合。
     */
    public init(items: Collection<ResourceBase>) {
        _items = items
    }

    /**
     * @brief 返回资源数量。
     * @return 返回资源数量。
     */
    public prop size: Int64 {
        get() {
            _items.size
        }
    }

    /**
     * @brief 返回资源集合迭代器。
     * @return 返回资源集合迭代器。
     */
    public func iterator(): Iterator<ResourceBase> {
        _items.iterator()
    }

    /**
     * @brief 检查资源集合是否为空。
     * @return 如果资源集合为空则返回 `true`。
     */
    public func isEmpty(): Bool {
        _items.isEmpty()
    }

    /**
     * @brief 获取全部作用域名称。
     * @return 返回作用域名称数组。
     */
    public func getScopes(): Array<String> {
        _items |> filterMap {
            f => if (f is IScope) {
                f
            } else {
                Option<ResourceBase>.None
            }
        } |> map {f => f.name} |> collectArray
    }

    /**
     * @brief 获取全部 API 作用域资源。
     * @return 返回 API 作用域数组。
     */
    public func getApiScopes(): Array<ApiScope> {
        _items |> filterMap {f => f as ApiScope} |> collectArray
    }

    /**
     * @brief 获取全部 API 资源。
     * @return 返回 API 资源数组。
     */
    public func getApiResources(): Array<ApiResource> {
        _items |> filterMap {f => f as ApiResource} |> collectArray
    }

    /**
     * @brief 获取全部身份资源。
     * @return 返回身份资源数组。
     */
    public func getIdentityResources(): Array<IdentityResource> {
        _items |> filterMap {f => f as IdentityResource} |> collectArray
    }

    /**
     * @brief 检查资源集合是否允许离线访问。
     * @return 如果允许离线访问则返回 `true`。
     */
    public func isAllowedOfflineAccess(): Bool {
        getApiScopes() |> any {f => f.name == OpenIdConnectScopes.OfflineAccess}
    }
}

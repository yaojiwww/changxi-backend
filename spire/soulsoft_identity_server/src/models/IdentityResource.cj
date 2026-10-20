/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.models

import std.collection.*
import soulsoft_identity_claims.*
import soulsoft_identity_protocols_oidc.*
import stdx.serialization.serialization.*

/**
 * @brief 表示 OpenID Connect 身份资源定义。
 */
public class IdentityResource <: ResourceBase & IScope & Serializable<IdentityResource> {
    /**
     * @brief 标识当前身份资源是否必须被显式授予。
     */
    public var required = false

    /**
     * @brief 表示标准 `openid` 身份资源。
     */
    public static let OpenId = IdentityResource(OpenIdConnectScopes.OpenId, [ClaimTypes.Sub])
    /**
     * @brief 表示标准 `profile` 身份资源。
     */
    public static let Profile = IdentityResource(OpenIdConnectScopes.Profile, [ClaimTypes.Profile])
    /**
     * @brief 表示标准 `email` 身份资源。
     */
    public static let Email = IdentityResource(OpenIdConnectScopes.Email, [ClaimTypes.Email])
    /**
     * @brief 表示标准 `address` 身份资源。
     */
    public static let Address = IdentityResource(OpenIdConnectScopes.Address, [ClaimTypes.Address])

    /**
     * @brief 创建空的身份资源实例。
     */
    public init() {
    }

    /**
     * @brief 使用名称和声明类型创建身份资源。
     * @param name 身份资源名称。
     * @param claimTypes 关联的声明类型列表。
     */
    public init(name: String, claimTypes: Array<String>) {
        this.name = name
        this.claimTypes = claimTypes
    }

    /**
     * @brief 使用名称和描述创建身份资源。
     * @param name 身份资源名称。
     * @param description 身份资源描述。
     */
    public init(name: String, description: ?String) {
        this.name = name
        this.description = description
    }

    /**
     * @brief 将当前身份资源序列化为数据模型。
     * @return 返回身份资源对应的数据模型结构。
     */
    public func serialize(): DataModelStruct {
        let dms = DataModelStruct()
        dms.add(field("enabled", enabled))
        dms.add(field("name", name))
        dms.add(field("description", description))
        dms.add(field("displayName", displayName))
        dms.add(field("claimTypes", claimTypes))
        dms.add(field("discoveryDocument", discoveryDocument))
        dms.add(field("properties", properties))
        dms.add(field("required", required))
        return dms
    }

    /**
     * @brief 从数据模型反序列化身份资源。
     * @param dm 身份资源对应的数据模型。
     * @return 返回反序列化后的身份资源。
     * @throws DataModelException 当数据模型不是结构类型时抛出。
     */
    public static func deserialize(dm: DataModel): IdentityResource {
        let dms = match (dm) {
            case dms: DataModelStruct => dms
            case _ => throw DataModelException("This data is not DataModelStruct.")
        }
        let result = IdentityResource()
        result.enabled = Bool.deserialize(dms.get("enabled"))
        result.name = String.deserialize(dms.get("name"))
        result.description = Option<String>.deserialize(dms.get("description"))
        result.displayName = Option<String>.deserialize(dms.get("displayName"))
        result.claimTypes = Array<String>.deserialize(dms.get("claimTypes"))
        result.discoveryDocument = Bool.deserialize(dms.get("discoveryDocument"))
        result.properties = HashMap<String, String>.deserialize(dms.get("properties"))
        result.required = Bool.deserialize(dms.get("required"))
        return result
    }
}

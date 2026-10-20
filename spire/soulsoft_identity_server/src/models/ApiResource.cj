/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.models

import std.collection.*
import stdx.serialization.serialization.*

/**
 * @brief 表示受保护 API 资源定义。
 */
public class ApiResource <: ResourceBase & Serializable<ApiResource> {
    /**
     * @brief 保存当前 API 资源允许访问的作用域列表。
     */
    public var allowedScopes: Array<String> = []
    /**
     * @brief 保存当前 API 资源可用的密钥列表。
     */
    public var apiSecrets: Array<Secret> = []

    /**
     * @brief 创建空的 API 资源实例。
     */
    public init() {
    }

    /**
     * @brief 使用名称和作用域创建 API 资源。
     * @param name API 资源名称。
     * @param allowedScopes 允许访问的作用域列表。
     */
    public init(name: String, allowedScopes: Array<String>) {
        this.name = name
        this.allowedScopes = allowedScopes
    }

    /**
     * @brief 使用名称、描述和作用域创建 API 资源。
     * @param name API 资源名称。
     * @param description API 资源描述。
     * @param allowedScopes 允许访问的作用域列表。
     */
    public init(name: String, description: ?String, allowedScopes: Array<String>) {
        this.name = name
        this.description = description
        this.allowedScopes = allowedScopes
    }

    /**
     * @brief 将当前 API 资源序列化为数据模型。
     * @return 返回 API 资源对应的数据模型结构。
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
        dms.add(field("allowedScopes", allowedScopes))
        dms.add(field("apiSecrets", apiSecrets))
        return dms
    }

    /**
     * @brief 从数据模型反序列化 API 资源。
     * @param dm API 资源对应的数据模型。
     * @return 返回反序列化后的 API 资源。
     * @throws DataModelException 当数据模型不是结构类型时抛出。
     */
    public static func deserialize(dm: DataModel): ApiResource {
        let dms = match (dm) {
            case dms: DataModelStruct => dms
            case _ => throw DataModelException("This data is not DataModelStruct.")
        }
        let result = ApiResource()
        result.enabled = Bool.deserialize(dms.get("enabled"))
        result.name = String.deserialize(dms.get("name"))
        result.description = Option<String>.deserialize(dms.get("description"))
        result.displayName = Option<String>.deserialize(dms.get("displayName"))
        result.claimTypes = Array<String>.deserialize(dms.get("claimTypes"))
        result.discoveryDocument = Bool.deserialize(dms.get("discoveryDocument"))
        result.properties = HashMap<String, String>.deserialize(dms.get("properties"))
        result.allowedScopes = Array<String>.deserialize(dms.get("allowedScopes"))
        result.apiSecrets = Array<Secret>.deserialize(dms.get("apiSecrets"))
        return result
    }
}

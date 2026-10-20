/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.models

import std.collection.*
import stdx.serialization.serialization.*

/**
 * @brief 表示可供客户端申请的 API 作用域。
 */
public class ApiScope <: ResourceBase & IScope & Serializable<ApiScope> {
    /**
     * @brief 标识当前作用域是否必须被显式授予。
     */
    public var required = false

    /**
     * @brief 创建空的 API 作用域实例。
     */
    public init() {
    }

    /**
     * @brief 使用作用域名称创建 API 作用域。
     * @param name 作用域名称。
     */
    public init(name: String) {
        this.name = name
    }

    /**
     * @brief 使用名称和描述创建 API 作用域。
     * @param name 作用域名称。
     * @param description 作用域描述。
     */
    public init(name: String, description: ?String) {
        this.name = name
        this.description = description
    }

    /**
     * @brief 将当前 API 作用域序列化为数据模型。
     * @return 返回 API 作用域对应的数据模型结构。
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
     * @brief 从数据模型反序列化 API 作用域。
     * @param dm API 作用域对应的数据模型。
     * @return 返回反序列化后的 API 作用域。
     * @throws DataModelException 当数据模型不是结构类型时抛出。
     */
    public static func deserialize(dm: DataModel): ApiScope {
        let dms = match (dm) {
            case dms: DataModelStruct => dms
            case _ => throw DataModelException("This data is not DataModelStruct.")
        }
        let result = ApiScope()
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

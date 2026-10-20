/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.models

import std.time.*
import stdx.serialization.serialization.*

/**
 * @brief 表示客户端或资源使用的密钥信息。
 */
public class Secret <: Serializable<Secret> {
    /**
     * @brief 保存密钥值。
     */
    public var value: String = String.empty
    /**
     * @brief 标识密钥是否启用。
     */
    public var enabled: Bool = true
    /**
     * @brief 保存密钥过期时间。
     */
    public var expiration: ?DateTime = None
    /**
     * @brief 保存密钥描述信息。
     */
    public var description: ?String = None

    /**
     * @brief 创建空的密钥实例。
     */
    public init() {
    }

    /**
     * @brief 使用值和可选元数据创建密钥。
     * @param value 密钥值。
     * @param expiration 密钥过期时间。
     * @param description 密钥描述信息。
     */
    public init(value: String, expiration!: ?DateTime = None, description!: ?String = None) {
        this.value = value
        this.expiration = expiration
        this.description = description
    }

    /**
     * @brief 将当前密钥序列化为数据模型。
     * @return 返回密钥对应的数据模型结构。
     */
    public func serialize(): DataModelStruct {
        let dms = DataModelStruct()
        dms.add(field("value", value))
        dms.add(field("enabled", enabled))
        dms.add(field("expiration", expiration?.toString()))
        dms.add(field("description", description))
        return dms
    }

    /**
     * @brief 从数据模型反序列化密钥。
     * @param dm 密钥对应的数据模型。
     * @return 返回反序列化后的密钥。
     * @throws DataModelException 当数据模型不是结构类型时抛出。
     */
    public static func deserialize(dm: DataModel): Secret {
        let dms = match (dm) {
            case dms: DataModelStruct => dms
            case _ => throw DataModelException("This data is not DataModelStruct.")
        }
        let result = Secret()
        result.value = String.deserialize(dms.get("value"))
        result.enabled = Bool.deserialize(dms.get("enabled"))
        result.expiration = Option<String>.deserialize(dms.get("expiration")).flatMap {f => DateTime.parse(f)}
        result.description = Option<String>.deserialize(dms.get("description"))
        return result
    }
}

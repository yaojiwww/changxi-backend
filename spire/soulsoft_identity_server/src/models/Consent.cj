/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.models

import std.time.*
import stdx.serialization.serialization.*

/**
 * @brief 表示用户对客户端的授权同意记录。
 */
public class Consent <: Serializable<Consent>{
    /**
     * @brief 保存授权用户的主体标识。
     */
    public var sub = String.empty
    /**
     * @brief 保存客户端标识。
     */
    public var clientId = String.empty
    /**
     * @brief 保存同意记录的有效时长。
     */
    public var lifetime:?Int64 = None
    /**
     * @brief 保存用户已同意的作用域列表。
     */
    public var scopes = Array<String>()
    /**
     * @brief 保存同意记录的创建时间。
     */
    public var creationTime: DateTime = DateTime.now().inUTC()

    /**
     * @brief 将当前同意记录序列化为数据模型。
     * @return 返回同意记录对应的数据模型结构。
     */
    public func serialize(): DataModelStruct {
        let dms = DataModelStruct()
        dms.add(field("sub", sub))
        dms.add(field("clientId", clientId))
        dms.add(field("lifetime", lifetime))
        dms.add(field("scopes", scopes))
        dms.add(field("creationTime", creationTime.toString()))
        return dms
    }

    /**
     * @brief 从数据模型反序列化同意记录。
     * @param dm 同意记录对应的数据模型。
     * @return 返回反序列化后的同意记录。
     * @throws DataModelException 当数据模型不是结构类型时抛出。
     */
    public static func deserialize(dm: DataModel): Consent {
        let dms = match (dm) {
            case dms: DataModelStruct => dms
            case _ => throw DataModelException("This data is not DataModelInt.")
        }
        let result = Consent()
        result.sub = String.deserialize(dms.get("sub"))
        result.clientId = String.deserialize(dms.get("clientId"))
        result.lifetime = Option<Int64>.deserialize(dms.get("lifetime"))
        result.scopes = Array<String>.deserialize(dms.get("scopes"))
        result.creationTime = DateTime.parse(String.deserialize(dms.get("creationTime")))
        return result
    }
}

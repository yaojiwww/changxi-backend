/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.models

import std.time.*
import soulsoft_identity_claims.*
import stdx.serialization.serialization.*

/**
 * @brief 表示刷新令牌持久化数据。
 */
public class RefreshToken <: Serializable<RefreshToken> {
    /**
     * @brief 保存刷新令牌所属的客户端标识。
     */
    public var clientId = String.empty
    /**
     * @brief 保存刷新令牌的有效时长。
     */
    public var lifetime: Int64 = 0
    /**
     * @brief 保存刷新令牌描述信息。
     */
    public var description: ?String = None
    /**
     * @brief 保存刷新令牌授权的作用域列表。
     */
    public var scopes: Array<String> = []
    /**
     * @brief 保存刷新令牌关联的用户主体。
     */
    public var subject = ClaimsPrincipal()
    /**
     * @brief 保存刷新令牌被消费的时间。
     */
    public var consumedTime: ?DateTime = None
    /**
     * @brief 保存刷新令牌的创建时间。
     */
    public var creationTime: DateTime = DateTime.now().inUTC()

    /**
     * @brief 将当前刷新令牌序列化为数据模型。
     * @return 返回刷新令牌对应的数据模型结构。
     */
    public func serialize(): DataModelStruct {
        let dms = DataModelStruct()
        dms.add(field("clientId", clientId))
        dms.add(field("lifetime", lifetime))
        dms.add(field("description", description))
        dms.add(field("scopes", scopes))
        dms.add(field("subject", subject))
        dms.add(field("consumedTime", consumedTime?.toString()))
        dms.add(field("creationTime", creationTime.toString()))
        return dms
    }

    /**
     * @brief 从数据模型反序列化刷新令牌。
     * @param dm 刷新令牌对应的数据模型。
     * @return 返回反序列化后的刷新令牌。
     * @throws DataModelException 当数据模型不是结构类型时抛出。
     */
    public static func deserialize(dm: DataModel): RefreshToken {
        let dms = match (dm) {
            case dms: DataModelStruct => dms
            case _ => throw DataModelException("This data is not DataModelInt.")
        }
        let result = RefreshToken()
        result.clientId = String.deserialize(dms.get("clientId"))
        result.lifetime = Int64.deserialize(dms.get("lifetime"))
        result.description = Option<String>.deserialize(dms.get("description"))
        result.scopes = Array<String>.deserialize(dms.get("scopes"))
        result.subject = ClaimsPrincipal.deserialize(dms.get("subject"))
        result.consumedTime = Option<String>.deserialize(dms.get("consumedTime")).flatMap {f => DateTime.parse(f)}
        result.creationTime = DateTime.parse(String.deserialize(dms.get("creationTime")))
        return result
    }
}

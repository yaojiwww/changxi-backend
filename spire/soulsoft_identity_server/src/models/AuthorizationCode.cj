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
 * @brief 表示授权码授权流程中的授权码数据。
 */
public class AuthorizationCode <: Serializable<AuthorizationCode> {
    /**
     * @brief 保存授权码所属的客户端标识。
     */
    public var clientId = String.empty
    /**
     * @brief 保存授权码的有效时长。
     */
    public var lifetime = 0
    /**
     * @brief 保存授权码关联的请求作用域列表。
     */
    public var requestedScopes: Array<String> = []
    /**
     * @brief 保存授权码关联的用户主体。
     */
    public var subject: ClaimsPrincipal = ClaimsPrincipal()
    /**
     * @brief 保存授权码的创建时间。
     */
    public var creationTime = DateTime.now().inUTC()
    /**
     * @brief 保存授权请求使用的重定向地址。
     */
    public var redirectUri = String.empty
    /**
     * @brief 保存 PKCE 代码挑战值。
     */
    public var codeChallenge: ?String = None
    /**
     * @brief 保存 PKCE 代码挑战方法。
     */
    public var codeChallengeMethod: ?String = None
    /**
     * @brief 保存授权请求关联的 nonce 值。
     */
    public var nonce: ?String = None
    /**
     * @brief 保存授权码关联的会话标识。
     */
    public var sessionId: ?String = None

    /**
     * @brief 将当前授权码序列化为数据模型。
     * @return 返回授权码对应的数据模型结构。
     */
    public func serialize(): DataModelStruct {
        let dms = DataModelStruct()
        dms.add(field("clientId", clientId))
        dms.add(field("lifetime", lifetime))
        dms.add(field("requestedScopes", requestedScopes))
        dms.add(field("subject", subject))
        dms.add(field("creationTime", creationTime.toString()))
        dms.add(field("redirectUri", redirectUri))
        dms.add(field("codeChallenge", codeChallenge))
        dms.add(field("codeChallengeMethod", codeChallengeMethod))
        dms.add(field("nonce", nonce))
        dms.add(field("sessionId", sessionId))
        return dms
    }

    /**
     * @brief 从数据模型反序列化授权码。
     * @param dm 授权码对应的数据模型。
     * @return 返回反序列化后的授权码。
     * @throws InvalidDataException 当数据模型不是结构类型时抛出。
     */
    public static func deserialize(dm: DataModel): AuthorizationCode {
        let dms = match (dm) {
            case dms: DataModelStruct => dms
            case _ => throw InvalidDataException("The data is not DataModelStruct.")
        }
        let result = AuthorizationCode()
        result.clientId = String.deserialize(dms.get("clientId"))
        result.lifetime = Int64.deserialize(dms.get("lifetime"))
        result.requestedScopes = Array<String>.deserialize(dms.get("requestedScopes"))
        result.subject = ClaimsPrincipal.deserialize(dms.get("subject"))
        result.creationTime = DateTime.parse(String.deserialize(dms.get("creationTime")))
        result.redirectUri = String.deserialize(dms.get("redirectUri"))
        result.codeChallenge = Option<String>.deserialize(dms.get("codeChallenge"))
        result.codeChallengeMethod = Option<String>.deserialize(dms.get("codeChallengeMethod"))
        result.nonce = Option<String>.deserialize(dms.get("nonce"))
        result.sessionId = Option<String>.deserialize(dms.get("sessionId"))
        return result
    }
}

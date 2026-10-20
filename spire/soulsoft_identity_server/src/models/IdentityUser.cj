/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.models

import std.time.*
import std.collection.*
import soulsoft_identity_claims.*

/**
 * @brief 表示身份服务中的用户上下文信息。
 */
public class IdentityUser {
    /**
     * @brief 保存用户主体标识。
     */
    public let sub: String
    /**
     * @brief 保存认证方法引用值。
     */
    public var amr: String = "pwd"
    /**
     * @brief 保存身份提供方标识。
     */
    public var idp: String = "local"
    /**
     * @brief 保存会话标识。
     */
    public var sid: ?String = None
    /**
     * @brief 保存用户认证时间。
     */
    public var authTime: DateTime = DateTime.now().inUTC()
    private let _claims = ArrayList<Claim>()

    private static let _protocolClaimTypes = [
        ClaimTypes.Aud,
        ClaimTypes.Jti,
        ClaimTypes.Azp,
        ClaimTypes.Exp,
        ClaimTypes.Iat,
        ClaimTypes.Iss,
        ClaimTypes.Nbf,
        ClaimTypes.Sid,
        ClaimTypes.Cnf,
        ClaimTypes.Sub,
        ClaimTypes.Amr,
        ClaimTypes.Idp,
        ClaimTypes.CHash,
        ClaimTypes.Scope,
        ClaimTypes.Nonce,
        ClaimTypes.ClientId,
        ClaimTypes.AuthTime,
        ClaimTypes.AccessTokenHash
    ]

    /**
     * @brief 使用主体标识创建用户上下文。
     * @param sub 用户主体标识。
     */
    public init(sub: String) {
        this.sub = sub
    }

    /**
     * @brief 返回当前用户的自定义声明列表。
     * @return 返回当前用户的自定义声明列表。
     */
    public prop claims: ReadOnlyList<Claim> {
        get() {
            _claims
        }
    }

    /**
     * @brief 添加一条自定义声明。
     * @param type 声明类型。
     * @param value 声明值。
     * @throws UnsupportedException 当声明类型属于协议保留声明时抛出。
     */
    public func addClaim(`type`: String, value: String): Unit {
        if (_protocolClaimTypes.contains(`type`)) {
            throw UnsupportedException("Cannot add protocol reserved claim: ${`type`}")
        }
        _claims.add(Claim(`type`, value))
    }

    /**
     * @brief 将当前用户上下文转换为声明主体。
     * @return 返回包含协议声明和自定义声明的主体对象。
     */
    public func toPrincipal(): ClaimsPrincipal {
        let identity = ClaimsIdentity(this.amr)
        identity.addClaims(this._claims)
        identity.addClaim(ClaimTypes.Sub, this.sub)
        identity.addClaim(ClaimTypes.Amr, this.amr)
        identity.addClaim(ClaimTypes.Idp, this.idp)
        if (let Some(sid) <- this.sid) {
            identity.addClaim(ClaimTypes.Sid, sid)
        }
        identity.addClaim(ClaimTypes.AuthTime, this.authTime.toUnixTimeStamp().toSeconds().toString())
        return ClaimsPrincipal(identity)
    }
}

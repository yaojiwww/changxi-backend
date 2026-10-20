// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_tokens_jwt

import std.convert.*
import std.collection.*
import soulsoft_identity_claims.*

/**
 * @brief 表示 JWT 载荷内容。
 */
public class JwtPayload <: JwtContent {
    /**
     * @brief 创建空的 JWT 载荷。
     */
    public init() {
    }

    /**
     * @brief 使用键值集合创建 JWT 载荷。
     * @param all 要写入载荷的键值集合。
     */
    public init(all: Collection<(String, Any)>) {
        add(all: all)
    }

    /**
     * @brief 使用声明集合创建 JWT 载荷。
     * @param claims 要写入载荷的声明集合。
     */
    public init(claims: Collection<Claim>) {
        addClaims(claims)
    }

    /**
     * @brief 添加单个声明到载荷。
     * @param claim 要添加的声明。
     * @return 无返回值。
     */
    public func addClaim(claim: Claim): Unit {
        if (claim.valueType == ClaimValueTypes.Integer) {
            add(claim.`type`, Int64.parse(claim.value))
        } else if (claim.valueType == ClaimValueTypes.Boolean) {
            add(claim.`type`, Bool.parse(claim.value))
        } else if (claim.valueType == ClaimValueTypes.Double) {
            add(claim.`type`, Float64.parse(claim.value))
        } else {
            add(claim.`type`, claim.value)
        }
    }

    /**
     * @brief 批量添加声明到载荷。
     * @param claims 要添加的声明集合。
     * @return 无返回值。
     */
    public func addClaims(claims: Collection<Claim>): Unit {
        for (pattern in claims) {
            addClaim(pattern)
        }
    }

    /**
     * @brief 获取 JWT ID。
     * @return 载荷中的 `jti` 值；不存在时返回 `None`。
     */
    public prop jti: ?String {
        get() {
            if (let Some(value) <- get(ClaimTypes.Jti).flatMap {f => f as String}) {
                return value
            }
            return None
        }
    }

    /**
     * @brief 获取主题标识。
     * @return 载荷中的 `sub` 值；不存在时返回 `None`。
     */
    public prop sub: ?String {
        get() {
            if (let Some(value) <- get(ClaimTypes.Sub).flatMap {f => f as String}) {
                return value
            }
            return None
        }
    }

    /**
     * @brief 获取受众集合。
     * @return 载荷中的全部 `aud` 值。
     */
    public prop aud: Collection<String> {
        get() {
            if (let Some(value) <- get(ClaimTypes.Aud)) {
                return match (value) {
                    case value: String => [value]
                    case values: ArrayList<Any> => values |> filterMap {f => f as String} |> collectArray
                    case _ => []
                }
            }
            return []
        }
    }

    /**
     * @brief 获取颁发者标识。
     * @return 载荷中的 `iss` 值；不存在时返回 `None`。
     */
    public prop iss: ?String {
        get() {
            if (let Some(value) <- get(ClaimTypes.Iss).flatMap {f => f as String}) {
                return value
            }
            return None
        }
    }

    /**
     * @brief 获取认证时间戳。
     * @return 载荷中的 `auth_time` 值；不存在时返回 `None`。
     */
    public prop authTime: ?Int64 {
        get() {
            if (let Some(value) <- get(ClaimTypes.AuthTime).flatMap {f => f as Int64}) {
                return value
            }
            return None
        }
    }

    /**
     * @brief 获取生效时间戳。
     * @return 载荷中的 `nbf` 值；不存在时返回 `None`。
     */
    public prop nbf: ?Int64 {
        get() {
            if (let Some(value) <- get(ClaimTypes.Nbf).flatMap {f => f as Int64}) {
                return value
            }
            return None
        }
    }

    /**
     * @brief 获取认证上下文类引用。
     * @return 载荷中的 `acr` 值；不存在时返回 `None`。
     */
    public prop acr: ?String {
        get() {
            if (let Some(value) <- get(ClaimTypes.Acr).flatMap {f => f as String}) {
                return value
            }
            return None
        }
    }

    /**
     * @brief 获取过期时间戳。
     * @return 载荷中的 `exp` 值；不存在时返回 `None`。
     */
    public prop exp: ?Int64 {
        get() {
            if (let Some(value) <- get(ClaimTypes.Exp).flatMap {f => f as Int64}) {
                return value
            }
            return None
        }
    }

    /**
     * @brief 获取签发时间戳。
     * @return 载荷中的 `iat` 值；不存在时返回 `None`。
     */
    public prop iat: ?Int64 {
        get() {
            if (let Some(value) <- get(ClaimTypes.Iat).flatMap {f => f as Int64}) {
                return value
            }
            return None
        }
    }

    /**
     * @brief 获取随机数声明。
     * @return 载荷中的 `nonce` 值；不存在时返回 `None`。
     */
    public prop nonce: ?String {
        get() {
            if (let Some(value) <- get(ClaimTypes.Nonce).flatMap {f => f as String}) {
                return value
            }
            return None
        }
    }
}

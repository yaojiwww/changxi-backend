// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_tokens_jwt

import std.collection.*
import soulsoft_identity_claims.*
import soulsoft_identity_tokens.*

private const DefaultTyp = "JWT"

/**
 * @brief 表示 JWT 头部内容。
 */
public class JwtHeader <: JwtContent {
    private let _typ: String
    private let _signingCredentials: ?SigningCredentials

    /**
     * @brief 创建默认的 JWT 头部。
     */
    public init() {
        _typ = DefaultTyp
        _signingCredentials = None
    }

    init(outboundAlgorithmMap: Map<String, Any>) {
        _typ = DefaultTyp
        _signingCredentials = None
        add(all: outboundAlgorithmMap)
    }

    /**
     * @brief 使用签名凭据创建 JWT 头部。
     * @param signingCredentials 用于生成头部算法信息的签名凭据。
     */
    public init(signingCredentials: SigningCredentials) {
        this(signingCredentials, None, None)
    }

    /**
     * @brief 使用签名凭据和附加头部声明创建 JWT 头部。
     * @param signingCredentials 用于生成头部算法信息的签名凭据。
     * @param outboundAlgorithmMap 要附加到头部的键值映射。
     */
    public init(signingCredentials: SigningCredentials, outboundAlgorithmMap: ?Map<String, Any>) {
        this(signingCredentials, outboundAlgorithmMap, None)
    }

    /**
     * @brief 使用签名凭据、附加头部声明和令牌类型创建 JWT 头部。
     * @param signingCredentials 用于生成头部算法信息的签名凭据。
     * @param outboundAlgorithmMap 要附加到头部的键值映射。
     * @param tokenType 要写入 `typ` 的令牌类型。
     */
    public init(signingCredentials: SigningCredentials, outboundAlgorithmMap: ?Map<String, Any>, tokenType: ?String) {
        _typ = tokenType ?? DefaultTyp
        _signingCredentials = signingCredentials
        if (let Some(outboundAlgorithmMap) <- outboundAlgorithmMap) {
           add(all: outboundAlgorithmMap)
        }
        addFirstPriorityClaims(signingCredentials)
    }

    /**
     * @brief 获取令牌类型。
     * @return 头部中的 `typ` 值。
     */
    public prop typ: String {
        get() {
            _typ
        }
    }

    /**
     * @brief 获取签名算法标识。
     * @return 头部中的 `alg` 值；不存在时返回 `None`。
     */
    public prop alg: ?String {
        get() {
            if (let Some(alg) <- get(ClaimTypes.Alg).flatMap {f => f as String}) {
                return alg
            }
            return None
        }
    }

    /**
     * @brief 获取密钥标识。
     * @return 头部中的 `kid` 值；不存在时返回 `None`。
     */
    public prop kid: ?String {
        get() {
            if (let Some(alg) <- get(ClaimTypes.Kid).flatMap {f => f as String}) {
                return alg
            }
            return None
        }
    }

    private func addFirstPriorityClaims(signingCredentials: SigningCredentials) {
        this["typ"] = _typ
        this["alg"] = signingCredentials.algorithm
        if (let Some(kid) <- signingCredentials.key.keyId) {
            this["kid"] = kid
        }
    }

    /**
     * @brief 获取关联的签名凭据。
     * @return 用于生成当前头部的签名凭据；不存在时返回 `None`。
     */
    public prop signingCredentials: ?SigningCredentials {
        get() {
            _signingCredentials
        }
    }
}

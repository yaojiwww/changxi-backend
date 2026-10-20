// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_tokens_jwt

import soulsoft_identity_tokens.*

/**
 * @brief 表示 JWT 安全令牌。
 */
public class JwtSecurityToken <: SecurityToken {
    private let _header: JwtHeader
    private let _payload: JwtPayload
    private let _segments: ?JwtSegments

    /**
     * @brief 使用头部和载荷创建 JWT 安全令牌。
     * @param header JWT 头部。
     * @param payload JWT 载荷。
     */
    public init(header: JwtHeader, payload: JwtPayload) {
        this(header, payload, None)
    }

    init(header: JwtHeader, payload: JwtPayload, segments: ?JwtSegments) {
        _header = header
        _payload = payload
        _segments = segments
    }

    /**
     * @brief 获取令牌标识。
     * @return 载荷中的 `jti` 值；不存在时返回 `None`。
     */
    public prop id: ?String {
        get() {
            _payload.jti
        }
    }

    /**
     * @brief 获取颁发者标识。
     * @return 载荷中的 `iss` 值；不存在时返回 `None`。
     */
    public prop issuer: ?String {
        get() {
            _payload.iss
        }
    }

    /**
     * @brief 获取签名密钥。
     * @return 头部签名凭据中的密钥；不存在时返回 `None`。
     */
    public prop signingKey: ?SecurityKey {
        get() {
            _header.signingCredentials?.key
        }
    }

    /**
     * @brief 获取 JWT 头部。
     * @return 当前令牌的头部对象。
     */
    public prop header: JwtHeader {
        get() {
            _header
        }
    }

    /**
     * @brief 获取 JWT 载荷。
     * @return 当前令牌的载荷对象。
     */
    public prop payload: JwtPayload {
        get() {
            _payload
        }
    }

    /**
     * @brief 获取原始分段信息。
     * @return 当前令牌的三段编码内容；不存在时返回 `None`。
     */
    public prop segments: ?JwtSegments {
        get() {
            _segments
        }
    }

    /**
     * @brief 获取签名凭据。
     * @return 当前头部关联的签名凭据；不存在时返回 `None`。
     */
    public prop signingCredentials: ?SigningCredentials {
        get() {
            _header.signingCredentials
        }
    }

    /**
     * @brief 获取签名算法标识。
     * @return 头部中的 `alg` 值；不存在时返回 `None`。
     */
    public prop signatureAlgorithm: ?String {
        get() {
            _header.alg
        }
    }
}

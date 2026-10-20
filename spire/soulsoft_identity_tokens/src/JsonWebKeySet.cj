// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_tokens

import std.collection.*

/**
 * @brief 表示 JSON Web Key 集合。
 */
public class JsonWebKeySet {
    private let _keys: ArrayList<JsonWebKey>

    /**
     * @brief 创建空的 JWK 集合。
     */
    public init() {
        this(ArrayList<JsonWebKey>())
    }

    /**
     * @brief 使用给定密钥集合创建 JWK 集合。
     * @param keys 初始 JWK 集合。
     */
    public init(keys: Collection<JsonWebKey>) {
        _keys = ArrayList<JsonWebKey>(keys)
    }

    /**
     * @brief 获取集合中的所有 JWK。
     * @return 当前 JWK 列表。
     */
    public prop keys: List<JsonWebKey> {
        get() {
            _keys
        }
    }

    /**
     * @brief 从 JSON 字符串创建 JWK 集合。
     * @param json JWKS 的 JSON 表示。
     * @return 解析后的 `JsonWebKeySet` 实例。
     */
    public static func create(json: String): JsonWebKeySet {
        let set = JsonWebKeySet()
        JsonWebKeySetSerializer.read(json, set)
        return set
    }

    /**
     * @brief 获取集合中可用于签名验证的安全密钥列表。
     * @return 可转换并支持签名用途的安全密钥列表。
     * @throws UnsupportedException 当集合中存在不受支持的密钥类型时抛出。
     */
    public func getSigningKeys(): ReadOnlyList<SecurityKey> {
        let securityKeys = ArrayList<SecurityKey>()

        for (key in _keys) {
            if (key.kty == JsonWebAlgorithmsKeyTypes.RSA ||
                key.kty == JsonWebAlgorithmsKeyTypes.EllipticCurve ||
                key.kty == JsonWebAlgorithmsKeyTypes.Octet) {
                securityKeys.add(JsonWebKeyConverter.convertToSecurityKey(key))
            }
        }

        return securityKeys
    }
}

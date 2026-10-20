// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_tokens

/**
 * @brief 表示基于字节序列的对称安全密钥。
 */
public class SymmetricSecurityKey <: SecurityKey {
    private let _key: Array<Byte>

    /**
     * @brief 使用字节数组创建对称密钥。
     * @param key 原始密钥字节。
     * @throws IllegalArgumentException 当密钥长度为零时抛出。
     */
    public init(key: Array<Byte>) {
        if (key.isEmpty()) {
            throw IllegalArgumentException("IDX10703: The SymmetricKey cannot have zero length.")
        }
        _key = key.clone()
    }

    /**
     * @brief 使用字符串内容创建对称密钥。
     * @param text 作为 UTF-8 原始字节使用的密钥字符串。
     * @throws IllegalArgumentException 当字符串为空时抛出。
     */
    public init(text: String) {
        if (text.isEmpty()) {
            throw IllegalArgumentException("IDX10703: The SymmetricKey cannot have zero length.")
        }
        _key = text.toArray()
    }

    /**
     * @brief 从对称 JWK 创建对称密钥。
     * @param jsonWebKey 包含对称密钥材料的 JWK。
     * @throws IllegalArgumentException 当 `k` 字段缺失或不是有效 Base64Url 时抛出。
     */
    public init(jsonWebKey: JsonWebKey) {
        this(SymmetricSecurityKey.decodeKeyFromJwk(jsonWebKey))
    }

    private static func decodeKeyFromJwk(jsonWebKey: JsonWebKey): Array<Byte> {
        return Base64UrlEncoder
            .decodeBytes(jsonWebKey.k.getOrThrow {IllegalArgumentException("Symmetric JWK missing required field 'k'")})
            .getOrThrow {IllegalArgumentException("Symmetric JWK field 'k' is not valid Base64Url")}
    }

    /**
     * @brief 获取对称密钥字节副本。
     * @return 当前密钥字节数组的副本。
     */
    public prop key: Array<Byte> {
        get() {
            _key.clone()
        }
    }

    /**
     * @brief 获取对称密钥标识。
     * @return 当前实现始终返回 `None`。
     */
    public prop keyId: ?String {
        get() {
            None
        }
    }

    /**
     * @brief 获取对称密钥位长度。
     * @return 当前密钥的位长度。
     */
    public prop keySize: Int64 {
        get() {
            _key.size * 8
        }
    }
}

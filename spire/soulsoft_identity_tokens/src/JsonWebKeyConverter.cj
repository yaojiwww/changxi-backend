// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_tokens

import std.reflect.*

/**
 * @brief 提供 `SecurityKey` 与 `JsonWebKey` 的双向转换能力。
 */
public class JsonWebKeyConverter {
    /**
     * @brief 将安全密钥转换为 JWK。
     * @param key 要转换的安全密钥。
     * @return 转换后的 JWK。
     * @throws UnsupportedException 当密钥类型不受支持时抛出。
     */
    public static func convertFromSecurityKey(key: SecurityKey): JsonWebKey {
        if (let Some(k) <- (key as RsaSecurityKey)) {
            return convertFromRsaSecurityKey(k)
        }
        if (let Some(k) <- (key as SymmetricSecurityKey)) {
            return convertFromSymmetricSecurityKey(k)
        }
        if (let Some(k) <- (key as ECDsaSecurityKey)) {
            return convertFromECDsaSecurityKey(k)
        }
        throw UnsupportedException("Unsupported SecurityKey type: ${ClassTypeInfo.of(key)}")
    }

    /**
     * @brief 将对称密钥转换为 JWK。
     * @param key 要转换的对称密钥。
     * @param algorithm 可选的算法标识。
     * @return 转换后的对称 JWK。
     */
    public static func convertFromSymmetricSecurityKey(key: SymmetricSecurityKey, algorithm!: ?String = None): JsonWebKey {
        let k = Base64UrlEncoder.encode(key.key)
        let jsonWebKey = JsonWebKey(k: k, kty: JsonWebAlgorithmsKeyTypes.Octet, use: "sig", alg: algorithm)
        jsonWebKey.convertedSecurityKey = key
        return jsonWebKey
    }

    /**
     * @brief 将 ECDSA 密钥转换为 JWK。
     * @param key 要转换的 ECDSA 密钥。
     * @param algorithm 可选的算法标识。
     * @return 转换后的 ECDSA JWK。
     */
    public static func convertFromECDsaSecurityKey(key: ECDsaSecurityKey, algorithm!: ?String = None): JsonWebKey {
        let jsonWebKey = JsonWebKey()
        jsonWebKey.kty = JsonWebAlgorithmsKeyTypes.EllipticCurve
        jsonWebKey.use = "sig"
        jsonWebKey.alg = algorithm
        let parameters = key.exportParameters(true)
        jsonWebKey.crv = ECDsaAdapter.getCrvParameterValue(parameters.curve)
        jsonWebKey.x = Base64UrlEncoder.encode(parameters.q.x)
        jsonWebKey.y = Base64UrlEncoder.encode(parameters.q.y)
        // 导出私钥参数（如果存在）
        if (let Some(d) <- parameters.d) {
            jsonWebKey.d = Base64UrlEncoder.encode(d)
        }
        jsonWebKey.convertedSecurityKey = key
        return jsonWebKey
    }

    /**
     * @brief 将 RSA 密钥转换为 JWK。
     * @param key 要转换的 RSA 密钥。
     * @param algorithm 可选的算法标识。
     * @return 转换后的 RSA JWK。
     */
    public static func convertFromRsaSecurityKey(key: RsaSecurityKey, algorithm!: ?String = None): JsonWebKey {
        let jsonWebKey = JsonWebKey()
        jsonWebKey.kty = JsonWebAlgorithmsKeyTypes.RSA
        jsonWebKey.use = "sig"
        jsonWebKey.alg = algorithm
        jsonWebKey.kid = key.keyId
        let parameters = key.exportParameters(true)
        jsonWebKey.e = Base64UrlEncoder.encode(parameters.exponent)
        jsonWebKey.n = Base64UrlEncoder.encode(parameters.modulus)
        // 导出私钥参数（如果存在）
        if (let Some(d) <- parameters.d) {
            jsonWebKey.d = Base64UrlEncoder.encode(d)
        }
        if (let Some(p) <- parameters.p) {
            jsonWebKey.p = Base64UrlEncoder.encode(p)
        }
        if (let Some(q) <- parameters.q) {
            jsonWebKey.q = Base64UrlEncoder.encode(q)
        }
        if (let Some(dp) <- parameters.dp) {
            jsonWebKey.dp = Base64UrlEncoder.encode(dp)
        }
        if (let Some(dq) <- parameters.dq) {
            jsonWebKey.dq = Base64UrlEncoder.encode(dq)
        }
        if (let Some(inverseQ) <- parameters.inverseQ) {
            jsonWebKey.qi = Base64UrlEncoder.encode(inverseQ)
        }
        jsonWebKey.convertedSecurityKey = key
        return jsonWebKey
    }

    /**
     * @brief 将签名凭据转换为 JWK。
     * @param signingCredentials 要转换的签名凭据。
     * @return 从签名凭据派生的 JWK。
     * @throws UnsupportedException 当密钥类型不受支持时抛出。
     */
    public static func convertFromSigningCredentials(signingCredentials: SigningCredentials): JsonWebKey {
        if (let Some(key) <- (signingCredentials.key as SymmetricSecurityKey)) {
            return convertFromSymmetricSecurityKey(key, algorithm: signingCredentials.algorithm)
        }
        if (let Some(key) <- (signingCredentials.key as ECDsaSecurityKey)) {
            return convertFromECDsaSecurityKey(key, algorithm: signingCredentials.algorithm)
        }
        if (let Some(key) <- (signingCredentials.key as RsaSecurityKey)) {
            return convertFromRsaSecurityKey(key, algorithm: signingCredentials.algorithm)
        }
        throw UnsupportedException("Unsupported SecurityKey type: ${ClassTypeInfo.of(signingCredentials.key)}")
    }

    /**
     * @brief 将 JWK 转换为具体安全密钥。
     * @param jsonWebKey 要转换的 JWK。
     * @return 转换后的安全密钥。
     * @throws UnsupportedException 当 `kty` 不受支持时抛出。
     */
    public static func convertToSecurityKey(jsonWebKey: JsonWebKey): SecurityKey {
        // 优先返回已缓存的转换结果，避免重复构建
        if (let Some(cachedKey) <- jsonWebKey.convertedSecurityKey) {
            return cachedKey
        }

        let key: SecurityKey
        if (jsonWebKey.kty.flatMap {f => f == JsonWebAlgorithmsKeyTypes.RSA} == true) {
            key = RsaSecurityKey(jsonWebKey)
        } else if (jsonWebKey.kty.flatMap {f => f == JsonWebAlgorithmsKeyTypes.EllipticCurve} == true) {
            key = ECDsaSecurityKey(jsonWebKey)
        } else if (let Some(symKey) <- convertToSymmetricSecurityKey(jsonWebKey)) {
            key = symKey
        } else {
            throw UnsupportedException("Unsupported kty: ${jsonWebKey.kty ?? "null"}")
        }

        jsonWebKey.convertedSecurityKey = key
        return key
    }

    private static func convertToSymmetricSecurityKey(jsonWebKey: JsonWebKey): ?SymmetricSecurityKey {
        if (jsonWebKey.kty.flatMap {f => f == JsonWebAlgorithmsKeyTypes.Octet} != true) {
            return None
        }
        if (jsonWebKey.k == None) {
            return None
        }
        return SymmetricSecurityKey(jsonWebKey)
    }
}

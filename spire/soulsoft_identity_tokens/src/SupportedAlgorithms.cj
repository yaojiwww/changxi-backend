// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_tokens

/**
 * @brief 提供算法与密钥类型兼容性判断工具。
 */
public class SupportedAlgorithms {

    /**
     * @brief 判断算法是否属于对称签名算法。
     * @param algorithm 要检查的算法标识。
     * @return 属于 HMAC 系列时返回 `true`。
     */
    public static func isSymmetricKeyAlgorithm(algorithm: String): Bool {
        algorithm == SecurityAlgorithms.HmacSha256 ||
        algorithm == SecurityAlgorithms.HmacSha384 ||
        algorithm == SecurityAlgorithms.HmacSha512
    }

    /**
     * @brief 判断算法是否属于非对称签名算法。
     * @param algorithm 要检查的算法标识。
     * @return 属于 RSA 或 ECDSA 系列时返回 `true`。
     */
    public static func isAsymmetricKeyAlgorithm(algorithm: String): Bool {
        algorithm == SecurityAlgorithms.RsaSha256    ||
        algorithm == SecurityAlgorithms.RsaSha384    ||
        algorithm == SecurityAlgorithms.RsaSha512    ||
        algorithm == SecurityAlgorithms.RsaSsaPssSha256 ||
        algorithm == SecurityAlgorithms.RsaSsaPssSha384 ||
        algorithm == SecurityAlgorithms.RsaSsaPssSha512 ||
        algorithm == SecurityAlgorithms.EcdsaSha256  ||
        algorithm == SecurityAlgorithms.EcdsaSha384  ||
        algorithm == SecurityAlgorithms.EcdsaSha512
    }

    /**
     * @brief 判断给定密钥与算法是否兼容。
     * @param algorithm 要检查的算法标识。
     * @param key 要检查的安全密钥。
     * @return 该密钥支持该算法时返回 `true`。
     */
    public static func isSupportedAlgorithm(algorithm: String, key: SecurityKey): Bool {
        // JsonWebKey：先尝试已转换的具体密钥，否则按 kty 路由
        if (let Some(jwk) <- (key as JsonWebKey)) {
            if (let Some(converted) <- jwk.convertedSecurityKey) {
                return isSupportedAlgorithm(algorithm, converted)
            }
            if (jwk.kty == JsonWebAlgorithmsKeyTypes.Octet) {
                return isSymmetricKeyAlgorithm(algorithm)
            }
            if (jwk.kty == JsonWebAlgorithmsKeyTypes.RSA ||
                jwk.kty == JsonWebAlgorithmsKeyTypes.EllipticCurve) {
                return isAsymmetricKeyAlgorithm(algorithm)
            }
            return false
        }

        if (key is SymmetricSecurityKey) {
            return isSymmetricKeyAlgorithm(algorithm)
        }
        if (key is AsymmetricSecurityKey) {
            return isAsymmetricKeyAlgorithm(algorithm)
        }
        return false
    }
}

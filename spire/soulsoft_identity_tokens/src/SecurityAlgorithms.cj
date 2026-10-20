// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_identity_tokens

/**
 * @brief 定义标准签名算法标识常量。
 */
public class SecurityAlgorithms {
    /**
     * @brief 表示 HMAC SHA-256 算法标识。
     */
    public static const HmacSha256 = "HS256"
    /**
     * @brief 表示 HMAC SHA-384 算法标识。
     */
    public static const HmacSha384 = "HS384"
    /**
     * @brief 表示 HMAC SHA-512 算法标识。
     */
    public static const HmacSha512 = "HS512"

    /**
     * @brief 表示 ECDSA SHA-256 算法标识。
     */
    public static const EcdsaSha256 = "ES256"
    /**
     * @brief 表示 ECDSA SHA-384 算法标识。
     */
    public static const EcdsaSha384 = "ES384"
    /**
     * @brief 表示 ECDSA SHA-512 算法标识。
     */
    public static const EcdsaSha512 = "ES512"

    /**
     * @brief 表示 RSA SHA-256 算法标识。
     */
    public static const RsaSha256 = "RS256"
    /**
     * @brief 表示 RSA SHA-384 算法标识。
     */
    public static const RsaSha384 = "RS384"
    /**
     * @brief 表示 RSA SHA-512 算法标识。
     */
    public static const RsaSha512 = "RS512"

    // RSA-PSS（RFC 7518 §3.5）— salt length 等于哈希长度
    /**
     * @brief 表示 RSA-PSS SHA-256 算法标识。
     */
    public static const RsaSsaPssSha256 = "PS256"
    /**
     * @brief 表示 RSA-PSS SHA-384 算法标识。
     */
    public static const RsaSsaPssSha384 = "PS384"
    /**
     * @brief 表示 RSA-PSS SHA-512 算法标识。
     */
    public static const RsaSsaPssSha512 = "PS512"
}

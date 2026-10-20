// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_tokens

/**
 * @brief 表示令牌签名所需的密钥与算法组合。
 */
public class SigningCredentials {
    private let _key: SecurityKey
    private let _algorithm: String

    /**
     * @brief 使用密钥和算法创建签名凭据。
     * @param key 用于签名的安全密钥。
     * @param algorithm 签名算法标识。
     */
    public init(key: SecurityKey, algorithm: String) {
        _key = key
        _algorithm = algorithm
    }

    /**
     * @brief 获取签名使用的安全密钥。
     * @return 关联的安全密钥。
     */
    public prop key: SecurityKey {
        get() {
            _key
        }
    }

    /**
     * @brief 获取签名算法标识。
     * @return 当前签名算法。
     */
    public prop algorithm: String {
        get() {
            _algorithm
        }
    }

    /**
     * @brief 创建签名用的签名提供者。
     * @description 提供者由关联密钥上的 `cryptoProviderFactory` 创建，用完后应交还给工厂。
     * @return 用于当前签名凭据的签名提供者。
     */
    public func createSignatureProvider(): SignatureProvider {
        _key.cryptoProviderFactory.createForSigning(_key, _algorithm)
    }
}

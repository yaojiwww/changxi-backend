// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_tokens

import stdx.crypto.digest.*

/**
 * @brief 提供基于对称密钥的签名与验签实现。
 */
public class SymmetricSignatureProvider <: SignatureProvider {

    /**
     * @brief 创建对称签名提供者。
     * @param key 用于签名或验签的安全密钥。
     * @param algorithm 签名算法标识。
     */
    public init(key: SecurityKey, algorithm: String) {
        this(key, algorithm, false)
    }

    /**
     * @brief 创建对称签名提供者并指定用途方向。
     * @param key 用于签名或验签的安全密钥。
     * @param algorithm 签名算法标识。
     * @param willCreateSignatures 是否用于签名方向。
     */
    public init(key: SecurityKey, algorithm: String, willCreateSignatures: Bool) {
        super(key, algorithm, willCreateSignatures: willCreateSignatures)
    }

    /**
     * @brief 使用当前对称密钥对输入数据进行签名。
     * @param input 要签名的字节数组。
     * @return 生成的签名字节序列。
     * @throws IllegalStateException 当提供者已关闭时抛出。
     * @throws UnsupportedException 当密钥类型或算法不受支持时抛出。
     */
    public func sign(input: Array<Byte>): Array<Byte> {
        if (isClosed()) {
            throw IllegalStateException("SignatureProvider has been closed")
        }
        let hmac = createHmacInstance()
        hmac.write(input)
        return hmac.finish()
    }

    /**
     * @brief 验证输入数据与签名是否匹配。
     * @param input 原始输入数据。
     * @param signature 待验证的签名字节序列。
     * @return 签名有效时返回 `true`。
     * @throws IllegalStateException 当提供者已关闭时抛出。
     * @throws UnsupportedException 当密钥类型或算法不受支持时抛出。
     */
    public func verify(input: Array<Byte>, signature: Array<Byte>): Bool {
        if (isClosed()) {
            throw IllegalStateException("SignatureProvider has been closed")
        }
        return HMAC.equal(sign(input), signature)
    }

    private func createHmacInstance() {
        if (let symmetricSecurityKey: SymmetricSecurityKey <- this.key) {
            if (algorithm == SecurityAlgorithms.HmacSha256) {
                return HMAC(symmetricSecurityKey.key, HashType.SHA256)
            }
            if (algorithm == SecurityAlgorithms.HmacSha384) {
                return HMAC(symmetricSecurityKey.key, HashType.SHA384)
            }
            if (algorithm == SecurityAlgorithms.HmacSha512) {
                return HMAC(symmetricSecurityKey.key, HashType.SHA512)
            }
            throw UnsupportedException("Unsupported HMAC algorithm: ${algorithm}")
        }
        throw UnsupportedException("Key must be SymmetricSecurityKey")
    }
}

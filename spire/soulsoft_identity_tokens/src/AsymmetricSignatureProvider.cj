// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_tokens

import stdx.crypto.keys.*
import std.crypto.digest.*
import stdx.crypto.digest.*

/**
 * @brief 提供基于非对称密钥的签名与验签实现。
 */
public class AsymmetricSignatureProvider <: SignatureProvider {
    
    /**
     * @brief 创建非对称签名提供者。
     * @param key 用于签名或验签的安全密钥。
     * @param algorithm 签名算法标识。
     */
    public init(key: SecurityKey, algorithm: String) {
        this(key, algorithm, false)
    }

    /**
     * @brief 创建非对称签名提供者并指定用途方向。
     * @param key 用于签名或验签的安全密钥。
     * @param algorithm 签名算法标识。
     * @param willCreateSignatures 是否用于签名方向。
     */
    public init(key: SecurityKey, algorithm: String, willCreateSignatures: Bool) {
        super(key, algorithm, willCreateSignatures: willCreateSignatures)
    }

    /**
     * @brief 使用当前非对称密钥对输入数据进行签名。
     * @param input 要签名的字节数组。
     * @return 生成的签名字节序列。
     * @throws IllegalStateException 当提供者已关闭时抛出。
     * @throws UnsupportedException 当算法不受支持时抛出。
     * @throws SecurityTokenValidationException 当密钥类型错误或缺少私钥时抛出。
     */
    public func sign(input: Array<Byte>): Array<Byte> {
        if (isClosed()) {
            throw IllegalStateException("SignatureProvider has been closed")
        }
        if (algorithm == SecurityAlgorithms.EcdsaSha256) {
            let privateKey = getECDsaPrivateKey()
            let sha = SHA256()
            return privateKey.sign(digest(sha, input))
        } else if (algorithm == SecurityAlgorithms.EcdsaSha384) {
            let privateKey = getECDsaPrivateKey()
            let sha = SHA384()
            return privateKey.sign(digest(sha, input))
        } else if (algorithm == SecurityAlgorithms.EcdsaSha512) {
            let privateKey = getECDsaPrivateKey()
            let sha = SHA512()
            return privateKey.sign(digest(sha, input))
        } else if (algorithm == SecurityAlgorithms.RsaSha256) {
            let privateKey = getRsaPrivateKey()
            let sha = SHA256()
            return privateKey.sign(sha, digest(sha, input), padType: PKCS1)
        } else if (algorithm == SecurityAlgorithms.RsaSha384) {
            let privateKey = getRsaPrivateKey()
            let sha = SHA384()
            return privateKey.sign(sha, digest(sha, input), padType: PKCS1)
        } else if (algorithm == SecurityAlgorithms.RsaSha512) {
            let privateKey = getRsaPrivateKey()
            let sha = SHA512()
            return privateKey.sign(sha, digest(sha, input), padType: PKCS1)
        } else if (algorithm == SecurityAlgorithms.RsaSsaPssSha256) {
            let privateKey = getRsaPrivateKey()
            let sha = SHA256()
            return privateKey.sign(sha, digest(sha, input), padType: PSS(PSSOption(32)))
        } else if (algorithm == SecurityAlgorithms.RsaSsaPssSha384) {
            let privateKey = getRsaPrivateKey()
            let sha = SHA384()
            return privateKey.sign(sha, digest(sha, input), padType: PSS(PSSOption(48)))
        } else if (algorithm == SecurityAlgorithms.RsaSsaPssSha512) {
            let privateKey = getRsaPrivateKey()
            let sha = SHA512()
            return privateKey.sign(sha, digest(sha, input), padType: PSS(PSSOption(64)))
        } else {
            throw UnsupportedException("Unsupported algorithm: ${algorithm}")
        }
    }

    /**
     * @brief 验证输入数据与签名是否匹配。
     * @param input 原始输入数据。
     * @param signature 待验证的签名字节序列。
     * @return 签名有效时返回 `true`。
     * @throws IllegalStateException 当提供者已关闭时抛出。
     * @throws UnsupportedException 当算法不受支持时抛出。
     * @throws SecurityTokenValidationException 当密钥类型错误或缺少公钥时抛出。
     */
    public func verify(input: Array<Byte>, signature: Array<Byte>): Bool {
        if (isClosed()) {
            throw IllegalStateException("SignatureProvider has been closed")
        }
        if (algorithm == SecurityAlgorithms.EcdsaSha256) {
            let publicKey = getECDsaPublicKey()
            let sha = SHA256()
            return publicKey.verify(digest(sha, input), signature)
        } else if (algorithm == SecurityAlgorithms.EcdsaSha384) {
            let publicKey = getECDsaPublicKey()
            let sha = SHA384()
            return publicKey.verify(digest(sha, input), signature)
        } else if (algorithm == SecurityAlgorithms.EcdsaSha512) {
            let publicKey = getECDsaPublicKey()
            let sha = SHA512()
            return publicKey.verify(digest(sha, input), signature)
        } else if (algorithm == SecurityAlgorithms.RsaSha256) {
            let publicKey = getRsaPublicKey()
            let sha = SHA256()
            return publicKey.verify(sha, digest(sha, input), signature, padType: PKCS1)
        } else if (algorithm == SecurityAlgorithms.RsaSha384) {
            let publicKey = getRsaPublicKey()
            let sha = SHA384()
            return publicKey.verify(sha, digest(sha, input), signature, padType: PKCS1)
        } else if (algorithm == SecurityAlgorithms.RsaSha512) {
            let publicKey = getRsaPublicKey()
            let sha = SHA512()
            return publicKey.verify(sha, digest(sha, input), signature, padType: PKCS1)
        } else if (algorithm == SecurityAlgorithms.RsaSsaPssSha256) {
            let publicKey = getRsaPublicKey()
            let sha = SHA256()
            return publicKey.verify(sha, digest(sha, input), signature, padType: PSS(PSSOption(32)))
        } else if (algorithm == SecurityAlgorithms.RsaSsaPssSha384) {
            let publicKey = getRsaPublicKey()
            let sha = SHA384()
            return publicKey.verify(sha, digest(sha, input), signature, padType: PSS(PSSOption(48)))
        } else if (algorithm == SecurityAlgorithms.RsaSsaPssSha512) {
            let publicKey = getRsaPublicKey()
            let sha = SHA512()
            return publicKey.verify(sha, digest(sha, input), signature, padType: PSS(PSSOption(64)))
        } else {
            throw UnsupportedException("Unsupported algorithm: ${algorithm}")
        }
    }

    private func getECDsaPrivateKey() {
        if (let securityKey: ECDsaSecurityKey <- key) {
            return securityKey.privateKey.getOrThrow{ SecurityTokenValidationException("ECDsa private key is null.") }
        }
        throw SecurityTokenValidationException("The key is not of type ECDsaSecurityKey.")
    }

    private func getECDsaPublicKey() {
        if (let securityKey: ECDsaSecurityKey <- key) {
            return securityKey.publicKey.getOrThrow{ SecurityTokenValidationException("ECDsa public key is null.") }
        }
        throw SecurityTokenValidationException("The key is not of type ECDsaSecurityKey.")
    }

    private func getRsaPrivateKey() {
        if (let securityKey: RsaSecurityKey <- key) {
            return securityKey.privateKey.getOrThrow{ SecurityTokenValidationException("RSA private key is null.") }
        }
        throw SecurityTokenValidationException("The key is not of type RsaSecurityKey.")
    }

    private func getRsaPublicKey() {
        if (let securityKey: RsaSecurityKey <- key) {
            return securityKey.publicKey.getOrThrow{ SecurityTokenValidationException("RSA public key is null.") }
        }
        throw SecurityTokenValidationException("The key is not of type RsaSecurityKey.")
    }
}

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_protection.default

import std.binary.*
import stdx.crypto.digest.*

private const KEY_MODIFIER_SIZE = 16

/**
 * @brief 提供认证加密器默认实现。
 */
public class AuthenticatedEncryptor <: IAuthenticatedEncryptor {
    private let _secret: ISecret
    private let _contextHeader: Array<Byte>
    private let _configuration: AuthenticatedEncryptorConfiguration

    /**
     * @brief 创建认证加密器实例。
     * @param secret 认证加密器使用的机密材料。
     * @param configuration 认证加密器算法配置。
     */
    public init(secret: ISecret, configuration: AuthenticatedEncryptorConfiguration) {
        _secret = secret
        _configuration = configuration
        _contextHeader = createContextHeader(configuration)
    }

    /**
     * @brief 解密并验证指定密文。
     * @param ciphertext 需要解密的密文字节数组。
     * @param additionalAuthenticatedData 参与认证的附加数据。
     * @return 返回解密后的明文字节数组。
     * @throws UnsupportedException 当密文格式非法或认证失败时抛出。
     */
    public func decrypt(ciphertext: Array<Byte>, additionalAuthenticatedData: Array<Byte>): Array<Byte> {
        // KeyModifier + IV + Ciphertext + HMAC
        let keyModifierSize = KEY_MODIFIER_SIZE
        let encryptionAlgorithmBlockSize = _configuration.encryptionAlgorithmBlockSize
        let validationAlgorithmDigestSize = _configuration.validationAlgorithmDigestSize
        if (ciphertext.size < keyModifierSize + encryptionAlgorithmBlockSize + validationAlgorithmDigestSize) {
            throw UnsupportedException("Invalid payload.")
        }
        let keyModifier = ciphertext.slice(0, KEY_MODIFIER_SIZE)
        let iv = ciphertext.slice(KEY_MODIFIER_SIZE, encryptionAlgorithmBlockSize)
        let encryptedDataWithHmac = ciphertext[KEY_MODIFIER_SIZE + encryptionAlgorithmBlockSize..]
        let encryptedData = encryptedDataWithHmac.slice(0, encryptedDataWithHmac.size - validationAlgorithmDigestSize)
        let hmac = encryptedDataWithHmac[encryptedData.size..]
        let (encryptionKey, validationKey) = deriveSubKeys(additionalAuthenticatedData, keyModifier)
        // encryptionKey / validationKey 是 tempKeys 的视图，用完后在 finally 中清零
        try {
            let hmacCalc = _configuration.digest(validationKey, iv.concat(encryptedData))
            // 使用固定时间比较，防止时序侧信道攻击（Timing Attack）
            if (!HMAC.equal(hmac, hmacCalc)) {
                throw UnsupportedException("Invalid payload.")
            }
            return _configuration.decrypt(encryptionKey, iv, encryptedData)
        } finally {
            // 两个视图合计覆盖 tempKeys 的全部字节，清零后底层内存完全归零
            CryptoUtil.zeroBytes(encryptionKey)
            CryptoUtil.zeroBytes(validationKey)
        }
    }

    /**
     * @brief 加密指定明文并附加认证信息。
     * @param plaintext 需要加密的明文字节数组。
     * @param additionalAuthenticatedData 参与认证的附加数据。
     * @return 返回加密后的密文字节数组。
     */
    public func encrypt(plaintext: Array<Byte>, additionalAuthenticatedData: Array<Byte>): Array<Byte> {
        // KeyModifier + IV + Ciphertext + HMAC
        let encryptionAlgorithmBlockSize = _configuration.encryptionAlgorithmBlockSize
        let keyModifier = SecureRandomUtil.generate(KEY_MODIFIER_SIZE)
        let iv = SecureRandomUtil.generate(encryptionAlgorithmBlockSize)
        let (encryptionKey, validationKey) = deriveSubKeys(additionalAuthenticatedData, keyModifier)
        // encryptionKey / validationKey 是 tempKeys 的视图，用完后在 finally 中清零
        try {
            let encryptedData = _configuration.encrypt(encryptionKey, iv, plaintext)
            let hmac = _configuration.digest(validationKey, iv.concat(encryptedData))
            // 预计算总长度，一次分配，避免链式 concat 产生 3 个中间临时数组
            let totalSize = KEY_MODIFIER_SIZE + encryptionAlgorithmBlockSize + encryptedData.size + hmac.size
            let result = Array<Byte>(totalSize, repeat: 0)
            var offset = 0
            keyModifier.copyTo(result[offset..])
            offset += KEY_MODIFIER_SIZE
            iv.copyTo(result[offset..])
            offset += encryptionAlgorithmBlockSize
            encryptedData.copyTo(result[offset..])
            offset += encryptedData.size
            hmac.copyTo(result[offset..])
            return result
        } finally {
            // 两个视图合计覆盖 tempKeys 的全部字节，清零后底层内存完全归零
            CryptoUtil.zeroBytes(encryptionKey)
            CryptoUtil.zeroBytes(validationKey)
        }
    }

    private func deriveSubKeys(additionalAuthenticatedData: Array<Byte>, keyModifier: Array<Byte>) {
        let km = _secret.bytes()
        let context = _contextHeader.concat(keyModifier)
        // km 和 context 是独立副本，KDF 执行完毕后立即清零
        try {
            let length = _configuration.encryptionAlgorithmKeySize + _configuration.validationAlgorithmKeySize
            let tempKeys = SP800_108_CTR_HMACSHA512Util.deriveKey(km, additionalAuthenticatedData, context, length)
            // slice 返回视图（共享 tempKeys 底层 rawptr）
            // 调用方在 try/finally 中清零 encryptionKey + validationKey 即可覆盖 tempKeys 全部字节
            let encryptionKey = tempKeys.slice(0, _configuration.encryptionAlgorithmKeySize)
            let validationKey = tempKeys[_configuration.encryptionAlgorithmKeySize..]
            return (encryptionKey, validationKey)
        } finally {
            CryptoUtil.zeroBytes(km)
            CryptoUtil.zeroBytes(context)
        }
    }

    private static func createContextHeader(configuration: AuthenticatedEncryptorConfiguration) {
        let totalLength = 1 + 1 + 4 + 4 + 4 + 4 + configuration.encryptionAlgorithmBlockSize + configuration
            .validationAlgorithmDigestSize
        let buffer = Array<Byte>(totalLength, repeat: 0)
        // 1. KDF 算法标识
        var offset = 0
        buffer[offset] = UInt8(0x00)
        offset += 1
        // 2. 加密模式
        buffer[offset] = UInt8(0x00)
        offset += 1
        // 3. 密钥长度 (Big-Endian)
        UInt32(configuration.encryptionAlgorithmKeySize).writeBigEndian(buffer[offset..])
        offset += 4
        // 4. 块大小 (Big-Endian)
        UInt32(configuration.encryptionAlgorithmBlockSize).writeBigEndian(buffer[offset..])
        offset += 4
        // 5. HMAC 密钥长度 (Big-Endian)
        UInt32(configuration.validationAlgorithmKeySize).writeBigEndian(buffer[offset..])
        offset += 4
        // 6. HMAC 摘要长度 (Big-Endian)
        UInt32(configuration.validationAlgorithmDigestSize).writeBigEndian(buffer[offset..])
        // 7. 算法特征：空字符串加密结果
        offset += 4
        let tempKeysLength = configuration.encryptionAlgorithmKeySize + configuration.validationAlgorithmKeySize
        let tempKeys = SP800_108_CTR_HMACSHA512Util.deriveEmptyKey(tempKeysLength)
        let encryptionKey = tempKeys.slice(0, configuration.encryptionAlgorithmKeySize)
        let encryptionIv = Array<Byte>(configuration.encryptionAlgorithmBlockSize, repeat: 0)
        configuration.encrypt(encryptionKey, encryptionIv, []).copyTo(buffer[offset..])
        offset += configuration.encryptionAlgorithmBlockSize
        // 8. 算法特征：空字符串 HMAC 结果
        let validationKey = tempKeys[configuration.encryptionAlgorithmKeySize..]
        configuration.digest(validationKey, [0]).copyTo(buffer[offset..])
        offset += configuration.validationAlgorithmDigestSize
        return buffer
    }
}

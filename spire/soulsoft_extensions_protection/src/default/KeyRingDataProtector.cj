// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_protection.default

import std.sync.*
import std.binary.*
import std.collection.*

protected class KeyRingDataProtector <: IDataProtector {
    private let _purposes: Array<String>
    private let _keyRingProvider: IKeyRingProvider
    private let _aadTemplate: AdditionalAuthenticatedDataTemplate

    public init(keyRingProvider: IKeyRingProvider, currentPurpose: String, originalPurposes: Array<String>) {
        _keyRingProvider = keyRingProvider
        _purposes = originalPurposes.concat(currentPurpose)
        _aadTemplate = AdditionalAuthenticatedDataTemplate(_purposes)
    }

    public func protect(plaintext: Array<Byte>): Array<Byte> {
        let keyRing = _keyRingProvider.getCurrentKeyRing()
        let keyId = keyRing.defaultKeyId
        if (let Some(encryptor) <- keyRing.getAuthenticatedEncryptorByKeyId(keyId)) {
            let additionalAuthenticatedData = _aadTemplate.getAadForKey(keyId, true)
            let payload = encryptor.encrypt(plaintext, additionalAuthenticatedData)
            let magicHeader = additionalAuthenticatedData.slice(0, 4)
            return magicHeader.concat(keyId.toBytes()).concat(payload)
        }
        // defaultKeyId 始终在密钥环中，此处理论上不可达
        throw UnsupportedException("Default key '${keyId}' not found in key ring.")
    }

    public func unprotect(ciphertext: Array<Byte>): Array<Byte> {
        if (ciphertext.size < Constants.MAGIC_HEADER_SIZE + Constants.KEY_ID_SIZE) {
            throw UnsupportedException("Invalid ciphertext.")
        }
        let keyId = AdditionalAuthenticatedDataTemplate.readKeyId(ciphertext)
        var keyRing = _keyRingProvider.getCurrentKeyRing()
        var encryptor = keyRing.getAuthenticatedEncryptorByKeyId(keyId)

        // 在自动刷新窗口内，若密钥未知（集群新密钥尚未同步到本节点），强制刷新一次
        if (encryptor.isNone() && let provider: KeyRingProvider <- _keyRingProvider) {
            if (provider.inAutoRefreshWindow()) {
                keyRing = provider.refreshCurrentKeyRing()
                encryptor = keyRing.getAuthenticatedEncryptorByKeyId(keyId)
            }
        }

        if (let Some(enc) <- encryptor) {
            let additionalAuthenticatedData = _aadTemplate.getAadForKey(keyId, false)
            let offset = Constants.MAGIC_HEADER_SIZE + Constants.KEY_ID_SIZE
            return enc.decrypt(ciphertext[offset..], additionalAuthenticatedData)
        }
        throw UnsupportedException("The key ring does not contain key '${keyId}'.")
    }

    public func createProtector(purpose: String): IDataProtector {
        return KeyRingDataProtector(_keyRingProvider, purpose, _purposes)
    }
}

/*
AAD: 防止重复攻击
 */
class AdditionalAuthenticatedDataTemplate {
    private let _template = AtomicReference<Box<Array<Byte>>>(Box<Array<Byte>>([]))

    AdditionalAuthenticatedDataTemplate(purposes: Collection<String>) {
        _template.store(Box<Array<Byte>>(buildAadTemplateBytes(purposes)))
    }

    public func getAadForKey(keyId: KeyIdentifier, isProtecting: Bool) {
        let existingTemplate = _template.load().value
        if (keyId == readKeyId(existingTemplate)) {
            return existingTemplate
        }

        let templateCopy = existingTemplate.clone()
        writeKeyId(templateCopy, keyId)
        if (isProtecting) {
            _template.store(Box<Array<Byte>>(templateCopy))
        }
        return templateCopy
    }

    public static func readKeyId(template: Array<Byte>) {
        let bytes = template.slice(Constants.MAGIC_HEADER_SIZE, Constants.KEY_ID_SIZE)
        return KeyIdentifier(bytes)
    }

    private func writeKeyId(template: Array<Byte>, keyId: KeyIdentifier) {
        keyId.toBytes().copyTo(template[Constants.MAGIC_HEADER_SIZE..])
    }

    private static func buildAadTemplateBytes(purposes: Collection<String>) {
        var totalLength = 4 + 16 + 4 // magicHeader + keyId + purposeCount
        let purposesUtf8Byte = purposes |> map {f => f.toArray()} |> collectArray
        let purposesUtf8Size = purposesUtf8Byte |> map {f => f.size} |> collectArray
        for (i in 0..purposes.size) {
            let encoded7BitLength = purposesUtf8Size[i].measure7BitEncodedUIntLength()
            totalLength += purposesUtf8Size[i] + encoded7BitLength
        }

        let buffer = Array<Byte>(totalLength, repeat: 0)
        var index = 0
        // 1. MagicHeader
        UInt32(Constants.MAGIC_HEADER_VALUE).writeBigEndian(buffer)
        index += Constants.MAGIC_HEADER_SIZE
        // 2. 跳过KeyId
        index += Constants.KEY_ID_SIZE // 跳过keyId

        // 3. 写入purposes个数
        UInt32(purposes.size).writeBigEndian(buffer[index..])
        index += 4
        // 4. 写入purposes
        for (i in 0..purposes.size) {
            index += buffer[index..].write7BitEncodedInt(purposesUtf8Size[i])
            purposesUtf8Byte[i].copyTo(buffer[index..])
            index += purposesUtf8Byte[i].size
        }
        return buffer
    }
}

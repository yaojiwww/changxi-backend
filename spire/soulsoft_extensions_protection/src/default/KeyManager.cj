// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_protection.default

import std.env.*
import std.time.*
import std.sync.*
import std.collection.*
import stdx.encoding.hex.*
import stdx.encoding.json.*
import soulsoft_extensions_options.*

protected class KeyManager <: IKeyManager {
    private let _activator: IActivator
    private let _newKeyLifetime: Duration
    private let _keyRepository: IKeyRepository
    private let _configuration: AlgorithmConfiguration
    private let _authenticatedEncryptorFactories: ArrayList<IAuthenticatedEncryptorFactory>
    private let _keyEscrowSinks: ArrayList<IKeyEscrowSink>
    // 缓存失效令牌：先 swap 换入新令牌，再 fire 触发旧令牌，保证新缓存不会拿到已触发的令牌
    private let _currentToken = AtomicReference<KeyExpirationToken>(KeyExpirationToken())

    public KeyManager(activator: IActivator, options: IOptions<KeyManagementOptions>) {
        _activator = activator
        _newKeyLifetime = options.value.newKeyLifetime
        _authenticatedEncryptorFactories = options.value.authenticatedEncryptorFactories
        _configuration = options.value.authenticatedEncryptorConfiguration ?? AuthenticatedEncryptorConfiguration()
        _keyRepository = options.value.keyRepository ?? FileSystemKeyRepository(getDefaultKeyStorageDirectory())
        _keyEscrowSinks = options.value.keyEscrowSinks
    }

    public func createNewKey(activationDate: DateTime, expirationDate: DateTime): IKey {
        let keyId = KeyIdentifier.create()
        let descriptor = _configuration.createNewDescriptor()
        let currentTime = DateTime.nowUTC()
        let key = Key(keyId, currentTime, expirationDate, activationDate, descriptor)
        let jsonObject = JsonObject()
        let descriptorInfo = descriptor.exportToJson()
        jsonObject.put("keyId", JsonString(key.keyId.toString()))
        jsonObject.put("version", JsonInt(1))
        jsonObject.put("creationDate", JsonString(key.creationDate.toString()))
        jsonObject.put("activationDate", JsonString(key.activationDate.toString()))
        jsonObject.put("expirationDate", JsonString(key.expirationDate.toString()))
        jsonObject.put("deserializerType", JsonString(descriptorInfo.typeInfo.qualifiedName))
        jsonObject.put("descriptor", descriptorInfo.jsonValue)
        // 在写入存储库之前，先将明文密钥材料分发给所有托管接收器
        for (sink in _keyEscrowSinks) {
            sink.store(keyId, jsonObject)
        }
        let keyIdStr = keyId.toString()
        _keyRepository.store(jsonObject, "${keyIdStr}.json")
        // 新密钥已写入存储，触发令牌使所有节点的缓存失效，确保集群同步
        fireAndRenewToken()
        return key
    }

    public func getAllKeys(): ReadOnlyList<IKey> {
        let files = _keyRepository.getAll()

        // 第一遍：收集所有撤销记录
        // - 单个撤销：keyId 为具体 id
        // - 批量撤销：keyId 为 "*"，保留最晚的撤销日期（严格小于该日期创建的密钥均被撤销）
        let revokedKeyIds = HashSet<String>()
        var massRevocationDate: ?DateTime = None
        for (jsonObj in files) {
            // 撤销文件特征：有 revocationDate 字段，且没有 descriptor 字段
            if (!jsonObj.containsKey("revocationDate") || jsonObj.containsKey("descriptor")) {
                continue
            }
            if (!jsonObj.containsKey("keyId")) {
                continue
            }
            try {
                let keyIdField = jsonObj["keyId"].asString().getValue()
                let revDate = DateTime.parse(jsonObj["revocationDate"].asString().getValue())
                if (keyIdField == "*") {
                    massRevocationDate = if (let Some(existing) <- massRevocationDate) {
                        if (revDate > existing) {
                            Some(revDate)
                        } else {
                            Some(existing)
                        }
                    } else {
                        Some(revDate)
                    }
                } else {
                    revokedKeyIds.add(keyIdField)
                }
            } catch (_: Exception) {
                // 撤销记录损坏（字段缺失/类型错误/日期格式非法），跳过，不阻断其余密钥加载
            }
        }

        // 第二遍：构建密钥列表，将撤销信息合并进来
        let keys = ArrayList<IKey>()
        for (jsonObj in files) {
            if (!jsonObj.containsKey("descriptor")) {
                continue
            }
            if (let Some(key) <- processJsonValue(jsonObj, revokedKeyIds, massRevocationDate)) {
                keys.add(key)
            }
        }
        return keys
    }

    public func createEncryptorInstance(key: IKey): IAuthenticatedEncryptor {
        for (pattern in _authenticatedEncryptorFactories) {
            if (let Some(encryptor) <- pattern.createEncryptorInstance(key)) {
                return encryptor
            }
        }
        throw UnsupportedException(
            "No encryptor factory could handle key '${key.keyId}'. Registered factories: ${_authenticatedEncryptorFactories.size}")
    }

    // 撤销单个密钥：只写一个新的撤销文件，不读取也不修改任何已有文件
    public func revokeKey(keyId: KeyIdentifier, reason: String): Unit {
        let jsonObject = JsonObject()
        let keyIdStr = keyId.toString()
        jsonObject.put("revocationDate", JsonString(DateTime.nowUTC().toString()))
        jsonObject.put("keyId", JsonString(keyIdStr))
        jsonObject.put("reason", JsonString(reason))
        _keyRepository.store(jsonObject, "revocation-${keyIdStr}.json")
        fireAndRenewToken()
    }

    // 批量撤销密钥：只写一个新的撤销文件，不读取也不修改任何已有文件
    // 严格小于 revocationDate 创建的密钥均被撤销（与微软行为一致）
    public func revokeAllKeys(revocationDate: DateTime, reason: String): Unit {
        let jsonObject = JsonObject()
        jsonObject.put("revocationDate", JsonString(revocationDate.toString()))
        jsonObject.put("keyId", JsonString("*"))
        jsonObject.put("reason", JsonString(reason))
        let ts = DateTime.nowUTC().toUnixTimeStamp().toSeconds()
        _keyRepository.store(jsonObject, "revocation-allkeys-${ts}.json")
        fireAndRenewToken()
    }

    public func getCacheExpirationToken(): IKeyExpirationToken {
        return _currentToken.load()
    }

    // 先换入新令牌，再触发旧令牌：确保 getCacheExpirationToken() 不会返回已触发的令牌
    private func fireAndRenewToken(): Unit {
        let oldToken = _currentToken.swap(KeyExpirationToken())
        oldToken.cancel()
    }

    private func processJsonValue(jsonObject: JsonObject, revokedKeyIds: HashSet<String>, massRevocationDate: ?DateTime): ?IKey {
        try {
            let descriptorJson = jsonObject["descriptor"].asObject()
            let deserializerType = jsonObject["deserializerType"].asString().getValue()
            if (let deserializer: IAuthenticatedEncryptorDescriptorDeserializer <- _activator.createInstance(
                deserializerType)) {
                let descriptor = deserializer.importFromJson(descriptorJson)
                let keyId = KeyIdentifier(fromHexString(jsonObject["keyId"].asString().getValue()).getOrThrow())
                let creationDate = DateTime.parse(jsonObject["creationDate"].asString().getValue())
                let expirationDate = DateTime.parse(jsonObject["expirationDate"].asString().getValue())
                let activationDate = DateTime.parse(jsonObject["activationDate"].asString().getValue())
                let keyIdStr = keyId.toString()
                let revokedById = revokedKeyIds.contains(keyIdStr)
                let revokedByMass = if (let Some(massDate) <- massRevocationDate) {
                    creationDate < massDate
                } else {
                    false
                }
                let isRevoked = revokedById || revokedByMass
                return Key(keyId, creationDate, expirationDate, activationDate, descriptor, isRevoked: isRevoked)
            }
            return None
        } catch (_: Exception) {
            // 密钥记录损坏（字段缺失/类型错误/日期格式非法/解密失败），跳过该密钥
            return None
        }
    }

    private static func getDefaultKeyStorageDirectory() {
        return getHomeDirectory().join(".cangjie").join("DataProtection-Keys")
    }
}

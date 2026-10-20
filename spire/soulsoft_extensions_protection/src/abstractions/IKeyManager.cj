// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_protection.abstractions

import std.time.*
import std.collection.*

/**
 * @brief 定义密钥创建、查询与撤销的管理接口。
 * @note 所有实现都应保证线程安全。
 */
public interface IKeyManager {
    /**
     * @brief 创建新密钥并持久化到底层存储。
     * @param activationDate 密钥可用于加密的起始时间。
     * @param expirationDate 密钥不再接受新加密操作的截止时间。
     * @return 返回新创建的密钥。
     */
    func createNewKey(activationDate: DateTime, expirationDate: DateTime): IKey

    /**
     * @brief 从底层存储加载全部密钥。
     * @return 返回包含全部密钥的只读列表。
     */
    func getAllKeys(): ReadOnlyList<IKey>

    /**
     * @brief 为指定密钥创建认证加密器实例。
     * @param key 需要创建加密器的密钥。
     * @return 返回认证加密器实例。
     */
    func createEncryptorInstance(key: IKey): IAuthenticatedEncryptor

    /**
     * @brief 撤销指定密钥并持久化撤销状态。
     * @param keyId 要撤销的密钥标识。
     * @param reason 用于审计的撤销原因。
     * @note 调用后应重新加载密钥实例。
     */
    func revokeKey(keyId: KeyIdentifier, reason: String): Unit

    /**
     * @brief 撤销指定日期之前创建的所有密钥并持久化。
     * @param revocationDate 撤销截止日期。
     * @param reason 用于审计的撤销原因。
     * @note 调用后应重新加载密钥实例。
     */
    func revokeAllKeys(revocationDate: DateTime, reason: String): Unit

    /**
     * @brief 获取当前缓存失效令牌。
     * @return 返回当前缓存失效令牌。
     */
    func getCacheExpirationToken(): IKeyExpirationToken
}

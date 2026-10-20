// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_protection.default

import std.time.*

/**
 * @brief 提供数据保护密钥默认实现。
 */
public class Key <: IKey {
    private let _keyId: KeyIdentifier
    private let _creationDate: DateTime
    private let _expirationDate: DateTime
    private let _activationDate: DateTime
    private let _isRevoked: Bool
    private let _descriptor: IAuthenticatedEncryptorDescriptor

    /**
     * @brief 创建密钥实例。
     * @param keyId 密钥标识。
     * @param creationDate 密钥创建时间。
     * @param expirationDate 密钥过期时间。
     * @param activationDate 密钥激活时间。
     * @param descriptor 密钥对应的认证加密器描述符。
     * @param isRevoked 指示密钥是否已撤销。
     */
    public init(keyId: KeyIdentifier, creationDate: DateTime, expirationDate: DateTime, activationDate: DateTime,
        descriptor: IAuthenticatedEncryptorDescriptor, isRevoked!: Bool = false) {
        _keyId = keyId
        _creationDate = creationDate
        _expirationDate = expirationDate
        _activationDate = activationDate
        _isRevoked = isRevoked
        _descriptor = descriptor
    }

    /**
     * @brief 返回当前密钥标识。
     * @return 返回当前密钥标识。
     */
    public prop keyId: KeyIdentifier {
        get() {
            _keyId
        }
    }

    /**
     * @brief 返回当前密钥创建时间。
     * @return 返回当前密钥创建时间。
     */
    public prop creationDate: DateTime {
        get() {
            _creationDate
        }
    }

    /**
     * @brief 返回当前密钥过期时间。
     * @return 返回当前密钥过期时间。
     */
    public prop expirationDate: DateTime {
        get() {
            _expirationDate
        }
    }

    /**
     * @brief 返回当前密钥激活时间。
     * @return 返回当前密钥激活时间。
     */
    public prop activationDate: DateTime {
        get() {
            _activationDate
        }
    }

    /**
     * @brief 返回当前密钥是否已撤销。
     * @return 如果当前密钥已撤销则返回 true，否则返回 false。
     */
    public prop isRevoked: Bool {
        get() {
            _isRevoked
        }
    }

    /**
     * @brief 返回当前密钥描述符。
     * @return 返回当前密钥描述符。
     */
    public prop descriptor: IAuthenticatedEncryptorDescriptor {
        get() {
            _descriptor
        }
    }
}

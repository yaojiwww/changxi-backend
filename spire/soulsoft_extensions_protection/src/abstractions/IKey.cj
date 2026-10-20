// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_protection.abstractions

import std.time.*

/**
 * @brief 定义数据保护密钥接口。
 */
public interface IKey {
    /**
     * @brief 返回当前密钥标识。
     */
    prop keyId: KeyIdentifier

    /**
     * @brief 返回密钥创建时间。
     */
    prop creationDate: DateTime

    /**
     * @brief 返回密钥过期时间。
     */
    prop expirationDate: DateTime

    /**
     * @brief 返回密钥激活时间。
     */
    prop activationDate: DateTime

    /**
     * @brief 返回密钥是否已被撤销。
     */
    prop isRevoked: Bool

    /**
     * @brief 返回密钥对应的认证加密器描述符。
     */
    prop descriptor: IAuthenticatedEncryptorDescriptor
}

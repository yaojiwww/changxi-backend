// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_protection.abstractions

/**
 * @brief 定义密钥环接口。
 */
public interface IKeyRing {
    /**
     * @brief 返回默认密钥标识。
     */
    prop defaultKeyId: KeyIdentifier

    /**
     * @brief 返回默认密钥对应的认证加密器。
     */
    prop defaultAuthenticatedEncryptor: IAuthenticatedEncryptor

    /**
     * @brief 根据密钥标识获取认证加密器。
     * @param keyId 密钥标识。
     * @return 返回对应的认证加密器；不存在时返回空。
     */
    func getAuthenticatedEncryptorByKeyId(keyId: KeyIdentifier): ?IAuthenticatedEncryptor
}

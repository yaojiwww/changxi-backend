// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_protection.default

/**
 * @brief 提供认证加密器工厂默认实现。
 */
public class AuthenticatedEncryptorFactory <: IAuthenticatedEncryptorFactory {
    /**
     * @brief 根据密钥创建认证加密器实例。
     * @param key 用于创建加密器的密钥。
     * @return 返回认证加密器实例；不支持时返回空。
     */
    public func createEncryptorInstance(key: IKey): ?IAuthenticatedEncryptor {
        if (let descriptor: AuthenticatedEncryptorDescriptor <- key.descriptor) {
            return AuthenticatedEncryptor(descriptor.masterKey, descriptor.configuration)
        }
        return None
    }
}

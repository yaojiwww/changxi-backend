// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_protection.abstractions

/**
 * @brief 定义创建认证加密器实例的工厂接口。
 */
public interface IAuthenticatedEncryptorFactory {
    /**
     * @brief 根据指定密钥创建认证加密器实例。
     * @param key 用于创建加密器的密钥。
     * @return 返回创建出的认证加密器；无法创建时返回空。
     */
    func createEncryptorInstance(key: IKey): ?IAuthenticatedEncryptor
}

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_protection.abstractions

/**
 * @brief 定义认证加密器接口。
 */
public interface IAuthenticatedEncryptor {
    /**
     * @brief 解密带认证数据的密文字节数组。
     * @param ciphertext 需要解密的密文字节数组。
     * @param additionalAuthenticatedData 参与认证但不加密的附加数据。
     * @return 返回解密后的明文字节数组。
     */
    func decrypt(ciphertext: Array<Byte>, additionalAuthenticatedData: Array<Byte>): Array<Byte>

    /**
     * @brief 加密明文字节数组并附加认证数据。
     * @param plaintext 需要加密的明文字节数组。
     * @param additionalAuthenticatedData 参与认证但不加密的附加数据。
     * @return 返回加密后的密文字节数组。
     */
    func encrypt(plaintext: Array<Byte>, additionalAuthenticatedData: Array<Byte>): Array<Byte>
}

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_protection.abstractions

/**
 * @brief 定义数据加密与解密能力的保护器接口。
 */
public interface IDataProtector <: IDataProtectionProvider {
    /**
     * @brief 保护明文字节数组。
     * @param plaintext 需要保护的明文字节数组。
     * @return 返回加密后的字节数组。
     */
    func protect(plaintext: Array<Byte>): Array<Byte>

    /**
     * @brief 还原受保护的字节数组。
     * @param ciphertext 受保护的字节数组。
     * @return 返回解密后的明文字节数组。
     */
    func unprotect(ciphertext: Array<Byte>): Array<Byte>
}

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_protection.abstractions

/**
 * @brief 定义密钥机密材料的访问接口。
 */
public interface ISecret <: ToString {
    /**
     * @brief 返回机密材料的字节长度。
     */
    prop size: Int64

    /**
     * @brief 导出机密材料的字节副本。
     * @return 返回机密材料的字节数组。
     */
    func bytes(): Array<Byte>

    /**
     * @brief 将机密材料写入指定缓冲区。
     * @param buffer 用于接收机密材料的缓冲区。
     */
    func writeSecretIntoBuffer(buffer: Array<Byte>): Unit
}

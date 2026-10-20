// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_protection.utilities

import std.binary.*
import std.crypto.digest.*
import stdx.crypto.digest.*

/*
NIST SP800-108密钥派生
 */
protected class SP800_108_CTR_HMACSHA512Util {
    public static func deriveEmptyKey(length: Int64) {
        return deriveKey([0], [], [], length)
    }

    public static func deriveKey(km: Array<Byte>, label: Array<Byte>, content: Array<Byte>, length: Int64) {
        let totalLength = 4 + label.size + 1 + content.size + 4
        let buffer = Array<Byte>(totalLength, repeat: 0)
        // PRF 输入构建（NIST SP800-108）
        // [Counter] [Label] [Separator] [Context] [OutputLength]
        var offset = 0
        //  1. Counter (Big-Endian)
        UInt32(1).writeBigEndian(buffer[offset..])
        offset += 4
        // 2. Label (AAD)
        label.copyTo(buffer[offset..])
        offset += label.size
        // 3. Separator
        buffer[offset] = UInt8(0x00)
        offset += 1
        // 4. Context (算法指纹)
        content.copyTo(buffer[offset..])
        offset += content.size
        // 5. Output Length (Big-Endian)
        UInt32(length * 8).writeBigEndian(buffer[offset..])
        // 6. 执行 HMAC-SHA512
        let total = (length + 63) / 64
        let keys = Array<Byte>(total * 64, repeat: 0)
        for (i in 0..(total)) {
            UInt32(i + 1).writeBigEndian(buffer)
            let subKeys = digest(km, buffer)
            subKeys.copyTo(keys[i * 64..])
        }
        return keys.slice(0, length)
    }

    private static func digest(key: Array<Byte>, input: Array<Byte>) {
        return digest(HMAC(key, HashType.SHA512), input)
    }
}

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_protection.default

protected interface I7BitEncodedInt64Extensions {
    func measure7BitEncodedUIntLength(): Int64
}

/**
 * @brief 定义 7 位编码写入扩展接口。
 */
public interface I7BitEncodedBytesExtensions {
    /**
     * @brief 将整数按 7 位编码格式写入字节数组。
     * @param value 需要写入的整数值。
     * @return 返回写入的字节数。
     */
    func write7BitEncodedInt(value: Int64): Int64
}

extend Int64 <: I7BitEncodedInt64Extensions {
    /**
     * @brief 计算当前整数按 7 位编码后的字节长度。
     * @return 返回编码所需的字节数。
     */
    public func measure7BitEncodedUIntLength(): Int64 {
        var uValue = UInt32(this)

        var length = 1
        while (uValue > 0x7F) {
            uValue >>= 7
            length++
        }

        return length
    }
}

extend Array<UInt8> <: I7BitEncodedBytesExtensions {
    /**
     * @brief 将整数按 7 位编码格式写入当前字节数组。
     * @param value 需要写入的整数值。
     * @return 返回写入的字节数。
     */
    @OverflowWrapping
    public func write7BitEncodedInt(value: Int64): Int64 {
        var uValue = UInt32(value)
        var bytesWritten = 0
        var offset = 0
        while (uValue > 0x7F) {
            this[offset] = UInt8(uValue | 0x80)
            uValue >>= 7
            bytesWritten++
            offset++
        }

        this[offset] = UInt8(uValue)
        bytesWritten++
        return bytesWritten
    }
}

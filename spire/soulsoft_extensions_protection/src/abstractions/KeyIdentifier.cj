// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_protection.abstractions

import stdx.encoding.hex.*
import stdx.crypto.crypto.*

/**
 * @brief 表示数据保护密钥标识。
 */
public struct KeyIdentifier <: Equatable<KeyIdentifier> & ToString & Hashable {
    private static let instance = SecureRandom()
    private let _bytes: Array<Byte>

    /**
     * @brief 使用指定字节创建密钥标识。
     * @param bytes 密钥标识字节数组。
     */
    public init(bytes: Array<Byte>) {
        _bytes = bytes
    }

    /**
     * @brief 判断两个密钥标识是否相等。
     * @param that 需要比较的另一个密钥标识。
     * @return 如果两个密钥标识相等则返回 `true`。
     */
    public operator func ==(that: KeyIdentifier): Bool {
        this._bytes == that._bytes
    }

    /**
     * @brief 返回密钥标识的字节副本。
     * @return 返回密钥标识字节数组。
     */
    public func toBytes(): Array<Byte> {
        return _bytes.clone()
    }

    /**
     * @brief 创建新的随机密钥标识。
     * @return 返回新生成的密钥标识。
     */
    public static func create(): KeyIdentifier {
        let bytes = Array<Byte>(16, repeat: 0)
        instance.nextBytes(bytes)
        return KeyIdentifier(bytes)
    }

    /**
     * @brief 返回密钥标识的十六进制字符串表示。
     * @return 返回密钥标识字符串。
     */
    public func toString(): String {
        toHexString(_bytes)
    }

    /**
     * @brief 返回密钥标识的哈希码。
     * @return 返回密钥标识哈希值。
     */
    public func hashCode(): Int64 {
        var hasher = DefaultHasher()
        for (byte in _bytes) {
            hasher.write(byte)
        }
        return hasher.finish()
    }
}

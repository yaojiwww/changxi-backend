// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_protection.abstractions

/**
 * @brief 表示支持的加密算法枚举。
 */
public enum EncryptionAlgorithm <: ToString {
    /**
     * @brief 表示 `SM4_128_CBC` 加密算法。
     */
    SM4_128_CBC

    /**
     * @brief 返回当前加密算法的字符串表示。
     * @return 返回当前加密算法名称。
     */
    public func toString(): String {
        match (this) {
            case SM4_128_CBC => "SM4_128_CBC"
        }
    }

    /**
     * @brief 根据字符串解析加密算法。
     * @param str 加密算法名称。
     * @return 返回解析后的加密算法。
     * @throws UnsupportedException 当字符串不对应已支持的加密算法时抛出。
     */
    public static func fromStr(str: String): EncryptionAlgorithm {
        match (str) {
            case "SM4_128_CBC" => SM4_128_CBC
            case _ => throw UnsupportedException("${str}")
        }
    }
}

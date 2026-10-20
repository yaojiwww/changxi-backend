// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_protection.abstractions

/**
 * @brief 表示支持的验证算法枚举。
 */
public enum ValidationAlgorithm <: ToString {
    /**
     * @brief 表示 `HMACSHA256` 验证算法。
     */
    HMACSHA256

    /**
     * @brief 表示 `HMACSHA512` 验证算法。
     */
    | HMACSHA512

    /**
     * @brief 返回当前验证算法的字符串表示。
     * @return 返回当前验证算法名称。
     */
    public func toString(): String {
        match (this) {
            case HMACSHA256 => "HMACSHA256"
            case HMACSHA512 => "HMACSHA512"
        }
    }

    /**
     * @brief 根据字符串解析验证算法。
     * @param str 验证算法名称。
     * @return 返回解析后的验证算法。
     * @throws UnsupportedException 当字符串不对应已支持的验证算法时抛出。
     */
    public static func fromStr(str: String): ValidationAlgorithm {
        match (str) {
            case "HMACSHA256" => HMACSHA256
            case "HMACSHA512" => HMACSHA512
            case _ => throw UnsupportedException("")
        }
    }
}

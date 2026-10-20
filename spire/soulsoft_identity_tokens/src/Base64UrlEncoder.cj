// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_tokens

import stdx.encoding.base64.*

/**
 * @brief 提供 Base64Url 编码与解码工具。
 */
public class Base64UrlEncoder {
    /**
     * @brief 将字符串编码为 Base64Url 文本。
     * @param input 要编码的 UTF-8 字符串。
     * @return 编码后的 Base64Url 字符串。
     */
    public static func encode(input: String): String {
        return encode(input.toArray())
    }

    /**
     * @brief 将字节数组编码为 Base64Url 文本。
     * @param data 要编码的字节数组。
     * @return 编码后的 Base64Url 字符串。
     */
    public static func encode(data: Array<Byte>): String {
        // Base64URL (RFC 4648 §5)：标准 Base64 → 替换字符 → 去 padding
        return toBase64String(data).replace("+", "-").replace("/", "_").replace("=", "")
    }

    /**
     * @brief 将 Base64Url 文本解码为字节数组。
     * @param input 要解码的 Base64Url 字符串。
     * @return 解码得到的字节数组；解码失败时返回 `None`。
     */
    public static func decodeBytes(input: String): ?Array<Byte> {
        // 还原 Base64URL 字符 → 补 padding → 标准 Base64 解码
        let s = input.replace("-", "+").replace("_", "/")
        let padded = match (s.size % 4) {
            case 2 => s + "=="
            case 3 => s + "="
            case _ => s
        }
        return fromBase64String(padded)
    }

    /**
     * @brief 将 Base64Url 文本解码为字符串。
     * @param input 要解码的 Base64Url 字符串。
     * @return 解码得到的 UTF-8 字符串；解码失败时返回 `None`。
     */
    public static func decode(input: String): ?String {
        if (let Some(data) <- decodeBytes(input)) {
            return unsafe {
                String.fromUtf8Unchecked(data)
            }
        }
        return None
    }
}

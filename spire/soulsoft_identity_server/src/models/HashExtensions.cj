/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.models

import std.crypto.digest.*
import stdx.crypto.digest.*
import stdx.encoding.base64.*

/**
 * @brief 定义字符串摘要计算扩展能力。
 */
public interface HashExtensions {
    /**
     * @brief 计算字符串的 SHA-256 摘要并返回 Base64 编码结果。
     * @return 返回 SHA-256 摘要的 Base64 字符串。
     */
    func sha256(): String
    /**
     * @brief 计算字符串的 SHA-384 摘要并返回 Base64 编码结果。
     * @return 返回 SHA-384 摘要的 Base64 字符串。
     */
    func sha384(): String
    /**
     * @brief 计算字符串的 SHA-512 摘要并返回 Base64 编码结果。
     * @return 返回 SHA-512 摘要的 Base64 字符串。
     */
    func sha512(): String
}

extend String <: HashExtensions {
    /**
     * @brief 计算当前字符串的 SHA-256 摘要并返回 Base64 编码结果。
     * @return 返回 SHA-256 摘要的 Base64 字符串。
     */
    public func sha256(): String {
        let sha = SHA256()
        return digest(sha, toArray()) |> toBase64String
    }

    /**
     * @brief 计算当前字符串的 SHA-384 摘要并返回 Base64 编码结果。
     * @return 返回 SHA-384 摘要的 Base64 字符串。
     */
    public func sha384(): String {
        let sha = SHA384()
        return digest(sha, toArray()) |> toBase64String
    }

    /**
     * @brief 计算当前字符串的 SHA-512 摘要并返回 Base64 编码结果。
     * @return 返回 SHA-512 摘要的 Base64 字符串。
     */
    public func sha512(): String {
        let sha = SHA512()
        return digest(sha, toArray()) |> toBase64String
    }
}

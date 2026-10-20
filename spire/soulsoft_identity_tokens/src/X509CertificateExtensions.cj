// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_tokens

import std.unicode.*
import stdx.crypto.x509.*
import stdx.encoding.hex.*
import stdx.crypto.digest.*

extend X509Certificate {
    /**
     * @brief 计算证书的十六进制 SHA-1 指纹。
     * @return 大写十六进制表示的证书指纹。
     */
    public func getThumbprint(): String {
        let hasher = SHA1()
        hasher.write(this.encodeToDer().body)
        let hash = hasher.finish()
        return toHexString(hash).toUpper()
    }

    /**
     * @brief 计算证书的 Base64Url SHA-1 指纹。
     * @return Base64Url 编码的证书指纹。
     */
    public func getX5t(): String {
        let hasher = SHA1()
        hasher.write(this.encodeToDer().body)
        let hash = hasher.finish()
        return Base64UrlEncoder.encode(hash)
    }
}

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_tokens

import stdx.crypto.x509.*

/**
 * @brief 表示基于 X.509 证书的安全密钥。
 */
public class X509SecurityKey <: AsymmetricSecurityKey {
    private let _x5t: String
    private let _keyId: ?String
    private let _keySize: Int64
    private let _certificate: X509Certificate

    /**
     * @brief 使用证书和显式密钥标识创建 X.509 安全密钥。
     * @param certificate 关联的 X.509 证书。
     * @param keyId 显式指定的密钥标识。
     */
    public init(certificate: X509Certificate, keyId: String) {
        _keyId = keyId
        _x5t = certificate.getX5t()
        _certificate = certificate
        _keySize = certificate.publicKey.encodeToDer().size
    }

    /**
     * @brief 使用证书创建 X.509 安全密钥。
     * @param certificate 关联的 X.509 证书。
     */
    public init(certificate: X509Certificate) {
        this(certificate, certificate.getThumbprint())
    }

    /**
     * @brief 获取证书对应的密钥标识。
     * @return 当前密钥标识。
     */
    public prop keyId: ?String {
        get() {
            _keyId
        }
    }

    /**
     * @brief 获取证书公钥大小。
     * @return 当前证书公钥的编码长度。
     */
    public prop keySize: Int64 {
        get() {
            _keySize
        }
    }
}

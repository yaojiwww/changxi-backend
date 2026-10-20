// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_identity_tokens_jwt

/**
 * @brief 表示 JWT 的三段编码内容。
 */
public struct JwtSegments {
    private let _rawData: String

    /**
     * @brief 创建 JWT 分段对象。
     * @param header 头部分段。
     * @param payload 载荷分段。
     * @param signature 签名分段。
     */
    public JwtSegments(public let header: String, public let payload: String, public let signature: String) {
        _rawData = "${header}.${payload}.${signature}"
    }

    /**
     * @brief 获取完整的 JWT 原始字符串。
     * @return 由三段内容拼接得到的原始 JWT 字符串。
     */
    public prop rawData: String {
        get() {
            _rawData
        }
    }
}

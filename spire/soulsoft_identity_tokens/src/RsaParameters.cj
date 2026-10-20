// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_tokens

/**
 * @brief 表示 RSA 密钥参数。
 */
public struct RsaParameters {
    /**
     * @brief 创建 RSA 密钥参数。
     * @param exponent 公钥指数。
     * @param modulus 模数。
     * @param d 私钥指数。
     * @param p 私钥质数 `p`。
     * @param q 私钥质数 `q`。
     * @param dp 私钥指数 `dp`。
     * @param dq 私钥指数 `dq`。
     * @param inverseQ 私钥系数 `inverseQ`。
     */
    public RsaParameters(
        public let exponent!: Array<Byte> = [],
        public let modulus!: Array<Byte> = [],
        public let d!: ?Array<Byte> = None,
        public let p!: ?Array<Byte> = None,
        public let q!: ?Array<Byte> = None,
        public let dp!: ?Array<Byte> = None,
        public let dq!: ?Array<Byte> = None,
        public let inverseQ!: ?Array<Byte> = None) {
    }
}

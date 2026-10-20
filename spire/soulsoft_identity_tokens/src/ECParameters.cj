// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
package soulsoft_identity_tokens

/**
 * @brief 表示椭圆曲线密钥参数。
 */
public struct ECParameters {
    /**
     * @brief 创建椭圆曲线密钥参数。
     * @param curve 椭圆曲线对象标识符。
     * @param q 公钥点坐标。
     * @param d 私钥标量。
     */
    public ECParameters(
        public let curve: String,
        public let q: ECPoint,
        public let d!: ?Array<Byte> = None) {
    }
}

/**
 * @brief 表示椭圆曲线公钥点坐标。
 */
public struct ECPoint {
    /**
     * @brief 创建椭圆曲线公钥点。
     * @param x 公钥点的 `x` 坐标字节。
     * @param y 公钥点的 `y` 坐标字节。
     */
    public ECPoint(public let x: Array<Byte>, public let y: Array<Byte>) {
    }
}

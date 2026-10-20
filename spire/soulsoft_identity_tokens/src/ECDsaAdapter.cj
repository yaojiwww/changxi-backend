// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
package soulsoft_identity_tokens

/**
 * @brief 提供 ECDSA 曲线标识转换工具。
 */
class ECDsaAdapter {
    /**
     * @brief 将曲线对象标识符转换为 JWK `crv` 值。
     * @param curve 椭圆曲线对象标识符。
     * @return 对应的 JWK 曲线名称。
     * @throws UnsupportedException 当曲线不受支持时抛出。
     */
    public static func getCrvParameterValue(curve: String): String {
        if (curve == '1.2.840.10045.3.1.7') {
            return 'P-256'
        }
        if (curve == '1.3.132.0.34') {
            return 'P-384'
        }
        if (curve == '1.3.132.0.35') {
            return 'P-521'
        }
        throw UnsupportedException("Unsupported EC curve: ${curve}")
    }

    /**
     * @brief 将 JWK `crv` 值转换为曲线对象标识符。
     * @param curveId JWK 曲线名称。
     * @return 对应的椭圆曲线对象标识符。
     * @throws UnsupportedException 当曲线不受支持时抛出。
     */
    public static func getNamedECCurve(curveId: String): String {
        if (curveId == 'P-256') {
            return '1.2.840.10045.3.1.7'
        }
        if (curveId == 'P-384') {
            return '1.3.132.0.34'
        }
        if (curveId == 'P-521') {
            return '1.3.132.0.35'
        }
        throw UnsupportedException("Unsupported curve ID: ${curveId}")
    }
}

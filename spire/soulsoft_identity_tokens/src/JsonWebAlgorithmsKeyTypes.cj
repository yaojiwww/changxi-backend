// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_identity_tokens

/**
 * @brief 定义 JWK 密钥类型常量。
 */
public class JsonWebAlgorithmsKeyTypes {
    /**
     * @brief 表示椭圆曲线密钥类型。
     */
    public static const EllipticCurve = "EC"
    /**
     * @brief 表示 RSA 密钥类型。
     */
    public static const RSA = "RSA"
    /**
     * @brief 表示对称八位组密钥类型。
     */
    public static const Octet = "oct"
}

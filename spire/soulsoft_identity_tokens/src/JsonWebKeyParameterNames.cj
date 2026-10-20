// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_tokens

/**
 * @brief 定义 JWK 常用参数名常量。
 */
public class JsonWebKeyParameterNames {
    /**
     * @brief 表示算法参数名。
     */
    public static let alg = "alg"
    /**
     * @brief 表示椭圆曲线参数名。
     */
    public static let crv = "crv"
    /**
     * @brief 表示私钥参数名。
     */
    public static let d = "d"
    /**
     * @brief 表示 RSA 私钥指数参数 `dp` 的名称。
     */
    public static let dp = "dp"
    /**
     * @brief 表示 RSA 私钥指数参数 `dq` 的名称。
     */
    public static let dq = "dq"
    /**
     * @brief 表示 RSA 公钥指数参数名。
     */
    public static let e = "e"
    /**
     * @brief 表示对称密钥材料参数名。
     */
    public static let k = "k"
    /**
     * @brief 表示密钥用途操作集合参数名。
     */
    public static let keyOps = "key_ops"
    /**
     * @brief 表示 JWK 集合参数名。
     */
    public static let keys = "keys"
    /**
     * @brief 表示密钥标识参数名。
     */
    public static let kid = "kid"
    /**
     * @brief 表示密钥类型参数名。
     */
    public static let kty = "kty"
    /**
     * @brief 表示 RSA 模数参数名。
     */
    public static let n = "n"
    /**
     * @brief 表示其他密钥参数集合名称。
     */
    public static let oth = "oth"
    /**
     * @brief 表示 RSA 私钥质数 `p` 参数名。
     */
    public static let p = "p"
    /**
     * @brief 表示 RSA 私钥质数 `q` 参数名。
     */
    public static let q = "q"
    /**
     * @brief 表示 RSA 系数参数 `qi` 名称。
     */
    public static let qi = "qi"
    /**
     * @brief 表示密钥用途参数名。
     */
    public static let use = "use"
    /**
     * @brief 表示椭圆曲线公钥 `x` 坐标参数名。
     */
    public static let x = "x"
    /**
     * @brief 表示 X.509 证书链参数名。
     */
    public static let x5c = "x5c"
    /**
     * @brief 表示 X.509 证书 SHA-1 指纹参数名。
     */
    public static let x5t = "x5t"
    /**
     * @brief 表示 X.509 证书 SHA-256 指纹参数名。
     */
    public static let x5tS256 = "x5t#S256"
    /**
     * @brief 表示 X.509 证书 URL 参数名。
     */
    public static let x5u = "x5u"
    /**
     * @brief 表示椭圆曲线公钥 `y` 坐标参数名。
     */
    public static let y = "y"
}

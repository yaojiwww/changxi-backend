// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_tokens

/**
 * @brief 表示 JSON Web Key。
 */
public class JsonWebKey <: SecurityKey {
    private var _convertedSecurityKey: ?SecurityKey = None

    /**
     * @brief 获取密钥标识。
     * @return `kid` 字段的值。
     */
    public prop keyId: ?String {
        get() {
            kid
        }
    }

    /**
     * @brief 获取密钥位长度。
     * @return 根据当前 JWK 类型推导出的位长度；无法推导时返回 `0`。
     */
    public prop keySize: Int64 {
        get() {
            if (kty == JsonWebAlgorithmsKeyTypes.RSA && let Some(data) <- n.flatMap {f => Base64UrlEncoder.decodeBytes(f)}) {
                return data.size * 8
            }

            if (kty == JsonWebAlgorithmsKeyTypes.EllipticCurve && let Some(data) <- x.flatMap {f => Base64UrlEncoder.decodeBytes(f)}) {
                return data.size * 8
            }

            if (kty == JsonWebAlgorithmsKeyTypes.Octet && let Some(data) <- k.flatMap {f => Base64UrlEncoder.decodeBytes(f)}) {
                return data.size * 8
            }

            return 0
        }
    }

    /**
     * @brief 检查当前 JWK 是否包含私钥材料。
     * @return 包含私钥参数时返回 `true`。
     */
    public prop hasPrivateKey: Bool {
        get() {
            if (kty == JsonWebAlgorithmsKeyTypes.RSA) {
                return d != None && dp != None && dq != None && p != None && q != None && qi != None
            }
            if (kty == JsonWebAlgorithmsKeyTypes.EllipticCurve) {
                return d != None
            }
            return false
        }
    }

    internal mut prop convertedSecurityKey: ?SecurityKey {
        get() {
            _convertedSecurityKey
        }
        set(value) {
            _convertedSecurityKey = value
        }
    }

    /**
     * @brief 创建 JSON Web Key 实例。
     * @param e RSA 公钥指数参数。
     * @param k 对称密钥的 Base64Url 编码值。
     * @param n RSA 模数参数。
     * @param d 私钥参数。
     * @param x 椭圆曲线公钥的 X 坐标。
     * @param y 椭圆曲线公钥的 Y 坐标。
     * @param p RSA 私钥的第一个素数因子。
     * @param q RSA 私钥的第二个素数因子。
     * @param qi RSA CRT 系数。
     * @param dp RSA 私钥指数对 `p - 1` 的模值。
     * @param dq RSA 私钥指数对 `q - 1` 的模值。
     * @param kid 密钥标识。
     * @param x5c X.509 证书链。
     * @param x5t X.509 SHA-1 证书指纹。
     * @param x5u X.509 证书 URL。
     * @param crv 椭圆曲线名称。
     * @param kty 密钥类型。
     * @param use 密钥用途。
     * @param alg 与密钥关联的算法。
     * @param x5tS256 X.509 SHA-256 证书指纹。
     */
    public JsonWebKey(public var e!: ?String = None, public var k!: ?String = None, public var n!: ?String = None,
        public var d!: ?String = None, public var x!: ?String = None, public var y!: ?String = None,
        public var p!: ?String = None, public var q!: ?String = None, public var qi!: ?String = None,
        public var dp!: ?String = None, public var dq!: ?String = None, public var kid!: ?String = None,
        public var x5c!: Array<String> = [], public var x5t!: ?String = None, public var x5u!: ?String = None,
        public var crv!: ?String = None, public var kty!: ?String = None, public var use!: ?String = None,
        public var alg!: ?String = None, public var x5tS256!: ?String = None) {
    }

    /**
     * @brief 从 JSON 字符串创建 JWK。
     * @param json JWK 的 JSON 表示。
     * @return 解析后的 `JsonWebKey` 实例。
     */
    public static func create(json: String): JsonWebKey {
        let jsonWebKey = JsonWebKey()
        JsonWebKeySerializer.read(json, jsonWebKey)
        return jsonWebKey
    }
}

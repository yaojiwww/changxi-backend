// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
package soulsoft_identity_tokens

import std.io.*
import std.fs.*
import stdx.crypto.keys.*
import stdx.crypto.common.*
import soulsoft_formats_asn1.*

/**
 * @brief 表示 ECDSA 安全密钥。
 */
public class ECDsaSecurityKey <: AsymmetricSecurityKey {
    private let _publicKey: ?ECDSAPublicKey
    private let _privateKey: ?ECDSAPrivateKey

    /**
     * @brief 使用公钥和私钥创建 ECDSA 安全密钥。
     * @param publicKey 可选的 ECDSA 公钥。
     * @param privateKey 可选的 ECDSA 私钥。
     */
    public init(publicKey!: ?ECDSAPublicKey = None, privateKey!: ?ECDSAPrivateKey = None) {
        _publicKey = publicKey
        _privateKey = privateKey
    }

    /**
     * @brief 从 JWK 创建 ECDSA 安全密钥。
     * @param jsonWebKey 包含椭圆曲线密钥材料的 JWK。
     * @throws IllegalArgumentException 当必填字段缺失或编码无效时抛出。
     * @throws UnsupportedException 当曲线标识不受支持时抛出。
     */
    public init(jsonWebKey: JsonWebKey) {
        this(ECDsaSecurityKey.parametersFromJwk(jsonWebKey))
    }

    /**
     * @brief 从椭圆曲线参数创建 ECDSA 安全密钥。
     * @param params 椭圆曲线密钥参数。
     */
    public init(params: ECParameters) {
        _publicKey = ECDsaSecurityKey.buildPublicKey(params)
        _privateKey = if (let Some(d) <- params.d) {
            ECDsaSecurityKey.buildPrivateKey(params, d)
        } else {
            None
        }
    }

    /**
     * @brief 获取密钥标识。
     * @return 当前实现始终返回 `None`。
     */
    public prop keyId: ?String {
        get() {
            None
        }
    }

    /**
     * @brief 获取 ECDSA 公钥。
     * @return 当前关联的公钥；不存在时返回 `None`。
     */
    public prop publicKey: ?ECDSAPublicKey {
        get() {
            _publicKey
        }
    }

    /**
     * @brief 获取 ECDSA 私钥。
     * @return 当前关联的私钥；不存在时返回 `None`。
     */
    public prop privateKey: ?ECDSAPrivateKey {
        get() {
            _privateKey
        }
    }

    /**
     * @brief 获取 ECDSA 密钥位长度。
     * @return 根据公钥坐标推导出的位长度；无法推导时返回 `0`。
     * @throws IllegalStateException 当 DER 解析失败时抛出。
     */
    public prop keySize: Int64 {
        get() {
            // x 坐标字节数 * 8 即为曲线位长（P-256=256, P-384=384, P-521=521 近似 528）。
            // ECDSAPublicKey 无法从私钥派生，私钥场景回退 0。
            if (let Some(_) <- _publicKey) {
                try {
                    let params = exportParameters(false)
                    return params.q.x.size * 8
                } catch (e: Exception) {
                    throw IllegalStateException("Failed to parse ECDsa key size from DER: ${e.message}")
                }
            }
            return 0
        }
    }

    /**
     * @brief 导出 ECDSA 密钥参数。
     * @param includePrivateParameters 是否同时导出私钥参数。
     * @return 导出的椭圆曲线密钥参数。
     * @throws IllegalArgumentException 当公钥不存在或点格式不受支持时抛出。
     */
    public func exportParameters(includePrivateParameters: Bool): ECParameters {
        if (let Some(key) <- _publicKey) {
            let body = key.encodeToDer().body
            let reader = AsnReader(body, AsnEncodingRules.DER)
            let seq0 = reader.readSequence()
            let seq1 = seq0.readSequence()
            seq1.readObjectIdentifier() // ecPublicKey
            let curve = seq1.readObjectIdentifier() // prime256v1
            let (bitStringData, _) = seq0.readBitString()
            // 仅支持未压缩点格式（0x04）；0x02/0x03 为压缩格式，需单独处理。
            // 静默跳过会产生错误坐标并传播至 JWK 序列化输出。
            if (bitStringData.size == 0 || bitStringData[0] != 0x04u8) {
                throw IllegalArgumentException(
                    "ECDsa public key must be in uncompressed point format (0x04 prefix), got: ${bitStringData[0]}")
            }
            let coordinateSize = (bitStringData.size - 1) / 2
            let x = bitStringData[1..coordinateSize + 1]
            let y = bitStringData[coordinateSize + 1..bitStringData.size]

            // 如果有私钥且调用方请求私钥参数，导出完整私钥参数
            if (includePrivateParameters) {
                if (let Some(priKey) <- _privateKey) {
                    let priBody = priKey.encodeToDer().body
                    let priReader = AsnReader(priBody, AsnEncodingRules.DER)
                    let priSeq = priReader.readSequence()
                    let _ = priSeq.readIntegerBytes() // version
                    let dBytes = priSeq.readOctetString() // privateKey

                    return ECParameters(curve, ECPoint(x, y), d: Some(dBytes))
                }
            }

            return ECParameters(curve, ECPoint(x, y))
        }
        throw IllegalArgumentException("Cannot export ECDsa JWK: public key is not available")
    }

    /**
     * @brief 从 PEM 文本加载 ECDSA 公钥。
     * @param pem PEM 格式的公钥文本。
     * @return 创建出的 ECDSA 安全密钥。
     */
    public static func fromPublicKeyPem(pem: String): ECDsaSecurityKey {
        ECDsaSecurityKey(publicKey: ECDSAPublicKey.decodeFromPem(pem))
    }

    /**
     * @brief 从 PEM 文本加载 ECDSA 私钥。
     * @param pem PEM 格式的私钥文本。
     * @return 创建出的 ECDSA 安全密钥。
     */
    public static func fromPrivateKeyPem(pem: String): ECDsaSecurityKey {
        ECDsaSecurityKey(privateKey: ECDSAPrivateKey.decodeFromPem(pem))
    }

    /**
     * @brief 从 PEM 文件加载 ECDSA 公钥。
     * @param path 公钥 PEM 文件路径。
     * @return 创建出的 ECDSA 安全密钥。
     */
    public static func fromPublicKeyPemFile(path: String): ECDsaSecurityKey {
        fromPublicKeyPem(readPemFile(path))
    }

    /**
     * @brief 从 PEM 文件加载 ECDSA 私钥。
     * @param path 私钥 PEM 文件路径。
     * @return 创建出的 ECDSA 安全密钥。
     */
    public static func fromPrivateKeyPemFile(path: String): ECDsaSecurityKey {
        fromPrivateKeyPem(readPemFile(path))
    }

    /**
     * @brief 同时从 PEM 文件加载 ECDSA 公钥和私钥。
     * @param publicKeyPath 公钥 PEM 文件路径。
     * @param privateKeyPath 私钥 PEM 文件路径。
     * @return 创建出的完整 ECDSA 密钥对。
     */
    public static func fromPemFiles(publicKeyPath: String, privateKeyPath: String): ECDsaSecurityKey {
        ECDsaSecurityKey(
            publicKey: ECDSAPublicKey.decodeFromPem(readPemFile(publicKeyPath)),
            privateKey: ECDSAPrivateKey.decodeFromPem(readPemFile(privateKeyPath))
        )
    }

    private static func readPemFile(path: String): String {
        try (f = File(path, OpenMode.Read)) {
            return String.fromUtf8(readToEnd(f))
        }
        return ""
    }

    private static func parametersFromJwk(jsonWebKey: JsonWebKey): ECParameters {
        let curve = ECDsaAdapter.getNamedECCurve(
            jsonWebKey.crv.getOrThrow {IllegalArgumentException("EC JWK missing required field 'crv'")})
        let x = Base64UrlEncoder
            .decodeBytes(jsonWebKey.x.getOrThrow {IllegalArgumentException("EC JWK missing required field 'x'")})
            .getOrThrow {IllegalArgumentException("EC JWK field 'x' is not valid Base64Url")}
        let y = Base64UrlEncoder
            .decodeBytes(jsonWebKey.y.getOrThrow {IllegalArgumentException("EC JWK missing required field 'y'")})
            .getOrThrow {IllegalArgumentException("EC JWK field 'y' is not valid Base64Url")}
        let d: ?Array<Byte> = if (jsonWebKey.hasPrivateKey) {
            Base64UrlEncoder.decodeBytes(jsonWebKey.d.getOrThrow()).getOrThrow()
        } else {
            None
        }
        return ECParameters(curve, ECPoint(x, y), d: d)
    }

    // 构造未压缩点格式缓冲区: 0x04 || x || y
    private static func buildPointBuffer(x: Array<Byte>, y: Array<Byte>): Array<Byte> {
        let buffer = Array<Byte>(x.size + y.size + 1, repeat: 0)
        buffer[0] = 0x04
        x.copyTo(buffer[1..])
        y.copyTo(buffer[x.size + 1..])
        return buffer
    }

    // 构建公钥 DER: SEQUENCE { SEQUENCE { OID ecPublicKey, OID curve }, BIT STRING { 0x04 || x || y } }
    private static func buildPublicKey(params: ECParameters): ECDSAPublicKey {
        let writer = AsnWriter(AsnEncodingRules.DER)
        try (s = writer.pushSequence()) {
            try (s = writer.pushSequence()) {
                writer.writeObjectIdentifier("1.2.840.10045.2.1")
                writer.writeObjectIdentifier(params.curve)
            }
            writer.writeBitString(buildPointBuffer(params.q.x, params.q.y))
        }
        return ECDSAPublicKey.decodeDer(DerBlob(writer.encode()))
    }

    // 构建私钥 DER: SEQUENCE { version=1, OCTET STRING d, [0] { OID curve }, [1] { BIT STRING pubKey } }
    private static func buildPrivateKey(params: ECParameters, d: Array<Byte>): ECDSAPrivateKey {
        let writer = AsnWriter(AsnEncodingRules.DER)
        try (s = writer.pushSequence()) {
            writer.writeInteger(1)
            writer.writeOctetString(d)
            try (s = writer.pushSequence(tag: Asn1Tag(TagClass.ContextSpecific, 0))) {
                writer.writeObjectIdentifier(params.curve)
            }
            try (s = writer.pushSequence(tag: Asn1Tag(TagClass.ContextSpecific, 1))) {
                writer.writeBitString(buildPointBuffer(params.q.x, params.q.y))
            }
        }
        return ECDSAPrivateKey.decodeDer(DerBlob(writer.encode()))
    }
}

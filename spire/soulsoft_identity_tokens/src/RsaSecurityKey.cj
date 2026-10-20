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
 * @brief 表示 RSA 安全密钥。
 */
public class RsaSecurityKey <: AsymmetricSecurityKey {
    private let _publicKey: ?RSAPublicKey
    private let _privateKey: ?RSAPrivateKey

    /**
     * @brief 使用公钥和私钥创建 RSA 安全密钥。
     * @param publicKey 可选的 RSA 公钥。
     * @param privateKey 可选的 RSA 私钥。
     */
    public init(publicKey!: ?RSAPublicKey = None, privateKey!: ?RSAPrivateKey = None) {
        _publicKey = publicKey
        _privateKey = privateKey
    }

    /**
     * @brief 从 JWK 创建 RSA 安全密钥。
     * @param jsonWebKey 包含 RSA 密钥材料的 JWK。
     * @throws IllegalArgumentException 当必填字段缺失或编码无效时抛出。
     */
    public init(jsonWebKey: JsonWebKey) {
        this(parametersFromJwk(jsonWebKey))
    }

    /**
     * @brief 从 RSA 参数创建安全密钥。
     * @param params RSA 密钥参数。
     */
    public init(params: RsaParameters) {
        _publicKey = RsaSecurityKey.buildPublicKey(params)
        _privateKey = RsaSecurityKey.buildPrivateKey(params)
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
     * @brief 获取 RSA 公钥。
     * @return 当前关联的公钥；不存在时返回 `None`。
     */
    public prop publicKey: ?RSAPublicKey {
        get() {
            _publicKey
        }
    }

    /**
     * @brief 获取 RSA 私钥。
     * @return 当前关联的私钥；不存在时返回 `None`。
     */
    public prop privateKey: ?RSAPrivateKey {
        get() {
            _privateKey
        }
    }

    private func resolvePublicKey(): ?RSAPublicKey {
        // 优先返回 _publicKey，私钥场景通过 RSAPublicKey(pri) 派生，均不存在时返回 None
        if (let Some(k) <- _publicKey) {
            return k
        }
        if (let Some(k) <- _privateKey) {
            return RSAPublicKey(k)
        }
        return None
    }

    /**
     * @brief 获取 RSA 密钥位长度。
     * @return 根据模数推导出的位长度；无法推导时返回 `0`。
     * @throws IllegalStateException 当 DER 解析失败时抛出。
     */
    public prop keySize: Int64 {
        get() {
            if (let Some(pubKey) <- resolvePublicKey()) {
                try {
                    let (modulus, _) = RsaSecurityKey.parsePublicKeyComponents(pubKey)
                    return modulus.size * 8
                } catch (e: Exception) {
                    throw IllegalStateException("Failed to parse RSA key size from DER: ${e.message}")
                }
            }
            return 0
        }
    }

    /**
     * @brief 导出 RSA 密钥参数。
     * @param includePrivateParameters 是否同时导出私钥参数。
     * @return 导出的 RSA 密钥参数。
     * @throws IllegalArgumentException 当既没有公钥也没有私钥时抛出。
     */
    public func exportParameters(includePrivateParameters: Bool): RsaParameters {
        let pubKey: RSAPublicKey = resolvePublicKey().getOrThrow {
            IllegalArgumentException("Cannot export RSA JWK: neither public nor private key is available")
        }

        let (modulus, e) = RsaSecurityKey.parsePublicKeyComponents(pubKey)

        // 如果有私钥且调用方请求私钥参数，导出完整私钥参数
        if (includePrivateParameters) {
            if (let Some(priKey) <- _privateKey) {
                let priBytes = priKey.encodeToDer().body
                let priReader = AsnReader(priBytes, AsnEncodingRules.DER)
                let priSeq = priReader.readSequence()
                let _ = priSeq.readIntegerBytes() // version
                let _ = priSeq.readIntegerBytes() // modulus（仅推进游标，公钥参数已从 pubKey 导出）
                let _ = priSeq.readIntegerBytes() // publicExponent（同上）
                let d = priSeq.readIntegerBytes() // privateExponent
                let p = priSeq.readIntegerBytes() // prime1
                let q = priSeq.readIntegerBytes() // prime2
                let dp = priSeq.readIntegerBytes() // exponent1
                let dq = priSeq.readIntegerBytes() // exponent2
                let inverseQ = priSeq.readIntegerBytes() // coefficient

                return RsaParameters(
                    modulus: modulus,
                    exponent: e,
                    d: Some(RsaSecurityKey.stripDerPadding(d)),
                    p: Some(RsaSecurityKey.stripDerPadding(p)),
                    q: Some(RsaSecurityKey.stripDerPadding(q)),
                    dp: Some(RsaSecurityKey.stripDerPadding(dp)),
                    dq: Some(RsaSecurityKey.stripDerPadding(dq)),
                    inverseQ: Some(RsaSecurityKey.stripDerPadding(inverseQ))
                )
            }
        }

        return RsaParameters(modulus: modulus, exponent: e)
    }

    /**
     * @brief 从 PEM 文本加载 RSA 公钥。
     * @param pem PEM 格式的公钥文本。
     * @return 创建出的 RSA 安全密钥。
     */
    public static func fromPublicKeyPem(pem: String): RsaSecurityKey {
        RsaSecurityKey(publicKey: RSAPublicKey.decodeFromPem(pem))
    }

    /**
     * @brief 从 PEM 文本加载 RSA 私钥。
     * @param pem PEM 格式的私钥文本。
     * @return 创建出的 RSA 安全密钥。
     */
    public static func fromPrivateKeyPem(pem: String): RsaSecurityKey {
        RsaSecurityKey(privateKey: RSAPrivateKey.decodeFromPem(pem))
    }

    /**
     * @brief 从 PEM 文件加载 RSA 公钥。
     * @param path 公钥 PEM 文件路径。
     * @return 创建出的 RSA 安全密钥。
     */
    public static func fromPublicKeyPemFile(path: String): RsaSecurityKey {
        fromPublicKeyPem(readPemFile(path))
    }

    /**
     * @brief 从 PEM 文件加载 RSA 私钥。
     * @param path 私钥 PEM 文件路径。
     * @return 创建出的 RSA 安全密钥。
     */
    public static func fromPrivateKeyPemFile(path: String): RsaSecurityKey {
        fromPrivateKeyPem(readPemFile(path))
    }

    /**
     * @brief 同时从 PEM 文件加载 RSA 公钥和私钥。
     * @param publicKeyPath 公钥 PEM 文件路径。
     * @param privateKeyPath 私钥 PEM 文件路径。
     * @return 创建出的完整 RSA 密钥对。
     */
    public static func fromPemFiles(publicKeyPath: String, privateKeyPath: String): RsaSecurityKey {
        RsaSecurityKey(
            publicKey: RSAPublicKey.decodeFromPem(readPemFile(publicKeyPath)),
            privateKey: RSAPrivateKey.decodeFromPem(readPemFile(privateKeyPath))
        )
    }

    // DER INTEGER 正整数最高位为 1 时需添加 0x00 符号填充位，仅在必要时添加
    private static func addDerPadding(bytes: Array<Byte>): Array<Byte> {
        if (bytes.size > 0 && bytes[0] >= 0x80u8) {
            let buffer = Array<Byte>(bytes.size + 1, repeat: 0)
            bytes.copyTo(buffer[1..])
            return buffer
        }
        return bytes
    }

    // 移除 DER INTEGER 符号填充位（0x00 前缀），与 addDerPadding 互逆
    // DER INTEGER 首字节 0x00 是符号填充位，仅当最高有效位为 1 时存在；
    // 并非所有整数都有此前缀，无条件截断会损坏密钥材料。
    private static func stripDerPadding(bytes: Array<Byte>): Array<Byte> {
        if (bytes.size > 0 && bytes[0] == 0x00u8) {
            return bytes[1..]
        }
        return bytes
    }

    // 解析公钥 DER，返回已去除符号填充位的 (modulus, exponent)
    private static func parsePublicKeyComponents(pubKey: RSAPublicKey): (Array<Byte>, Array<Byte>) {
        let bytes = pubKey.encodeToDer().body
        let reader = AsnReader(bytes, AsnEncodingRules.DER)
        let seq1 = reader.readSequence()
        let _ = seq1.readSequence()
        let (bitBytes, _) = seq1.readBitString()
        let reader2 = AsnReader(bitBytes, AsnEncodingRules.DER)
        let seq3 = reader2.readSequence()
        return (stripDerPadding(seq3.readIntegerBytes()), seq3.readIntegerBytes())
    }

    // 构建公钥 DER: SEQUENCE { SEQUENCE { OID rsaEncryption, NULL }, BIT STRING { SEQUENCE { INTEGER n, INTEGER e } } }
    private static func buildPublicKey(params: RsaParameters): RSAPublicKey {
        let writer = AsnWriter(AsnEncodingRules.DER)
        try (s = writer.pushSequence()) {
            try (s = writer.pushSequence()) {
                writer.writeObjectIdentifier("1.2.840.113549.1.1.1")
                writer.writeNull()
            }
            let innerWriter = AsnWriter(AsnEncodingRules.DER)
            try (s = innerWriter.pushSequence()) {
                innerWriter.writeIntegerUnsigned(params.modulus)
                innerWriter.writeIntegerUnsigned(params.exponent)
            }
            writer.writeBitString(innerWriter.encode())
        }
        return RSAPublicKey.decodeDer(DerBlob(writer.encode()))
    }

    // 构建私钥 DER: SEQUENCE { version=0, n, e, d, p, q, dp, dq, qi }
    private static func buildPrivateKey(params: RsaParameters): ?RSAPrivateKey {
        if (let Some(d) <- params.d) {
            let writer = AsnWriter(AsnEncodingRules.DER)
            try (s = writer.pushSequence()) {
                writer.writeInteger(0) // version
                writer.writeIntegerUnsigned(params.modulus)
                writer.writeIntegerUnsigned(params.exponent)
                writer.writeIntegerUnsigned(d)
                writer.writeIntegerUnsigned(params.p.getOrThrow())
                writer.writeIntegerUnsigned(params.q.getOrThrow())
                writer.writeIntegerUnsigned(params.dp.getOrThrow())
                writer.writeIntegerUnsigned(params.dq.getOrThrow())
                writer.writeIntegerUnsigned(params.inverseQ.getOrThrow())
            }
            return RSAPrivateKey.decodeDer(DerBlob(writer.encode()))
        }
        return None
    }

    private static func parametersFromJwk(jsonWebKey: JsonWebKey): RsaParameters {
        let n = Base64UrlEncoder
            .decodeBytes(jsonWebKey.n.getOrThrow {IllegalArgumentException("RSA JWK missing required field 'n'")})
            .getOrThrow {IllegalArgumentException("RSA JWK field 'n' is not valid Base64Url")}
        let e = Base64UrlEncoder
            .decodeBytes(jsonWebKey.e.getOrThrow {IllegalArgumentException("RSA JWK missing required field 'e'")})
            .getOrThrow {IllegalArgumentException("RSA JWK field 'e' is not valid Base64Url")}
        if (jsonWebKey.hasPrivateKey) {
            let d = Base64UrlEncoder.decodeBytes(jsonWebKey.d.getOrThrow()).getOrThrow()
            let p = Base64UrlEncoder.decodeBytes(jsonWebKey.p.getOrThrow()).getOrThrow()
            let q = Base64UrlEncoder.decodeBytes(jsonWebKey.q.getOrThrow()).getOrThrow()
            let dp = Base64UrlEncoder.decodeBytes(jsonWebKey.dp.getOrThrow()).getOrThrow()
            let dq = Base64UrlEncoder.decodeBytes(jsonWebKey.dq.getOrThrow()).getOrThrow()
            let qi = Base64UrlEncoder.decodeBytes(jsonWebKey.qi.getOrThrow()).getOrThrow()
            return RsaParameters(
                modulus: n,
                exponent: e,
                d: Some(d),
                p: Some(p),
                q: Some(q),
                dp: Some(dp),
                dq: Some(dq),
                inverseQ: Some(qi)
            )
        }
        return RsaParameters(modulus: n, exponent: e)
    }

    private static func readPemFile(path: String): String {
        try (f = File(path, OpenMode.Read)) {
            return String.fromUtf8(readToEnd(f))
        }
        return String.empty
    }
}

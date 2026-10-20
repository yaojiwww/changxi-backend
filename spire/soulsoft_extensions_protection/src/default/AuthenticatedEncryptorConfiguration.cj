// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_protection.default

import std.crypto.digest.*
import stdx.crypto.digest.*
import stdx.crypto.crypto.*

/**
 * @brief 表示认证加密器的算法配置。
 */
public class AuthenticatedEncryptorConfiguration <: AlgorithmConfiguration {
    /**
     * @brief 指定使用的消息认证算法。
     */
    public var validationAlgorithm: ValidationAlgorithm

    /**
     * @brief 指定使用的加密算法。
     */
    public var encryptionAlgorithm: EncryptionAlgorithm

    /**
     * @brief 创建认证加密器算法配置。
     * @param validationAlgorithm 消息认证算法。
     * @param encryptionAlgorithm 加密算法。
     */
    public init(validationAlgorithm!: ValidationAlgorithm = HMACSHA256,
        encryptionAlgorithm!: EncryptionAlgorithm = SM4_128_CBC) {
        this.validationAlgorithm = validationAlgorithm
        this.encryptionAlgorithm = encryptionAlgorithm
    }

    /**
     * @brief 创建新的认证加密器描述符。
     * @return 返回新创建的认证加密器描述符。
     */
    public func createNewDescriptor(): IAuthenticatedEncryptorDescriptor {
        return AuthenticatedEncryptorDescriptor(Secret.create(), this)
    }

    internal prop encryptionAlgorithmKeySize: Int64 {
        get() {
            match (encryptionAlgorithm) {
                case SM4_128_CBC => 16
            }
        }
    }

    internal prop encryptionAlgorithmBlockSize: Int64 {
        get() {
            match (encryptionAlgorithm) {
                case SM4_128_CBC => 16
            }
        }
    }

    internal prop validationAlgorithmKeySize: Int64 {
        get() {
            match (validationAlgorithm) {
                case HMACSHA256 => 256 / 8
                case HMACSHA512 => 512 / 8
            }
        }
    }

    internal prop validationAlgorithmDigestSize: Int64 {
        get() {
            match (validationAlgorithm) {
                case HMACSHA256 => 256 / 8
                case HMACSHA512 => 512 / 8
            }
        }
    }

    internal func digest(key: Array<Byte>, input: Array<Byte>) {
        return match (validationAlgorithm) {
            case HMACSHA256 => digest(HMAC(key, HashType.SHA256), input)
            case HMACSHA512 => digest(HMAC(key, HashType.SHA512), input)
        }
    }

    internal func encrypt(key: Array<Byte>, iv: Array<Byte>, input: Array<Byte>) {
        return match (encryptionAlgorithm) {
            case SM4_128_CBC =>
                let sm4 = SM4(OperationMode.CBC, key, iv: iv, paddingMode: PaddingMode.PKCS7Padding)
                sm4.encrypt(input)
        }
    }

    internal func decrypt(key: Array<Byte>, iv: Array<Byte>, input: Array<Byte>) {
        return match (encryptionAlgorithm) {
            case SM4_128_CBC =>
                let sm4 = SM4(OperationMode.CBC, key, iv: iv, paddingMode: PaddingMode.PKCS7Padding)
                sm4.decrypt(input)
        }
    }
}

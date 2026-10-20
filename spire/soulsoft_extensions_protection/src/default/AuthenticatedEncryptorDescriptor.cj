// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_protection.default

import std.reflect.*
import stdx.encoding.json.*

/**
 * @brief 表示认证加密器描述符实现。
 */
public class AuthenticatedEncryptorDescriptor <: IAuthenticatedEncryptorDescriptor {
    /**
     * @brief 保存认证加密器主密钥。
     */
    public let masterKey: ISecret

    /**
     * @brief 保存认证加密器算法配置。
     */
    public let configuration: AuthenticatedEncryptorConfiguration

    /**
     * @brief 创建一个认证加密器描述符。
     * @param masterKey 认证加密器主密钥。
     * @param configuration 认证加密器配置。
     */
    protected init(masterKey: ISecret, configuration: AuthenticatedEncryptorConfiguration) {
        this.masterKey = masterKey
        this.configuration = configuration
    }

    /**
     * @brief 导出当前描述符的 JSON 序列化结果。
     * @return 返回描述符序列化信息。
     */
    public func exportToJson(): JsonSerializedDescriptorInfo {
        let jsonObject = JsonObject()
        jsonObject.put("encryptionAlgorithm", JsonString(configuration.encryptionAlgorithm.toString()))
        jsonObject.put("validationAlgorithm", JsonString(configuration.validationAlgorithm.toString()))
        jsonObject.put("encryptionMasterKey", JsonString(masterKey.toString()))
        return JsonSerializedDescriptorInfo(jsonObject, TypeInfo.of<AuthenticatedEncryptorDescriptorDeserializer>())
    }
}

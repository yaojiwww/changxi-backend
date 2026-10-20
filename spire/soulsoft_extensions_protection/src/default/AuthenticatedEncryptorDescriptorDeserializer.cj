// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_protection.default

import stdx.encoding.json.*

/**
 * @brief 提供认证加密器描述符的 JSON 反序列化实现。
 */
public class AuthenticatedEncryptorDescriptorDeserializer <: IAuthenticatedEncryptorDescriptorDeserializer {
    /**
     * @brief 从 JSON 对象导入认证加密器描述符。
     * @param jsonValue 描述符对应的 JSON 对象。
     * @return 返回导入后的认证加密器描述符。
     */
    public func importFromJson(jsonValue: JsonObject): IAuthenticatedEncryptorDescriptor {
        let encryptionMasterKey = jsonValue["encryptionMasterKey"].asString().getValue()
        let encryptionAlgorithm = EncryptionAlgorithm.fromStr(jsonValue["encryptionAlgorithm"].asString().getValue())
        let validationAlgorithm = ValidationAlgorithm.fromStr(jsonValue["validationAlgorithm"].asString().getValue())
        let configuration = AuthenticatedEncryptorConfiguration(encryptionAlgorithm: encryptionAlgorithm, validationAlgorithm: validationAlgorithm)
        let secret = Secret.fromStr(encryptionMasterKey)
        return AuthenticatedEncryptorDescriptor(secret, configuration)
    }
}

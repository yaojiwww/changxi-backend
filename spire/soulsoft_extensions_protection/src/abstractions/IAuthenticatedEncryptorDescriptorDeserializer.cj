// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_protection.abstractions

import stdx.encoding.json.*

/**
 * @brief 定义认证加密器描述符反序列化接口。
 */
public interface IAuthenticatedEncryptorDescriptorDeserializer {
    /**
     * @brief 从 JSON 对象导入认证加密器描述符。
     * @param object 描述符对应的 JSON 对象。
     * @return 返回导入后的认证加密器描述符。
     */
    func importFromJson(object: JsonObject): IAuthenticatedEncryptorDescriptor
}

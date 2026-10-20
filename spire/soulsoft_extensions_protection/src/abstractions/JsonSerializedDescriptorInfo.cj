// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_protection.abstractions

import std.reflect.*
import stdx.encoding.json.*

/**
 * @brief 表示认证加密器描述符的 JSON 序列化结果。
 */
public class JsonSerializedDescriptorInfo {
    /**
     * @brief 创建描述符序列化结果实例。
     * @param jsonValue 描述符对应的 JSON 对象。
     * @param typeInfo 描述符类型信息。
     */
    public JsonSerializedDescriptorInfo(public let jsonValue: JsonObject, public let typeInfo: TypeInfo) {
    }
}

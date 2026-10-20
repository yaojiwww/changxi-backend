// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_web_openapi.models

import std.collection.*

/**
 * @brief 表示 OpenAPI 响应对象。
 */
public class OpenApiResponse <: IOpenApiSerializable {
    /**
     * @brief 表示响应描述。
     */
    public var description: String
    /**
     * @brief 表示响应内容映射。
     */
    public var content = HashMap<String, OpenApiMediaType>()

    /**
     * @brief 创建 OpenAPI 响应对象。
     * @param description 响应描述。
     */
    public init(description: String) {
        this.description = description
    }

    /**
     * @brief 按 OpenAPI V3 格式写出当前响应对象。
     * @param writer OpenAPI 写入器。
     */
    public func serializeAsV3(writer: IOpenApiWriter): Unit {
        writer.startObject()
        writer.writeName("description")
        writer.writeValue(description)
        if (!content.isEmpty()) {
            writer.writeName("content")
            writer.startObject()
            for ((key, value) in content) {
                writer.writeName(key)
                value.serializeAsV3(writer)
            }
            writer.endObject()
        }
        writer.endObject()
    }
}

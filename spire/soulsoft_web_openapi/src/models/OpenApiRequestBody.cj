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
 * @brief 表示 OpenAPI 请求体对象。
 */
public class OpenApiRequestBody <: IOpenApiSerializable {
    /**
     * @brief 表示请求体是否必填。
     */
    public var required: Bool = false
    /**
     * @brief 表示请求体描述。
     */
    public var description: ?String = None
    /**
     * @brief 表示请求体内容映射。
     */
    public var content = HashMap<String, OpenApiMediaType>()

    /**
     * @brief 创建 OpenAPI 请求体对象。
     * @param required 请求体是否必填。
     * @param description 请求体描述。
     */
    public init(required!: Bool = false, description!: ?String = None) {
        this.required = required
        this.description = description
    }

    /**
     * @brief 按 OpenAPI V3 格式写出当前请求体对象。
     * @param writer OpenAPI 写入器。
     */
    public func serializeAsV3(writer: IOpenApiWriter): Unit {
        writer.startObject()
        if (let Some(desc) <- description) {
            writer.writeName("description")
            writer.writeValue(desc)
        }
        if (!content.isEmpty()) {
            writer.writeName("content")
            writer.startObject()
            for ((key, value) in content) {
                writer.writeName(key)
                value.serializeAsV3(writer)
            }
            writer.endObject()
        }
        if (required) {
            writer.writeName("required")
            writer.writeValue(true)
        }
        writer.endObject()
    }
}

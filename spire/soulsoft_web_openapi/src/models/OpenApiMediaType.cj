// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_web_openapi.models

/**
 * @brief 表示 OpenAPI 媒体类型对象。
 */
public class OpenApiMediaType <: IOpenApiSerializable {
    /**
     * @brief 表示媒体类型对应的架构。
     */
    public var schema: ?OpenApiSchema = None
  
    /**
     * @brief 创建 OpenAPI 媒体类型实例。
     * @param schema 媒体类型对应的架构。
     */
    public init(schema: ?OpenApiSchema) {
        this.schema = schema
    }

    /**
     * @brief 按 OpenAPI V3 格式写出当前媒体类型对象。
     * @param writer OpenAPI 写入器。
     */
    public func serializeAsV3(writer: IOpenApiWriter): Unit {
        writer.startObject()
        if (let Some(value) <- schema) {
            writer.writeName("schema")
            value.serializeAsV3(writer)
        }
        writer.endObject()
    }
}

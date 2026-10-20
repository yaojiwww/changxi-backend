// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_web_openapi.models

/**
 * @brief 表示 OpenAPI 参数对象。
 */
public class OpenApiParameter <: IOpenApiSerializable {
    /**
     * @brief 表示参数名称。
     */
    public var name: ?String
    /**
     * @brief 表示参数是否必填。
     */
    public var required: ?Bool
    /**
     * @brief 表示参数是否已弃用。
     */
    public var deprecated: ?Bool
    /**
     * @brief 表示参数描述。
     */
    public var description: ?String
    /**
     * @brief 表示参数架构。
     */
    public var schema: ?OpenApiSchema = None
    /**
     * @brief 表示参数位置。
     */
    public var location: ?ParameterLocation = None

    /**
     * @brief 创建 OpenAPI 参数对象。
     * @param name 参数名称。
     * @param location 参数位置。
     * @param description 参数描述。
     * @param required 参数是否必填。
     * @param deprecated 参数是否已弃用。
     * @param schema 参数架构。
     */
    public init(name!: ?String, location!: ?ParameterLocation = None, description!: ?String = None,
        required!: ?Bool = None, deprecated!: ?Bool = None, schema!: ?OpenApiSchema = None) {
        this.name = name
        this.schema = schema
        this.location = location
        this.required = required
        this.deprecated = deprecated
        this.description = description
    }

    /**
     * @brief 按 OpenAPI V3 格式写出当前参数对象。
     * @param writer OpenAPI 写入器。
     */
    public func serializeAsV3(writer: IOpenApiWriter): Unit {
        writer.startObject()
        if (let Some(value) <- name) {
            writer.writeName("name")
            writer.writeValue(value)
        }
        if (let Some(loc) <- location) {
            writer.writeName("in")
            writer.writeValue(loc.toString())
        }
        if (let Some(desc) <- description) {
            writer.writeName("description")
            writer.writeValue(desc)
        }
        if (let Some(req) <- required) {
            writer.writeName("required")
            writer.writeValue(req)
        }
        if (let Some(dep) <- deprecated) {
            writer.writeName("deprecated")
            writer.writeValue(dep)
        }
        if (let Some(s) <- schema) {
            writer.writeName("schema")
            s.serializeAsV3(writer)
        }
        writer.endObject()
    }
}

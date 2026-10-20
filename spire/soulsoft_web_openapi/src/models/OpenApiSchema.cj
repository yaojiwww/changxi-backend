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
 * @brief 表示 OpenAPI 架构对象。
 */
public class OpenApiSchema <: IOpenApiSerializable {
    /**
     * @brief 表示架构标题。
     */
    public var title: ?String = None
    /**
     * @brief 表示架构是否可为空。
     */
    public var nullable: ?Bool = None
    /**
     * @brief 表示架构类型。
     */
    public var `type`: ?String = None
    /**
     * @brief 表示数组元素架构。
     */
    public var items: ?OpenApiSchema = None
    /**
     * @brief 表示架构格式。
     */
    public var format: ?String = None
    /**
     * @brief 表示架构描述。
     */
    public var description: ?String = None
    /**
     * @brief 表示字符串枚举候选值。
     */
    public var `enum` = ArrayList<String>()
    /**
     * @brief 表示架构引用。
     */
    public var reference: ?OpenApiReference = None
    /**
     * @brief 表示对象属性集合。
     */
    public var properties = HashMap<String, OpenApiSchema>()
    /**
     * @brief 表示 allOf 组合架构。
     */
    public var allOf = ArrayList<OpenApiSchema>()
    /**
     * @brief 表示 oneOf 组合架构。
     */
    public var oneOf = ArrayList<OpenApiSchema>()
    /**
     * @brief 表示是否允许附加属性。
     */
    public var additionalProperties: ?Bool = None
    /**
     * @brief 表示附加属性的值架构。
     */
    public var additionalPropertiesSchema: ?OpenApiSchema = None

    /**
     * @brief 创建 OpenAPI 架构对象。
     * @param title 架构标题。
     * @param nullable 架构是否可为空。
     * @param `type` 架构类型。
     * @param items 数组元素架构。
     * @param format 架构格式。
     * @param reference 架构引用。
     * @param description 架构描述。
     */
    public init(title!: ?String = None, nullable!: ?Bool = None, `type`!: ?String = None, items!: ?OpenApiSchema = None,
        format!: ?String = None, reference!: ?OpenApiReference = None, description!: ?String = None) {
        this.title = title
        this.format = format
        this.`type` = `type`
        this.items = items
        this.nullable = nullable
        this.reference = reference
        this.description = description
    }

    /**
     * @brief 按 OpenAPI V3 格式写出当前架构对象。
     * @param writer OpenAPI 写入器。
     */
    public func serializeAsV3(writer: IOpenApiWriter): Unit {
        if (let Some(reference) <- reference) {
            reference.serializeAsV3(writer)
        } else {
            serializeAsV3WithoutReference(writer)
        }
    }

    /**
     * @brief 判断当前架构是否允许 `null` 值。
     * @return 允许 `null` 时返回 `true`。
     */
    public func allowsNull(): Bool {
        if (nullable ?? false) {
            return true
        }
        for (schema in oneOf) {
            if (schema.`type` == "null") {
                return true
            }
        }
        for (schema in allOf) {
            if (schema.allowsNull()) {
                return true
            }
        }
        return false
    }

    private func serializeAsV3WithoutReference(writer: IOpenApiWriter) {
        writer.startObject()
        if (let Some(value) <- title) {
            writer.writeName("title")
            writer.writeValue(value)
        }
        if (let Some(value) <- `type`) {
            writer.writeName("type")
            writer.writeValue(value)
        }
        if (let Some(value) <- items) {
            writer.writeName("items")
            value.serializeAsV3(writer)
        }
        if (let Some(value) <- nullable && value) {
            writer.writeName("nullable")
            writer.writeValue(value)
        }
        if (let Some(value) <- format) {
            writer.writeName("format")
            writer.writeValue(value)
        }
        if (let Some(value) <- description) {
            writer.writeName("description")
            writer.writeValue(value)
        }
        if (!`enum`.isEmpty()) {
            writer.writeName("enum")
            writer.startArray()
            for (value in `enum`) {
                writer.writeValue(value)
            }
            writer.endArray()
        }
        if (!properties.isEmpty()) {
            writer.writeName("properties")
            writer.startObject()
            for ((key, value) in properties) {
                writer.writeName(key)
                value.serializeAsV3(writer)
            }
            writer.endObject()
        }
        if (!allOf.isEmpty()) {
            writer.writeName("allOf")
            writer.startArray()
            for (schema in allOf) {
                schema.serializeAsV3(writer)
            }
            writer.endArray()
        }
        if (!oneOf.isEmpty()) {
            writer.writeName("oneOf")
            writer.startArray()
            for (schema in oneOf) {
                schema.serializeAsV3(writer)
            }
            writer.endArray()
        }
        if (let Some(value) <- additionalPropertiesSchema) {
            writer.writeName("additionalProperties")
            value.serializeAsV3(writer)
        } else if (let Some(value) <- additionalProperties) {
            writer.writeName("additionalProperties")
            writer.writeValue(value)
        }
        writer.endObject()
    }
}

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_web_openapi.models

/**
 * @brief 表示 OpenAPI 基本信息。
 */
public class OpenApiInfo <: IOpenApiSerializable {
    /**
     * @brief 表示文档标题。
     */
    public var title: ?String = None
    /**
     * @brief 表示文档描述。
     */
    public var description: ?String = None
    /**
     * @brief 表示文档版本。
     */
    public var version: ?String = None
    /**
     * @brief 表示联系人信息。
     */
    public var contact: ?OpenApiContact = None
    /**
     * @brief 表示许可证信息。
     */
    public var license: ?OpenApiLicense = None

    /**
     * @brief 创建 OpenAPI 基本信息实例。
     * @param title 文档标题。
     * @param version 文档版本。
     */
    public init(title!: String, version!: String) {
        this.title = title
        this.version = version
    }

    /**
     * @brief 按 OpenAPI V3 格式写出当前基本信息。
     * @param writer OpenAPI 写入器。
     */
    public func serializeAsV3(writer: IOpenApiWriter): Unit {
        writer.startObject()
        if (let Some(value) <- title) {
            writer.writeName("title")
            writer.writeValue(value)
        }
        if (let Some(value) <- description) {
            writer.writeName("description")
            writer.writeValue(value)
        }
        if (let Some(value) <- version) {
            writer.writeName("version")
            writer.writeValue(value)
        }
        if (let Some(value) <- contact) {
            writer.writeName("contact")
            value.serializeAsV3(writer)
        }
        if (let Some(value) <- license) {
            writer.writeName("license")
            value.serializeAsV3(writer)
        }
        writer.endObject()
    }
}

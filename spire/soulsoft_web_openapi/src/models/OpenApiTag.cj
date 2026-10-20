// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_web_openapi.models

/**
 * @brief 表示 OpenAPI 标签对象。
 */
public class OpenApiTag <: IOpenApiSerializable {
    /**
     * @brief 表示标签名称。
     */
    public var name: ?String = None
    /**
     * @brief 表示标签描述。
     */
    public var description: ?String = None
    /**
     * @brief 表示标签引用。
     */
    public var reference: ?OpenApiReference = None

    /**
     * @brief 创建 OpenAPI 标签对象。
     * @param name 标签名称。
     * @param reference 标签引用。
     * @param description 标签描述。
     */
    public init(name!: ?String = None, reference!: ?OpenApiReference = None, description!: ?String = None) {
        this.name = name
        this.reference = reference
        this.description = description
    }

    /**
     * @brief 按 OpenAPI V3 格式写出当前标签对象。
     * @param writer OpenAPI 写入器。
     */
    public func serializeAsV3(writer: IOpenApiWriter): Unit {
        if (let Some(reference) <- reference) {
            reference.serializeAsV3(writer)
            return
        }
        if (let Some(name) <- name) {
            writer.writeValue(name)
        }
    }
}

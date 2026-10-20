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
 * @brief 表示 OpenAPI 组件集合。
 */
public class OpenApiComponents <: IOpenApiSerializable {
    /**
     * @brief 表示组件中的架构集合。
     */
    public var schemas = HashMap<String, OpenApiSchema>()

    /**
     * @brief 创建 OpenAPI 组件实例。
     */
    public init() {
    }

    /**
     * @brief 按 OpenAPI V3 格式写出当前组件集合。
     * @param writer OpenAPI 写入器。
     */
    public func serializeAsV3(writer: IOpenApiWriter): Unit {
        writer.startObject()
        if (!schemas.isEmpty()) {
            writer.writeName("schemas")
            writer.startObject()
            for ((key, value) in schemas) {
                writer.writeName(key)
                value.serializeAsV3(writer)
            }
            writer.endObject()
        }
        writer.endObject()
    }
}

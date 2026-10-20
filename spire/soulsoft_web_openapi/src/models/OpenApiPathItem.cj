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
 * @brief 表示 OpenAPI 路径项对象。
 */
public class OpenApiPathItem <: IOpenApiSerializable {
    /**
     * @brief 表示路径项摘要。
     */
    public var summary: ?String = None
    /**
     * @brief 表示路径项描述。
     */
    public var description: ?String = None
    /**
     * @brief 表示当前路径项是否未解析引用。
     */
    public var unresolvedReference: Bool = false
    /**
     * @brief 表示路径项引用。
     */
    public var reference: ?OpenApiReference = None
    /**
     * @brief 表示路径项服务器集合。
     */
    public var servers = ArrayList<OpenApiServer>()
    /**
     * @brief 表示路径项参数集合。
     */
    public var parameters = ArrayList<OpenApiParameter>()
    /**
     * @brief 表示路径项操作集合。
     */
    public var operations = HashMap<OperationType, OpenApiOperation>()

    /**
     * @brief 创建 OpenAPI 路径项对象。
     */
    public init() {
    }

    /**
     * @brief 按 OpenAPI V3 格式写出当前路径项对象。
     * @param writer OpenAPI 写入器。
     */
    public func serializeAsV3(writer: IOpenApiWriter): Unit {
        writer.startObject()
        if (let Some(value) <- summary) {
            writer.writeName("summary")
            writer.writeValue(value)
        }
        if (let Some(value) <- description) {
            writer.writeName("description")
            writer.writeValue(value)
        }
        if (unresolvedReference) {
            writer.writeName("$ref")
            if (let Some(value) <- reference) {
                writer.writeValue(value.toReferenceString())
            }
        }
        if (!servers.isEmpty()) {
            writer.writeName("servers")
            writer.startArray()
            for (server in servers) {
                server.serializeAsV3(writer)
            }
            writer.endArray()
        }
        if (!parameters.isEmpty()) {
            writer.writeName("parameters")
            writer.startArray()
            for (param in parameters) {
                param.serializeAsV3(writer)
            }
            writer.endArray()
        }
        for ((key, value) in operations) {
            writer.writeName(key.toString())
            value.serializeAsV3(writer)
        }
        writer.endObject()
    }
}

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
 * @brief 表示 OpenAPI 操作对象。
 */
public class OpenApiOperation <: IOpenApiSerializable {
    /**
     * @brief 表示操作摘要。
     */
    public var summary: ?String = None
    /**
     * @brief 表示操作描述。
     */
    public var description: ?String = None
    /**
     * @brief 表示操作标识。
     */
    public var operationId: ?String = None
    /**
     * @brief 表示操作响应集合。
     */
    public var response = OpenApiResponses()
    /**
     * @brief 表示操作标签集合。
     */
    public var tags = ArrayList<OpenApiTag>()
    /**
     * @brief 表示操作服务器集合。
     */
    public var servers = ArrayList<OpenApiServer>()
    /**
     * @brief 表示操作请求体。
     */
    public var requestBody:? OpenApiRequestBody = None
    /**
     * @brief 表示操作参数集合。
     */
    public var parameters = ArrayList<OpenApiParameter>()
    /**
     * @brief 表示操作安全需求集合。
     */
    public var security = ArrayList<OpenApiSecurityRequirement>()

    /**
     * @brief 创建 OpenAPI 操作对象。
     */
    public init() {
    }

    /**
     * @brief 按 OpenAPI V3 格式写出当前操作对象。
     * @param writer OpenAPI 写入器。
     */
    public func serializeAsV3(writer: IOpenApiWriter): Unit {
        writer.startObject()
        if (!tags.isEmpty()) {
            writer.writeName("tags")
            writer.startArray()
            for (tag in tags) {
                tag.serializeAsV3(writer)
            }
            writer.endArray()
        }
        if (let Some(value) <- summary) {
            writer.writeName("summary")
            writer.writeValue(value)
        }
        if (let Some(value) <- description) {
            writer.writeName("description")
            writer.writeValue(value)
        }
        if (let Some(value) <- operationId) {
            writer.writeName("operationId")
            writer.writeValue(value)
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
        if (!security.isEmpty()) {
            writer.writeName("security")
            writer.startArray()
            for (sec in security) {
                sec.serializeAsV3(writer)
            }
            writer.endArray()
        }
        if (!response.isEmpty()) {
            writer.writeName("responses")
            response.serializeAsV3(writer)
        }
        if (let Some(requestBody) <- requestBody) {
            writer.writeName("requestBody")
            requestBody.serializeAsV3(writer)
        }
        writer.endObject()
    }
}

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
 * @brief 表示 OpenAPI 文档对象。
 */
public class OpenApiDocument <: IOpenApiSerializable {
    /**
     * @brief 表示 OpenAPI 版本号。
     */
    public var openapi: String = "3.0.3"
    /**
     * @brief 表示文档基本信息。
     */
    public var info: ?OpenApiInfo = None
    /**
     * @brief 表示路径集合。
     */
    public var paths: ?OpenApiPaths = None
    /**
     * @brief 表示组件集合。
     */
    public var components: ?OpenApiComponents = None
    /**
     * @brief 表示标签集合。
     */
    public var tags = ArrayList<OpenApiTag>()
    /**
     * @brief 表示服务器集合。
     */
    public var servers = ArrayList<OpenApiServer>()
    /**
     * @brief 表示安全需求集合。
     */
    public var securityRequirements = ArrayList<OpenApiSecurityRequirement>()

    /**
     * @brief 创建 OpenAPI 文档对象。
     */
    public init() {
    }

    /**
     * @brief 按 OpenAPI V3 格式写出当前文档对象。
     * @param writer OpenAPI 写入器。
     */
    public func serializeAsV3(writer: IOpenApiWriter): Unit {
        writer.startObject()
        writer.writeName("openapi")
        writer.writeValue(openapi)
        if (let Some(value) <- info) {
            writer.writeName("info")
            value.serializeAsV3(writer)
        }
        if (!servers.isEmpty()) {
            writer.writeName("servers")
            writer.startArray()
            for (server in servers) {
                server.serializeAsV3(writer)
            }
            writer.endArray()
        }
        if (let Some(value) <- paths) {
            writer.writeName("paths")
            value.serializeAsV3(writer)
        }
        if (let Some(value) <- components) {
            writer.writeName("components")
            value.serializeAsV3(writer)
        }
        if (!tags.isEmpty()) {
            writer.writeName("tags")
            writer.startArray()
            for (tag in tags) {
                tag.serializeAsV3(writer)
            }
            writer.endArray()
        }

        if (!securityRequirements.isEmpty()) {
            writer.writeName("security")
            writer.startArray()
            for (sec in securityRequirements) {
                sec.serializeAsV3(writer)
            }
            writer.endArray()
        }
        writer.endObject()
    }
}

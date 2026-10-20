// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_web_openapi.models

/**
 * @brief 表示 OpenAPI 联系人信息。
 */
public class OpenApiContact <: IOpenApiSerializable {
    /**
     * @brief 表示联系人名称。
     */
    public var name: ?String = None
    /**
     * @brief 表示联系人地址。
     */
    public var url: ?String = None
    /**
     * @brief 表示联系人邮箱。
     */
    public var email: ?String = None
    /**
     * @brief 创建 OpenAPI 联系人实例。
     */
    public init() {
    }

    /**
     * @brief 按 OpenAPI V3 格式写出当前联系人信息。
     * @param writer OpenAPI 写入器。
     */
    public func serializeAsV3(writer: IOpenApiWriter): Unit {
        writer.startObject()
        if (let Some(value) <- name) {
            writer.writeName("name")
            writer.writeValue(value)
        }

        if (let Some(value) <- url) {
            writer.writeName("url")
            writer.writeValue(value)
        }

        if (let Some(value) <- email) {
            writer.writeName("email")
            writer.writeValue(value)
        }

        writer.endObject()
    }
}

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_web_openapi.models

/**
 * @brief 表示 OpenAPI 安全需求对象。
 */
public class OpenApiSecurityRequirement <: IOpenApiSerializable {
    /**
     * @brief 创建 OpenAPI 安全需求对象。
     */
    public init() {
    }

    /**
     * @brief 按 OpenAPI V3 格式写出当前安全需求对象。
     * @param writer OpenAPI 写入器。
     */
    public func serializeAsV3(writer: IOpenApiWriter): Unit {}
}

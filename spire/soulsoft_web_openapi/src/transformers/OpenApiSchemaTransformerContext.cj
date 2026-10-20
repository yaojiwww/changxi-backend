// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_openapi.transformers

import soulsoft_extensions_injection.*

/**
 * @brief 提供架构转换器执行时的上下文信息。
 */
public class OpenApiSchemaTransformerContext {
    /**
     * @brief 当前正在生成的文档名称。
     */
    public let documentName: String
    /**
     * @brief 请求作用域的服务提供器。
     */
    public let services: IServiceProvider
    /**
     * @brief 当前架构在 components/schemas 中的键名（即类型限定名）。
     */
    public let schemaName: String

    /**
     * @brief 创建架构转换器上下文实例。
     * @param services 请求作用域的服务提供器。
     * @param documentName 当前正在生成的文档名称。
     * @param schemaName 当前架构在 components/schemas 中的键名。
     */
    public init(services: IServiceProvider, documentName: String, schemaName: String) {
        this.services = services
        this.documentName = documentName
        this.schemaName = schemaName
    }
}

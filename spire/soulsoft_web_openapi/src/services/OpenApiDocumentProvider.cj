// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_openapi.services

import std.collection.*
import soulsoft_web_openapi.models.*
import soulsoft_extensions_options.*
import soulsoft_extensions_injection.*
import soulsoft_web_openapi.transformers.*

/**
 * @brief 提供 OpenAPI 文档创建能力。
 */
protected class OpenApiDocumentProvider <: IDocumentProvider {
    private let _services: IServiceProvider
    private let _options: IOptionsMonitor<OpenApiOptions>

    /**
     * @brief 创建 OpenAPI 文档提供器实例。
     * @param services 服务提供器。
     * @param options OpenAPI 选项监视器。
     * @param provider OpenAPI 文档生成服务。
     */
    public init(services: IServiceProvider, options: IOptionsMonitor<OpenApiOptions>) {
        _services = services
        _options = options
    }

    /**
     * @brief 返回已注册的文档名称集合。
     * @return 当前可用的文档名称集合。
     */
    public func getDooucmentNames(): Collection<String> {
        _services.getAll<NamedService>() |> map {f => f.name} |> collectArray
    }

    /**
     * @brief 按名称创建 OpenAPI 文档并依次应用所有转换器。
     * @param documentName 要创建的文档名称。
     * @param services 请求作用域的服务提供器，传递给操作转换器上下文。
     * @return 经过转换器处理后的 OpenAPI 文档。
     */
    public func create(documentName: String, services: IServiceProvider): OpenApiDocument {
        let options = _options.get(documentName)
        let schemaService = OpenApiSchemaService(options, services, documentName)
        let parameterService = OpenApiParameterService(schemaService)
        let provider = ActivatorUtilities.createInstance<OpenApiDocumentService>(
            services,
            documentName,
            schemaService,
            parameterService
        )
        let document = provider.getOpenApiDocument(services)
        let context = OpenApiDocumentTransformerContext(services, documentName)
        for (transformer in options.documentTransformers) {
            transformer.transform(document, context)
        }
        return document
    }
}

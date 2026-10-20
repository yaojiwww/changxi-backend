// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_openapi

import soulsoft_web_http.*
import soulsoft_web_routing.*
import soulsoft_web_openapi.services.*
import soulsoft_extensions_injection.*
import soulsoft_web_openapi.infrastructure.*

/**
 * @brief 提供 OpenAPI 文档路由映射扩展。
 */
public interface OpenApiEndpointRouteBuilderExtension {
    /**
     * @brief 映射默认 OpenAPI 文档路由。
     * @return 当前端点路由构建器实例。
     */
    func mapOpenApi(): EndpointRouteBuilder {
        mapOpenApi(OpenApiConstants.DefaultOpenApiRoute)
    }
    /**
     * @brief 映射指定模式的 OpenAPI 文档路由。
     * @param pattern OpenAPI 文档路由模式。
     * @return 当前端点路由构建器实例。
     */
    func mapOpenApi(pattern: String): EndpointRouteBuilder
}

extend EndpointRouteBuilder <: OpenApiEndpointRouteBuilderExtension {
    /**
     * @brief 映射指定模式的 OpenAPI 文档路由。
     * @param pattern OpenAPI 文档路由模式。
     * @return 当前端点路由构建器实例。
     */
    public func mapOpenApi(pattern: String): EndpointRouteBuilder {
        verifyOpenApiServicesAreRegistered()
        this.mapGet(pattern) {
            context =>
                let documentName = context.request.routeValues.get("documentName").flatMap {f => f} ?? "v1"
                let documentFactory = context.services.getOrThrow<IDocumentProvider>()
                let document = documentFactory.create(documentName, context.services)
                context.response.contentType = "application/json; charset=utf-8"
                let writer = JsonOpenApiWriter(context.response.body)
                document.serializeAsV3(writer)
                writer.flush()
        }.withOpenApi(OpenApi(ignore: true))
        return this
    }

    private func verifyOpenApiServicesAreRegistered() {
        let callSiteFactory = this.services.getOrThrow<IServiceProviderIsService>()
        if (!callSiteFactory.isService<IDocumentProvider>()) {
            throw Exception(
                "Unable to find the required services. Please add all the required services by calling 'ServiceCollection.addOpenApi' inside the call to 'configureServices(...)' in the application startup code.")
        }
    }
}

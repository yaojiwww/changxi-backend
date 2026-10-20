// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_web_openapi

import soulsoft_web_http.*
import soulsoft_extensions_injection.*
import soulsoft_web_openapi.services.*

/**
 * @brief 提供 OpenAPI UI 中间件扩展。
 */
public interface OpenApiUIMiddlewareExtensions {
    /**
     * @brief 启用 OpenAPI UI 中间件。
     */
    func useOpenApiUI(): Unit
}

extend ApplicationBuilder <: OpenApiUIMiddlewareExtensions{
    /**
     * @brief 启用 OpenAPI UI 中间件。
     */
    public func useOpenApiUI(): Unit {
        verifyOpenApiServicesAreRegistered()
        use<OpenApiUIMiddleware>()
    }

    private func verifyOpenApiServicesAreRegistered() {
        let callSiteFactory = this.services.getOrThrow<IServiceProviderIsService>()
        if (!callSiteFactory.isService<IDocumentProvider>()) {
            throw Exception("Unable to find the required services. Please add all the required services by calling 'ServiceCollection.addOpenApi' inside the call to 'configureServices(...)' in the application startup code.")
        }
    }
}

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_openapi

import soulsoft_web_routing.*
import soulsoft_extensions_options.*
import soulsoft_web_openapi.services.*
import soulsoft_extensions_injection.*
import soulsoft_web_openapi.infrastructure.*

/**
 * @brief 提供 OpenAPI 服务注册扩展。
 */
public interface OpenApiServiceCollectionExtensions {
    /**
     * @brief 注册默认名称的 OpenAPI 服务。
     * @return 当前服务集合实例。
     */
    func addOpenApi(): ServiceCollection {
        addOpenApi(OpenApiConstants.DefaultDocumentName, {_ =>})
    }

    /**
     * @brief 注册指定文档名称的 OpenAPI 服务。
     * @param documentName OpenAPI 文档名称。
     * @return 当前服务集合实例。
     */
    func addOpenApi(documentName: String): ServiceCollection {
        addOpenApi(documentName, {_ =>})
    }

    /**
     * @brief 注册默认文档名称的 OpenAPI 服务并配置选项。
     * @param configureOptions 用于配置 OpenAPI 选项的回调。
     * @return 当前服务集合实例。
     */
    func addOpenApi(configureOptions: (OpenApiOptions) -> Unit): ServiceCollection {
        addOpenApi(OpenApiConstants.DefaultDocumentName, configureOptions)
    }

    /**
     * @brief 注册指定文档名称的 OpenAPI 服务并配置选项。
     * @param documentName OpenAPI 文档名称。
     * @param configureOptions 用于配置 OpenAPI 选项的回调。
     * @return 当前服务集合实例。
     */
    func addOpenApi(documentName: String, configureOptions: (OpenApiOptions) -> Unit): ServiceCollection
}

extend ServiceCollection <: OpenApiServiceCollectionExtensions {
    /**
     * @brief 注册指定文档名称的 OpenAPI 服务并配置选项。
     * @param documentName OpenAPI 文档名称。
     * @param configureOptions 用于配置 OpenAPI 选项的回调。
     * @return 当前服务集合实例。
     */
    public func addOpenApi(documentName: String, configureOptions: (OpenApiOptions) -> Unit): ServiceCollection {
        this.addRouting()
        this.configure<OpenApiOptions>(documentName, configureOptions)
        this.addSingleton(NamedService(documentName))
        this.addSingleton<IDocumentProvider, OpenApiDocumentProvider>()
        return this
    }
}

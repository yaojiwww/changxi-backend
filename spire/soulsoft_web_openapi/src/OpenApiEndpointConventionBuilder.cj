// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_web_openapi

import soulsoft_web_http.*

/**
 * @brief 提供 OpenAPI 端点约定扩展。
 */
public interface OpenApiEndpointConventionBuilderExtensions {
    /**
     * @brief 为端点附加 OpenAPI 元数据。
     * @param metadata 要附加的 OpenAPI 元数据。
     * @return 当前端点约定构建器实例。
     */
    func withOpenApi(metadata: OpenApi): EndpointConventionBuilder
}

extend EndpointConventionBuilder <: OpenApiEndpointConventionBuilderExtensions {
    /**
     * @brief 为端点附加 OpenAPI 元数据。
     * @param metadata 要附加的 OpenAPI 元数据。
     * @return 当前端点约定构建器实例。
     */
    public func withOpenApi(metadata: OpenApi): EndpointConventionBuilder {
        this.add {
            builder => builder.metadata.add(metadata)
        }
        return this
    }
}

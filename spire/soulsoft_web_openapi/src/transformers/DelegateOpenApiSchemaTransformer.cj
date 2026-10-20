// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_openapi.transformers

import soulsoft_web_openapi.models.*

/**
 * @brief 将委托包装为 IOpenApiSchemaTransformer 的适配器实现。
 */
protected class DelegateOpenApiSchemaTransformer <: IOpenApiSchemaTransformer {
    private let _transformer: (OpenApiSchema, OpenApiSchemaTransformerContext) -> Unit

    /**
     * @brief 创建委托架构转换器实例。
     * @param transformer 表示架构转换逻辑的委托。
     */
    public init(transformer: (OpenApiSchema, OpenApiSchemaTransformerContext) -> Unit) {
        _transformer = transformer
    }

    /**
     * @brief 调用委托转换指定的 OpenAPI 架构。
     * @param schema 要转换的 OpenAPI 架构。
     * @param context 架构转换器上下文。
     */
    public func transform(schema: OpenApiSchema, context: OpenApiSchemaTransformerContext): Unit {
        _transformer(schema, context)
    }
}

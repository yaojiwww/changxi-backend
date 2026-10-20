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
 * @brief 定义 OpenAPI 架构转换器接口。
 */
public interface IOpenApiSchemaTransformer {
    /**
     * @brief 转换指定的 OpenAPI 架构。
     * @param schema 要转换的 OpenAPI 架构。
     * @param context 架构转换器上下文。
     */
    func transform(schema: OpenApiSchema, context: OpenApiSchemaTransformerContext): Unit
}

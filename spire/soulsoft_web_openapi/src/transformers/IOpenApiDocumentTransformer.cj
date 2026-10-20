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
 * @brief 定义 OpenAPI 文档转换器接口。
 */
public interface IOpenApiDocumentTransformer {
    /**
     * @brief 转换指定的 OpenAPI 文档。
     * @param document 要转换的 OpenAPI 文档。
     * @param context 文档转换器上下文。
     */
    func transform(document: OpenApiDocument, context: OpenApiDocumentTransformerContext): Unit
}

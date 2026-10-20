// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_openapi.services

import soulsoft_web_openapi.models.*
import soulsoft_extensions_injection.*

/**
 * @brief 定义 OpenAPI 文档提供器接口。
 */
public interface IDocumentProvider {
    /**
     * @brief 返回已注册的文档名称集合。
     * @return 当前可用的文档名称集合。
     */
    func getDooucmentNames(): Collection<String>
    /**
     * @brief 按名称创建 OpenAPI 文档。
     * @param documentName 要创建的文档名称。
     * @return 生成后的 OpenAPI 文档。
     */
    func create(documentName: String, services: IServiceProvider): OpenApiDocument
}

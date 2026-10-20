// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_openapi.services

import std.reflect.*
import std.collection.*
import soulsoft_web_openapi.models.*
import soulsoft_web_openapi.transformers.*

/**
 * @brief 定义 OpenAPI 文档生成选项。
 */
public class OpenApiOptions {
    private let _documentTransformers = ArrayList<IOpenApiDocumentTransformer>()
    private let _operationTransformer = ArrayList<IOpenApiOperationTransformer>()
    private let _schemaTransformers = ArrayList<IOpenApiSchemaTransformer>()

    /**
     * @brief 确定指定类型在 components/schemas 中使用的引用 ID。
     * 返回 None 时该 Schema 始终内联，不生成 $ref。
     */
    public var createSchemaReferenceId: (TypeInfo) -> ?String = {typeInfo =>
        let name = typeInfo.name
        if (let Some(ltIdx) <- name.indexOf('<') && let Some(gtIdx) <- name.lastIndexOf('>') &&
            gtIdx > ltIdx) {
            let baseName = name[0..ltIdx]
            let argsStr = name[ltIdx + 1..gtIdx]
            let simpleName = if (let Some(dotIdx) <- argsStr.lastIndexOf('.')) {
                argsStr[dotIdx + 1..]
            } else {
                argsStr
            }
            "${baseName}Of${simpleName}"
        } else {
            name
        }
    }

    /**
     * @brief 返回当前文档转换器集合。
     * @return 已注册的文档转换器集合。
     */
    protected prop documentTransformers: List<IOpenApiDocumentTransformer> {
        get() {
            _documentTransformers
        }
    }

    /**
     * @brief 返回当前操作转换器集合。
     * @return 已注册的操作转换器集合。
     */
    protected prop operationTransformers: List<IOpenApiOperationTransformer> {
        get() {
            _operationTransformer
        }
    }

    /**
     * @brief 返回当前架构转换器集合。
     * @return 已注册的架构转换器集合。
     */
    protected prop schemaTransformers: List<IOpenApiSchemaTransformer> {
        get() {
            _schemaTransformers
        }
    }

    /**
     * @brief 添加文档转换器实例。
     * @param transformer 要添加的 OpenAPI 文档转换器。
     */
    public func addDocumentTransformer(transformer: IOpenApiDocumentTransformer): Unit {
        _documentTransformers.add(transformer)
    }

    /**
     * @brief 以委托形式添加文档转换器。
     * @param transformer 表示文档转换逻辑的委托。
     */
    public func addDocumentTransformer(transformer: (OpenApiDocument, OpenApiDocumentTransformerContext) -> Unit): Unit {
        _documentTransformers.add(DelegateOpenApiDocumentTransformer(transformer))
    }

    /**
     * @brief 添加操作转换器实例。
     * @param transformer 要添加的 OpenAPI 操作转换器。
     */
    public func addOperationTransformer(transformer: IOpenApiOperationTransformer): Unit {
        _operationTransformer.add(transformer)
    }

    /**
     * @brief 以委托形式添加操作转换器。
     * @param transformer 表示操作转换逻辑的委托。
     */
    public func addOperationTransformer(transformer: (OpenApiOperation, OpenApiOperationTransformerContext) -> Unit): Unit {
        _operationTransformer.add(DelegateOpenApiOperationTransformer(transformer))
    }

    /**
     * @brief 添加架构转换器实例。
     * @param transformer 要添加的 OpenAPI 架构转换器。
     */
    public func addSchemaTransformer(transformer: IOpenApiSchemaTransformer): Unit {
        _schemaTransformers.add(transformer)
    }

    /**
     * @brief 以委托形式添加架构转换器。
     * @param transformer 表示架构转换逻辑的委托。
     */
    public func addSchemaTransformer(transformer: (OpenApiSchema, OpenApiSchemaTransformerContext) -> Unit): Unit {
        _schemaTransformers.add(DelegateOpenApiSchemaTransformer(transformer))
    }
}

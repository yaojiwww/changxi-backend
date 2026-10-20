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
import soulsoft_web_mvc.*
import soulsoft_web_http.*
import soulsoft_web_routing.http.*
import soulsoft_web_mvc.utilities.*
import soulsoft_web_openapi.models.*
import soulsoft_extensions_options.*
import soulsoft_web_mvc.controllers.*
import soulsoft_extensions_injection.*
import soulsoft_web_openapi.metadata.*
import soulsoft_web_mvc.abstractions.*
import soulsoft_web_openapi.transformers.*
import soulsoft_web_openapi.infrastructure.*

/**
 * @brief 提供 OpenAPI 文档生成功能。
 */
protected class OpenApiDocumentService {
    private let _documentName: String
    private let _endpointSource: EndpointDataSource
    private let _openApiSchemaService: OpenApiSchemaService
    private let _openApiParameterService: OpenApiParameterService

    /**
     * @brief 创建 OpenAPI 文档生成服务实例。
     * @param endpointSource 终结点数据源。
     * @param openApiSchemaService OpenAPI Schema 服务。
     * @param openApiParameterService OpenAPI 参数服务。
     * @param documentName 当前正在生成的文档名称。
     */
    public init(
        documentName: String,
        endpointSource: EndpointDataSource,
        openApiSchemaService: OpenApiSchemaService,
        openApiParameterService: OpenApiParameterService
    ) {
        _documentName = documentName
        _endpointSource = endpointSource
        _openApiSchemaService = openApiSchemaService
        _openApiParameterService = openApiParameterService
    }

    /**
     * @brief 生成 OpenAPI 文档。
     * @param services 服务提供器，用于构建操作转换器上下文。
     * @return 生成后的 OpenAPI 文档。
     */
    public func getOpenApiDocument(services: IServiceProvider): OpenApiDocument {
        let document = OpenApiDocument()
        document.info = OpenApiInfo(title: "OpenApi | ${_documentName}", version: "1.0.0")
        document.paths = createOpenApiPaths(services)
        document.components = createOpenApiComponents()
        return document
    }

    private func createOpenApiPaths(services: IServiceProvider) {
        let paths = OpenApiPaths()
        let openApiOptions = services.getOrThrow<IOptionsMonitor<OpenApiOptions>>().get(_documentName)
        let operationTransformers = openApiOptions.operationTransformers
        for (endpoint in _endpointSource.endpoints |> filterMap {f => f as RouteEndpoint} where !isIgnore(endpoint)) {
            if (!isShouldInclude(endpoint)) {
                continue
            }

            // 构建用于显示的url路径
            let key = if (let Some(displayText) <- endpoint.routePattern.displayText) {
                "/${displayText.trimStart('/')}"
            } else {
                "/${endpoint.routePattern.rawText.trimStart('/')}"
            }

            let pathItem = if (paths.contains(key)) {
                paths[key]
            } else {
                let item = OpenApiPathItem()
                paths[key] = item
                item
            }

            // add operations
            if (let Some(metadata) <- endpoint.metadata.getMetadata<IHttpMethodMetadata>()) {
                for (httpMethod in metadata.httpMethods) {
                    let operationType = OperationType.parse(httpMethod)
                    let actionDescriptor = endpoint.metadata.getMetadata<ControllerActionDescriptor>()
                    let operation = createOpenApiOperation(endpoint, actionDescriptor)
                    let context = OpenApiOperationTransformerContext(services, _documentName, actionDescriptor)
                    for (transformer in operationTransformers) {
                        transformer.transform(operation, context)
                    }
                    pathItem.operations.add(operationType, operation)
                }
            }
        }
        return paths
    }

    private func isShouldInclude(endpoint: RouteEndpoint) {
        let groupNames = endpoint.metadata.getOrderedMetadata<IApiGroupNameProvider>() |> filterMap {f => f.groupName} |>
            collectArray
        if (groupNames.isEmpty() || groupNames.contains(_documentName)) {
            return true
        }
        return false
    }

    private func createOpenApiComponents() {
        let components = OpenApiComponents()
        let schemas = _openApiSchemaService.getSchemas()
        components.schemas = schemas
        return components
    }

    /*
    生成每个终结点的文档
     */
    private func createOpenApiOperation(endpoint: RouteEndpoint, actionDescriptor: ?ControllerActionDescriptor): OpenApiOperation {
        let operation = OpenApiOperation()

        // tags
        operation.tags.add(all: createOpenApiOperationTags(endpoint, actionDescriptor))

        // parameters
        if (let Some(actionDescriptor) <- actionDescriptor) {
            operation.parameters = _openApiParameterService.createParameters(actionDescriptor)
        }

        // requestBody
        if (let Some(actionDescriptor) <- actionDescriptor) {
            operation.requestBody = createOpenApiOperationRequestBody(endpoint, actionDescriptor)
        }

        // response
        operation.response = createOpenApiOperationResponses(actionDescriptor)

        // summary
        if (let Some(metadata) <- endpoint.metadata.getLastMetadata<IApiSummaryMetadata> {f => f.summary.isSome()}) {
            if (let Some(summary) <- metadata.summary) {
                operation.summary = summary
            }
        }

        // description
        if (let Some(metadata) <- endpoint
            .metadata
            .getLastMetadata<IApiDescriptionMetadata> {f => f.description.isSome()}) {
            if (let Some(description) <- metadata.description) {
                operation.description = description
            }
        }

        // operationId
        if (let Some(metadata) <- endpoint.metadata.getLastMetadata<IApiNameMetadata> {f => f.name.isSome()}) {
            operation.operationId = metadata.name
        }

        return operation
    }

    private func createOpenApiOperationTags(endpoint: RouteEndpoint, actionDescriptor: ?ControllerActionDescriptor) {
        let result = ArrayList<OpenApiTag>()
        // tags
        if (let Some(metadata) <- endpoint.metadata.getLastMetadata<IApiTagsMetadata> {f => f.tags.isSome()}) {
            if (let Some(tags) <- metadata.tags) {
                for (name in tags.split(',')) {
                    result.add(OpenApiTag(name: name))
                }
            }
        }
        if (!result.isEmpty()) {
            return result
        }

        if (let Some(actionDescriptor) <- actionDescriptor) {
            result.add(OpenApiTag(name: actionDescriptor.controllerName))
        } else {
            result.add(OpenApiTag(name: OpenApiConstants.DefaultOpenApiName))
        }

        return result
    }

    /*
    来自请求体的参数
     */
    private func createOpenApiOperationRequestBody(endpoint: RouteEndpoint, actionDescriptor: ControllerActionDescriptor): ?OpenApiRequestBody {
        var requestBody = OpenApiRequestBody(required: true)
        let parameters = HashMap<String, OpenApiSchema>()
        for (parameter in actionDescriptor.actionFunction.parameters) {
            let typeInfo = Nullable.getUnderlyingType(parameter.typeInfo) ?? parameter.typeInfo
            let hasBindingSourceMetadata = parameter.annotations |> any {f => f is IBindingSourceMetadata}
            if (parameter.findAnnotation<FromBody>().isSome() || !hasBindingSourceMetadata) {
                let schema = _openApiSchemaService.createSchema(typeInfo)
                requestBody.content.add("application/json", OpenApiMediaType(schema))
            } else if (parameter.findAnnotation<FromForm>().isSome()) {
                if (let classTypeInfo: ClassTypeInfo <- typeInfo) {
                    let schema = _openApiSchemaService.createInlineSchema(typeInfo)
                    for ((name, property) in schema.properties) {
                        parameters.add(name, property)
                    }
                } else {
                    parameters.add(BindingNameUtilities.resolveFormName(parameter), _openApiSchemaService.createSchema(typeInfo))
                }
            }
        }
        if (parameters.size > 0) {
            let formSchema = OpenApiSchema(`type`: OpenApiSchemaTypes.OBJECT)
            for ((name, schema) in parameters) {
                formSchema.properties.add(name, schema)
            }
            requestBody.content.add("multipart/form-data", OpenApiMediaType(formSchema))
        }
        if (requestBody.content.size > 0) {
            return requestBody
        }
        return None
    }

    /*
      生成响应描述
      */
    private func createOpenApiOperationResponses(actionDescriptor: ?ControllerActionDescriptor) {
        let responses = OpenApiResponses()

        // 获取action的返回类型
        let returnType: ?TypeInfo = if (let Some(actionDescriptor) <- actionDescriptor) {
            Nullable.getUnderlyingType(actionDescriptor.actionFunction.returnType) ?? actionDescriptor
                .actionFunction
                .returnType
        } else {
            None
        }
        if (let Some(returnType) <- returnType && returnType != TypeInfo.of<Unit>()) {
            let response = OpenApiResponse("OK")
            let schema = _openApiSchemaService.createSchema(returnType)
            response.content.add("text/plain", OpenApiMediaType(schema))
            response.content.add("application/json", OpenApiMediaType(schema))
            response.content.add("text/json", OpenApiMediaType(schema))
            responses.add("200", response)
        } else {
            responses.add("200", OpenApiResponse("OK"))
        }
        return responses
    }

    // api ignore
    private func isIgnore(endpoint: RouteEndpoint) {
        if (let Some(metadata) <- endpoint.metadata.getLastMetadata<IApiVisibilityProvider> {f => f.ignore}) {
            return true
        }
        return false
    }
}

extend EndpointMetadataCollection {
    /**
     * @brief 返回最后一个满足条件的元数据。
     * @param filter 用于筛选元数据的条件。
     * @return 最后一个满足条件的元数据；如果不存在则返回 `None`。
     */
    public func getLastMetadata<T>(filter: (T) -> Bool): ?T {
        let metadatas = this.getOrderedMetadata<T>()
        var index = metadatas.size - 1
        while (index >= 0) {
            let metadata = metadatas[index]
            if (filter(metadata)) {
                return metadata
            }
            index--
        }

        return None
    }
}

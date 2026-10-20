/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_openapi.services

import std.reflect.*
import std.collection.*
import soulsoft_web_mvc.*
import soulsoft_web_mvc.utilities.*
import soulsoft_web_openapi.models.*
import soulsoft_web_mvc.controllers.*
import soulsoft_web_openapi.infrastructure.*

/**
 * @brief 提供 OpenAPI 参数生成能力。
 */
protected class OpenApiParameterService {
    private let _openApiSchemaService: OpenApiSchemaService

    public init(openApiSchemaService: OpenApiSchemaService) {
        _openApiSchemaService = openApiSchemaService
    }

    /**
     * @brief 为 action 参数生成 OpenAPI parameters。
     * @param actionDescriptor 控制器 action 描述。
     * @return operation 对应的 parameters。
     */
    public func createParameters(actionDescriptor: ControllerActionDescriptor): ArrayList<OpenApiParameter> {
        let parameters = ArrayList<OpenApiParameter>()
        for (parameter in actionDescriptor.actionFunction.parameters) {
            if (let Some(location) <- getParameterLocation(parameter)) {
                parameters.add(all: createParameters(parameter, location))
            }
        }
        return parameters
    }

    private func createParameters(parameter: ParameterInfo, location: ParameterLocation): Array<OpenApiParameter> {
        let underlyingType = Nullable.getUnderlyingType(parameter.typeInfo)
        let isNullable = underlyingType.isSome()
        let typeInfo = underlyingType ?? parameter.typeInfo

        if (let classTypeInfo: ClassTypeInfo <- typeInfo) {
            let objectSchema = _openApiSchemaService.createInlineSchema(typeInfo)
            let parameters = ArrayList<OpenApiParameter>(objectSchema.properties.size)
            for ((name, propertySchema) in objectSchema.properties) {
                let isPropertyNullable = propertySchema.allowsNull()
                parameters.add(
                    OpenApiParameter(
                        name: name,
                        schema: propertySchema,
                        required: isRequiredParameter(location, isPropertyNullable),
                        location: location
                    )
                )
            }
            return parameters.toArray()
        }

        let schema = _openApiSchemaService.createSchema(parameter.typeInfo)
        return [
            OpenApiParameter(
                name: resolveParameterName(parameter, location),
                schema: schema,
                required: isRequiredParameter(location, isNullable),
                location: location
            )
        ]
    }

    private func getParameterLocation(parameter: ParameterInfo): ?ParameterLocation {
        if (parameter.findAnnotation<FromQuery>().isSome()) {
            return ParameterLocation.Query
        }
        if (parameter.findAnnotation<FromRoute>().isSome()) {
            return ParameterLocation.Path
        }
        if (parameter.findAnnotation<FromHeader>().isSome()) {
            return ParameterLocation.Header
        }
        return None
    }

    private func resolveParameterName(parameter: ParameterInfo, location: ParameterLocation): String {
        match (location) {
            case ParameterLocation.Header => BindingNameUtilities.resolveHeaderName(parameter)
            case ParameterLocation.Path => BindingNameUtilities.resolveRouteName(parameter)
            case ParameterLocation.Query => BindingNameUtilities.resolveQueryName(parameter)
        }
    }

    private func isRequiredParameter(location: ParameterLocation, isNullable: Bool): Bool {
        match (location) {
            case ParameterLocation.Path => true
            case _ => !isNullable
        }
    }
}

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_openapi.services

import std.time.*
import std.reflect.*
import std.collection.*
import std.math.numeric.*
import stdx.encoding.json.*
import soulsoft_web_http.*
import soulsoft_web_openapi.models.*
import soulsoft_web_mvc.IActionResult
import soulsoft_web_openapi.metadata.*
import soulsoft_extensions_injection.*
import soulsoft_web_openapi.transformers.*
import soulsoft_web_openapi.infrastructure.*

/**
 * @brief 提供 OpenAPI Schema 生成功能。
 */
protected class OpenApiSchemaService {
    private static let PrimitiveTypes = HashSet<TypeInfo>(
        [
            TypeInfo.of<Rune>(),
            TypeInfo.of<Bool>(),
            TypeInfo.of<Int8>(),
            TypeInfo.of<UInt8>(),
            TypeInfo.of<Int16>(),
            TypeInfo.of<UInt16>(),
            TypeInfo.of<Int32>(),
            TypeInfo.of<UInt32>(),
            TypeInfo.of<Int64>(),
            TypeInfo.of<UInt64>(),
            TypeInfo.of<Float16>(),
            TypeInfo.of<Float32>(),
            TypeInfo.of<Float64>(),
            TypeInfo.of<Any>(),
            TypeInfo.of<Object>(),
            TypeInfo.of<BigInt>(),
            TypeInfo.of<String>(),
            TypeInfo.of<Decimal>(),
            TypeInfo.of<DateTime>()
        ]
    )
    private static let StringType = TypeInfo.of<String>()
    private static let FormFileType = TypeInfo.of<IFormFile>()
    private static let JsonValueType = TypeInfo.of<JsonValue>()
    private static let ActionResultType = TypeInfo.of<IActionResult>()

    private let _documentName: String
    private let _options: OpenApiOptions
    private let _services: IServiceProvider
    private let _schemas = HashMap<String, OpenApiSchema>()

    /**
     * @brief 创建 OpenAPI Schema 服务实例。
     * @param options 当前文档的 OpenAPI 选项。
     * @param services 请求作用域的服务提供器。
     */
    public init(options: OpenApiOptions, services: IServiceProvider, documentName: String) {
        _options = options
        _services = services
        _documentName = documentName
    }

    /**
     * @brief 返回当前已缓存的 Schema 集合。
     * @return 以类型限定名为键的 Schema 集合。
     */
    public func getSchemas(): HashMap<String, OpenApiSchema> {
        return _schemas
    }

    /**
     * @brief 为指定类型创建 OpenAPI Schema。
     * @param typeInfo 要转换的类型信息。
     * @return 对应的 OpenAPI Schema。
     */
    public func createSchema(typeInfo: TypeInfo): OpenApiSchema {
        return buildSchema(typeInfo, false, true)
    }

    /**
     * @brief 为指定类型创建内联 OpenAPI Schema。
     * @param typeInfo 要转换的类型信息。
     * @return 对应的 OpenAPI Schema。
     */
    public func createInlineSchema(typeInfo: TypeInfo): OpenApiSchema {
        return buildSchema(typeInfo, false, false)
    }

    /*
    生成类型的 Schema。
    preferReference=true 时，复杂对象优先输出为组件引用。
     */
    private func buildSchema(typeInfo: TypeInfo, nullable: Bool, preferReference: Bool): OpenApiSchema {
        let underlyingType = Nullable.getUnderlyingType(typeInfo)
        if (let Some(underlyingType) <- underlyingType) {
            return createNullableSchema(buildSchema(underlyingType, false, preferReference))
        }

        // 处理基本类型
        if (OpenApiSchemaService.PrimitiveTypes.contains(typeInfo)) {
            let `type` = OpenApiSchemaTypes.convert(typeInfo)
            let format = convertToSchemaFormat(typeInfo)
            let schema = OpenApiSchema(`type`: `type`, format: format)
            applySchemaTransformers(schema, typeInfo.qualifiedName)
            if (nullable) {
                return createNullableSchema(schema)
            }
            return schema
        }

        // JsonValue/JsonObject/JsonArray 表示“任意 JSON 值树”，不应展开为固定 object schema。
        if (typeInfo.isSubtypeOf(OpenApiSchemaService.JsonValueType)) {
            let schema = OpenApiSchema()
            applySchemaTransformers(schema, typeInfo.qualifiedName)
            if (nullable) {
                return createNullableSchema(schema)
            }
            return schema
        }

        // 处理文件上传
        if (typeInfo == OpenApiSchemaService.FormFileType) {
            let schema = OpenApiSchema(`type`: OpenApiSchemaTypes.STRING, format: "binary")
            applySchemaTransformers(schema, typeInfo.qualifiedName)
            return schema
        }

        // 处理字典类型
        if (let Some((keyTypeInfo, valueTypeInfo)) <- resolveMapTypeArguments(typeInfo)) {
            return createDictionarySchema(keyTypeInfo, valueTypeInfo)
        }

        // 处理集合类型
        if (let Some(elementTypeInfo) <- resolveCollectionElementType(typeInfo)) {
            return createArraySchema(elementTypeInfo, preferReference)
        }

        // 处理泛型：IActionResult 派生类型解构一层，将泛型参数当作普通类型处理
        if (typeInfo.isSubtypeOf(OpenApiSchemaService.ActionResultType)) {
            if (let Some(resultValueType) <- resolveSingleGenericArgumentType(typeInfo)) {
                return buildSchema(resultValueType, false, preferReference)
            }
        }

        // 普通 enum 映射为 string + enum；Option<T> 已在入口处解包。
        if (typeInfo is EnumTypeInfo) {
            let schema = OpenApiSchema(`type`: OpenApiSchemaTypes.STRING)
            if (let enumTypeInfo: EnumTypeInfo <- typeInfo) {
                for (constructor in enumTypeInfo.constructors) {
                    if (constructor.parameters.isEmpty()) {
                        schema.`enum`.add(constructor.name)
                    }
                }
            }
            applySchemaTransformers(schema, typeInfo.qualifiedName)
            if (nullable) {
                return createNullableSchema(schema)
            }
            return schema
        }

        // 处理复合类型
        if (typeInfo is ClassTypeInfo || typeInfo is StructTypeInfo) {
            if (preferReference) {
                return createReferencedObjectSchema(typeInfo, nullable)
            }
            return createInlineObjectSchema(typeInfo, nullable)
        }

        let schema = OpenApiSchema(`type`: OpenApiSchemaTypes.OBJECT)
        if (nullable) {
            return createNullableSchema(schema)
        }
        return schema
    }

    /*
    生成对象的 Schema，引用 ID 由 createSchemaReferenceId 委托决定；
    返回 None 时强制内联，不生成 $ref
     */
    private func createReferencedObjectSchema(typeInfo: TypeInfo, nullable: Bool): OpenApiSchema {
        let schemaId = _options.createSchemaReferenceId(typeInfo)
        if (let Some(schemaId) <- schemaId) {
            if (_schemas.get(schemaId).isNone()) {
                let schema = OpenApiSchema(`type`: OpenApiSchemaTypes.OBJECT)
                schema.additionalProperties = false
                // 先加入缓存，再处理属性，避免循环引用导致无限递归
                _schemas.add(schemaId, schema)
                buildObjectProperties(schema, typeInfo)
                applySchemaTransformers(schema, schemaId)
            }
            return createReferenceSchema(schemaId, nullable)
        } else {
            // 强制内联：不缓存，不生成 $ref
            let schema = OpenApiSchema(`type`: OpenApiSchemaTypes.OBJECT, nullable: nullable)
            buildObjectProperties(schema, typeInfo)
            applySchemaTransformers(schema, typeInfo.qualifiedName)
            return schema
        }
    }

    private func createReferenceSchema(schemaId: String, nullable: Bool): OpenApiSchema {
        let reference = OpenApiReference(ReferenceType.Schema, schemaId)
        if (!nullable) {
            return OpenApiSchema(reference: reference)
        }
        let schema = OpenApiSchema()
        schema.nullable = true
        schema.allOf.add(OpenApiSchema(reference: reference))
        return schema
    }

    private func createInlineObjectSchema(typeInfo: TypeInfo, nullable: Bool): OpenApiSchema {
        let schema = OpenApiSchema(`type`: OpenApiSchemaTypes.OBJECT)
        buildObjectProperties(schema, typeInfo)
        applySchemaTransformers(schema, typeInfo.qualifiedName)
        if (nullable) {
            return createNullableSchema(schema)
        }
        return schema
    }

    private func buildObjectProperties(schema: OpenApiSchema, typeInfo: TypeInfo): Unit {
        let properties = getObjectProperties(typeInfo)
        for (property in properties) {
            let underlyingType = Nullable.getUnderlyingType(property.typeInfo)
            let propertyTypeInfo = underlyingType ?? property.typeInfo
            let propertySchema = buildSchema(propertyTypeInfo, underlyingType.isSome(), true)
            for (annotation in property.annotations) {
                if (let meta: IApiDescriptionMetadata <- annotation) {
                    propertySchema.description = meta.description
                }
            }
            schema.properties.add(property.name, propertySchema)
        }
    }

    private func getObjectProperties(typeInfo: TypeInfo): Array<InstancePropertyInfo> {
        if (typeInfo is ClassTypeInfo) {
            return ReflectUtilities.collectInstanceProperties(typeInfo)
        }
        return typeInfo.instanceProperties.toArray()
    }

    /*
    生成数组的 Schema
     */
    private func createArraySchema(elementTypeInfo: TypeInfo, preferReference: Bool): OpenApiSchema {
        let itemSchema = buildSchema(elementTypeInfo, false, preferReference)
        let schema = OpenApiSchema(`type`: OpenApiSchemaTypes.ARRAY, items: itemSchema)
        // transformer 面向当前数组 schema，本处使用容器类型名最准确；现阶段退化为元素类型名。
        applySchemaTransformers(schema, elementTypeInfo.qualifiedName)
        return schema
    }

    /*
     生成字典的 Schema。
     OpenAPI 3.0 的 dictionary 仅能稳定映射到 string key 的 JSON object。
     */
    private func createDictionarySchema(keyTypeInfo: TypeInfo, valueTypeInfo: TypeInfo): OpenApiSchema {
        let schema = OpenApiSchema(`type`: OpenApiSchemaTypes.OBJECT)
        if (keyTypeInfo != OpenApiSchemaService.StringType) {
            // 非字符串 key 无法直接表达为标准 JSON object key；当前保守输出为封闭 object。
            schema.additionalProperties = false
            applySchemaTransformers(schema, keyTypeInfo.qualifiedName)
            return schema
        }
        schema.additionalPropertiesSchema = buildSchema(valueTypeInfo, false, true)
        applySchemaTransformers(schema, valueTypeInfo.qualifiedName)
        return schema
    }

    private func createNullableSchema(schema: OpenApiSchema): OpenApiSchema {
        if (schema.reference.isSome()) {
            let nullableSchema = OpenApiSchema(nullable: true)
            nullableSchema.allOf.add(schema)
            return nullableSchema
        }
        schema.nullable = true
        return schema
    }

    private func applySchemaTransformers(schema: OpenApiSchema, schemaName: String): Unit {
        if (_documentName.isEmpty() || _options.schemaTransformers.isEmpty()) {
            return
        }
        let context = OpenApiSchemaTransformerContext(_services, _documentName, schemaName)
        for (transformer in _options.schemaTransformers) {
            transformer.transform(schema, context)
        }
    }

    /*
    解析 Collection<T> 中的 T
     */
    private func resolveCollectionElementType(typeInfo: TypeInfo): ?TypeInfo {
        for (pattern in typeInfo.superInterfaces) {
            let interfaceName = pattern.qualifiedName
            let baseName = TypeNameParser.getGenericBaseName(interfaceName)
            if (baseName != "Collection" && baseName != "std.collection.Collection") {
                continue
            }
            let genericArguments = TypeNameParser.getGenericArguments(interfaceName) ?? continue
            if (genericArguments.size == 1) {
                return TypeInfo.get(genericArguments[0])
            }
        }

        return None
    }

    private func resolveMapTypeArguments(typeInfo: TypeInfo): ?(TypeInfo, TypeInfo) {
        for (pattern in typeInfo.superInterfaces) {
            let interfaceName = pattern.qualifiedName
            let baseName = TypeNameParser.getGenericBaseName(interfaceName)
            if (!baseName.startsWith("std.collection.Map") && baseName != "Map") {
                continue
            }
            let genericArguments = TypeNameParser.getGenericArguments(interfaceName) ?? continue
            if (genericArguments.size == 2) {
                return (TypeInfo.get(genericArguments[0]), TypeInfo.get(genericArguments[1]))
            }
        }

        return None
    }

    /*
    解析 ActionResult<T> 中的 T
     */
    private func resolveSingleGenericArgumentType(typeInfo: TypeInfo): ?TypeInfo {
        let genericArguments = TypeNameParser.getGenericArguments(typeInfo.qualifiedName) ?? return None
        if (genericArguments.size == 1) {
            return TypeInfo.get(genericArguments[0])
        }
        return None
    }

    private static func convertToSchemaFormat(typeInfo: TypeInfo): ?String {
        match (typeInfo.name) {
            case "Int32" => "int32"
            case "Int64" => "int64"
            case "DateTime" => "date-time"
            case "Float32" => "float"
            case "Float64" => "double"
            case _ => None
        }
    }
}

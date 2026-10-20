// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_mvc.modelBindings

import std.io.*
import std.time.*
import std.reflect.*
import std.collection.*
import std.math.numeric.*
import soulsoft_serialization.*
import soulsoft_web_mvc.utilities.*
import soulsoft_serialization.annotations.*

/**
 * @brief 表示复合对象模型绑定器。
 */
public class ComplexObjectModelBinder <: IModelBinder {
    private let _typeInfo: TypeInfo
    private let _factory: IModelBinderFactory
    private let _properties: ArrayList<PropertyBindingInfo>

    /**
     * @brief 创建复合对象模型绑定器实例。
     * @param typeInfo 要绑定的类类型信息。
     * @param factory 用于解析子绑定器的模型绑定器工厂。
     */
    public init(typeInfo: ClassTypeInfo, factory: IModelBinderFactory) {
        _typeInfo = typeInfo
        _factory = factory
        _properties = collectPropertyBindings(typeInfo)
    }

    /**
     * @brief 检查当前绑定器是否支持指定类型。
     * @param typeInfo 要检查的类型信息。
     * @return 如果当前绑定器支持该类型则返回 `true`。
     */
    public func canBind(typeInfo: TypeInfo): Bool {
        return typeInfo == _typeInfo
    }

    /**
     * @brief 将值提供器中的数据绑定为复合对象。
     * @param context 当前模型绑定上下文。
     * @return 绑定得到的对象值；如果没有可绑定属性则返回 `()`。
     */
    public func bind(context: ModelBindingContext): Any {
        if (_properties.size == 0) {
            return ()
        }
        let boundFields = ByteBuffer()
        let writer = JsonWriter(boundFields)
        writer.startObject()
        for (boundProperty in _properties) {
            let property = boundProperty.property
            let bindingName = boundProperty.bindingName
            if (let Some(str) <- context.source.get(bindingName)) {
                if (str.isEmpty()) {
                    continue
                }
                let propertyTypeInfo = Nullable.getUnderlyingType(property.typeInfo) ?? property.typeInfo
                if (let Some(binder) <- _factory.createBinder(propertyTypeInfo)) {
                    let childContext = context.nested(bindingName, propertyTypeInfo)
                    let boundValue = binder.bind(childContext)
                    writer.writeName(bindingName)
                    writeJsonValue(context, writer, boundValue)
                }
            }
        }
        writer.endObject()
        writer.flush()
        return deserialize(context, boundFields)
    }

    private static func collectPropertyBindings(typeInfo: ClassTypeInfo) {
        let properties = ReflectUtilities.collectInstanceProperties(typeInfo)
        let result = ArrayList<PropertyBindingInfo>(properties.size)
        for (property in properties) {
            result.add(PropertyBindingInfo(property))
        }
        return result
    }

    private func deserialize(context: ModelBindingContext, json: ByteBuffer): Any {
        if (!context.modelState.isValid) {
            return ()
        }
        try {
            return JsonSerializer.deserialize(_typeInfo, json.bytes(), context.jsonSerializerOptions)
        } catch (ex: Exception) {
            context.modelState.addError("", ex.message)
        }
        return ()
    }

    private func writeJsonValue(context: ModelBindingContext, writer: JsonWriter, value: Any): Unit {
        if (let v: Bool <- value) {
            return v.toJson(writer, context.jsonSerializerOptions)
        }
        if (let v: Int8 <- value) {
            return v.toJson(writer, context.jsonSerializerOptions)
        }
        if (let v: Int16 <- value) {
            return v.toJson(writer, context.jsonSerializerOptions)
        }
        if (let v: Int32 <- value) {
            return v.toJson(writer, context.jsonSerializerOptions)
        }
        if (let v: Int64 <- value) {
            return v.toJson(writer, context.jsonSerializerOptions)
        }
        if (let v: UInt8 <- value) {
            return v.toJson(writer, context.jsonSerializerOptions)
        }
        if (let v: UInt16 <- value) {
            return v.toJson(writer, context.jsonSerializerOptions)
        }
        if (let v: UInt32 <- value) {
            return v.toJson(writer, context.jsonSerializerOptions)
        }
        if (let v: UInt64 <- value) {
            return v.toJson(writer, context.jsonSerializerOptions)
        }
        if (let v: BigInt <- value) {
            return v.toJson(writer, context.jsonSerializerOptions)
        }
        if (let v: Float16 <- value) {
            return v.toJson(writer, context.jsonSerializerOptions)
        }
        if (let v: Float32 <- value) {
            return v.toJson(writer, context.jsonSerializerOptions)
        }
        if (let v: Float64 <- value) {
            return v.toJson(writer, context.jsonSerializerOptions)
        }
        if (let v: Decimal <- value) {
            return v.toJson(writer, context.jsonSerializerOptions)
        }
        if (let v: String <- value) {
            return v.toJson(writer, context.jsonSerializerOptions)
        }
        if (let v: DateTime <- value) {
            return v.toJson(writer, context.jsonSerializerOptions)
        }
        if (let v: Array<Bool> <- value) {
            return v.toJson(writer, context.jsonSerializerOptions)
        }
        if (let v: Array<Int8> <- value) {
            return v.toJson(writer, context.jsonSerializerOptions)
        }
        if (let v: Array<Int16> <- value) {
            return v.toJson(writer, context.jsonSerializerOptions)
        }
        if (let v: Array<Int32> <- value) {
            return v.toJson(writer, context.jsonSerializerOptions)
        }
        if (let v: Array<Int64> <- value) {
            return v.toJson(writer, context.jsonSerializerOptions)
        }
        if (let v: Array<UInt8> <- value) {
            return v.toJson(writer, context.jsonSerializerOptions)
        }
        if (let v: Array<UInt16> <- value) {
            return v.toJson(writer, context.jsonSerializerOptions)
        }
        if (let v: Array<UInt32> <- value) {
            return v.toJson(writer, context.jsonSerializerOptions)
        }
        if (let v: Array<UInt64> <- value) {
            return v.toJson(writer, context.jsonSerializerOptions)
        }
        if (let v: Array<BigInt> <- value) {
            return v.toJson(writer, context.jsonSerializerOptions)
        }
        if (let v: Array<Float16> <- value) {
            return v.toJson(writer, context.jsonSerializerOptions)
        }
        if (let v: Array<Float32> <- value) {
            return v.toJson(writer, context.jsonSerializerOptions)
        }
        if (let v: Array<Float64> <- value) {
            return v.toJson(writer, context.jsonSerializerOptions)
        }
        if (let v: Array<Decimal> <- value) {
            return v.toJson(writer, context.jsonSerializerOptions)
        }
        if (let v: Array<String> <- value) {
            return v.toJson(writer, context.jsonSerializerOptions)
        }
        if (let v: Array<DateTime> <- value) {
            return v.toJson(writer, context.jsonSerializerOptions)
        }
        writer.writeNullValue()
    }
}

private class PropertyBindingInfo {
    public let property: InstancePropertyInfo
    public let bindingName: String

    public init(property: InstancePropertyInfo) {
        this.property = property
        this.bindingName = resolveBindingName(property)
    }

    private static func resolveBindingName(property: InstancePropertyInfo): String {
        if (let Some(jsonPropertyName) <- property.findAnnotation<JsonPropertyName>()) {
            return jsonPropertyName.name
        }
        return property.name
    }
}

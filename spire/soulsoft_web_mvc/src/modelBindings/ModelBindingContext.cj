// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_mvc.modelBindings

import std.reflect.*
import soulsoft_web_http.*
import soulsoft_serialization.*
import soulsoft_web_mvc.abstractions.*

/**
 * @brief 表示单次参数绑定的上下文。
 */
public class ModelBindingContext {
    /**
     * @brief 表示当前绑定的字段或参数名称。
     */
    public let name: String
    /**
     * @brief 表示当前要绑定到的目标类型。
     */
    public let typeInfo: TypeInfo
    /**
     * @brief 表示当前绑定使用的值提供器。
     */
    public var source: IValueProvider
    /**
     * @brief 表示当前请求的模型状态字典。
     */
    public let modelState: ModelStateDictionary
    /**
     * @brief 表示当前请求的 HTTP 上下文。
     */
    public let httpContext: HttpContext
    /**
     * @brief 表示当前使用的模型绑定器工厂。
     */
    public let factory: IModelBinderFactory
    /**
     * @brief 表示当前使用的 JSON 序列化选项。
     */
    public let jsonSerializerOptions: JsonSerializerOptions

    /**
     * @brief 创建模型绑定上下文实例。
     * @param name 当前绑定的字段或参数名称。
     * @param typeInfo 当前要绑定到的目标类型。
     * @param valueProvider 当前绑定使用的值提供器。
     * @param modelState 当前请求的模型状态字典。
     * @param httpContext 当前请求的 HTTP 上下文。
     * @param factory 当前使用的模型绑定器工厂。
     * @param jsonSerializerOptions 当前使用的 JSON 序列化选项。
     */
    public init(
        name: String,
        typeInfo: TypeInfo,
        valueProvider: IValueProvider,
        modelState: ModelStateDictionary,
        httpContext: HttpContext,
        factory: IModelBinderFactory,
        jsonSerializerOptions: JsonSerializerOptions
    ) {
        this.name = name
        this.typeInfo = typeInfo
        this.source = valueProvider
        this.modelState = modelState
        this.httpContext = httpContext
        this.factory = factory
        this.jsonSerializerOptions = jsonSerializerOptions
    }

    /**
     * @brief 创建继承共享状态的子上下文。
     * @param name 子上下文中的字段或参数名称。
     * @param typeInfo 子上下文中的目标类型。
     * @return 继承当前共享状态的新模型绑定上下文。
     */
    public func nested(name: String, typeInfo: TypeInfo): ModelBindingContext {
        return ModelBindingContext(name, typeInfo, source, modelState, httpContext, factory, jsonSerializerOptions)
    }
}

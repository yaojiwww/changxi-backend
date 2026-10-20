// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_mvc.modelBindings

import std.convert.*
import std.reflect.*

/**
 * @brief 表示可解析类型模型绑定器。
 */
public class ParsableModelBinder<T> <: IModelBinder where T <: Parsable<T> {
    private let _typeInfo: TypeInfo
    private let _default: T

    /**
     * @brief 创建可解析类型模型绑定器实例。
     * @param defaultValue 当值缺失或为空时使用的默认值。
     */
    public init(defaultValue!: T) {
        _typeInfo = TypeInfo.of<T>()
        _default = defaultValue
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
     * @brief 将字符串值绑定为可解析类型。
     * @param context 当前模型绑定上下文。
     * @return 绑定得到的目标值、默认值或 `()`。
     */
    public func bind(context: ModelBindingContext): Any {
        // get() 直接返回第一个值，避免 getAll |> filter |> collectArray 的中间 Array 分配
        if (let Some(str) <- context.source.get(context.name)) {
            if (str.isEmpty()) {
                return _default
            }
            if (let Some(value) <- T.tryParse(str)) {
                return value
            }
            context.modelState.addError(context.name, "The value '${str}' is not valid for ${context.name}.")
            return ()
        }
        return _default
    }
}

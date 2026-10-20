// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_mvc.modelBindings

import std.reflect.*
import std.collection.*
import soulsoft_web_http.*

/**
 * @brief 表示表单文件模型绑定器。
 */
public class FormFileModelBinder <: IModelBinder {
    private static let _typeInfo: TypeInfo = TypeInfo.of<IFormFile>()
    private static let _nullableTypeInfo: TypeInfo = TypeInfo.of<?IFormFile>()

    /**
     * @brief 检查当前绑定器是否支持指定类型。
     * @param typeInfo 要检查的类型信息。
     * @return 如果目标类型为 `IFormFile` 或 `?IFormFile` 则返回 `true`。
     */
    public func canBind(typeInfo: TypeInfo): Bool {
        return typeInfo == FormFileModelBinder._typeInfo || typeInfo == FormFileModelBinder._nullableTypeInfo
    }

    /**
     * @brief 将表单文件绑定到目标值。
     * @param context 当前模型绑定上下文。
     * @return 绑定得到的文件值、可空文件值或 `()`。
     */
    public func bind(context: ModelBindingContext): Any {
        let file = context.httpContext.request.form.files.get(context.name)
        if (context.typeInfo == FormFileModelBinder._nullableTypeInfo) {
            // ?IFormFile：返回 ?IFormFile 类型（即 Option<IFormFile>）
            match (file) {
                case Some(f) => return Option<IFormFile>.Some(f)
                case None => return Option<IFormFile>.None
            }
        }
        // IFormFile（非空）：文件不存在时写入 modelState 错误，触发 400
        match (file) {
            case Some(f) => return f
            case None =>
                context.modelState.addError(context.name, "The '${context.name}' field is required.")
                return ()
        }
    }
}

/**
 * @brief 表示表单文件数组模型绑定器。
 */
public class FormFileArrayModelBinder <: IModelBinder {
    private let _typeInfo: TypeInfo = TypeInfo.of<Array<IFormFile>>()

    /**
     * @brief 检查当前绑定器是否支持指定类型。
     * @param typeInfo 要检查的类型信息。
     * @return 如果目标类型为 `Array<IFormFile>` 则返回 `true`。
     */
    public func canBind(typeInfo: TypeInfo): Bool {
        return typeInfo == _typeInfo
    }

    /**
     * @brief 将表单文件集合绑定为文件数组。
     * @param context 当前模型绑定上下文。
     * @return 绑定得到的文件数组。
     */
    public func bind(context: ModelBindingContext): Any {
        let result = ArrayList<IFormFile>()
        for (file in context.httpContext.request.form.files.getAll(context.name)) {
            result.add(file)
        }
        return result.toArray()
    }
}

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_mvc.modelBindings

import std.reflect.*

/**
 * @brief 表示可空类型模型绑定器。
 */
public class NullableModelBinder <: IModelBinder {
    private let _optionTypeInfo: TypeInfo
    private let _innerBinder: IModelBinder
    private let _noneValue: Any
    private let _someWrapper: (Any) -> Any

    /**
     * @brief 创建可空类型模型绑定器实例。
     * @param optionTypeInfo 可空目标类型信息。
     * @param innerTypeInfo 可空类型内部值的类型信息。
     * @param innerBinder 内部值使用的模型绑定器。
     */
    public init(optionTypeInfo: TypeInfo, innerTypeInfo: TypeInfo, innerBinder: IModelBinder) {
        _optionTypeInfo = optionTypeInfo
        _innerBinder = innerBinder
        _noneValue = NullableUtilities.createNoneValue(innerTypeInfo)
        _someWrapper = NullableUtilities.createSomeWrapper(innerTypeInfo)
    }

    /**
     * @brief 检查当前绑定器是否支持指定类型。
     * @param typeInfo 要检查的类型信息。
     * @return 如果当前绑定器支持该类型则返回 `true`。
     */
    public func canBind(typeInfo: TypeInfo): Bool {
        return typeInfo == _optionTypeInfo
    }

    /**
     * @brief 将值绑定为可空类型。
     * @param context 当前模型绑定上下文。
     * @return 绑定得到的可空值。
     */
    public func bind(context: ModelBindingContext): Any {
        // 存在性检查：get() 返回第一个值，无需 collectArray
        if (let Some(str) <- context.source.get(context.name)) {
            if (!str.isEmpty()) {
                return _someWrapper(_innerBinder.bind(context))
            }
        }
        return _noneValue
    }
}

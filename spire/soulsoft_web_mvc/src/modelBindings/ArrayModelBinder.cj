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
 * @brief 表示数组类型模型绑定器。
 */
public class ArrayModelBinder<T> <: IModelBinder {
    private let _arrayTypeInfo: TypeInfo
    private let _elementBinder: IModelBinder
    private let _skipEmpty: Bool

    /**
     * @brief 创建数组类型模型绑定器实例。
     * @param arrayTypeInfo 目标数组类型信息。
     * @param elementBinder 数组元素使用的模型绑定器。
     * @param skipEmpty 是否跳过空字符串元素。
     */
    public init(arrayTypeInfo: TypeInfo, elementBinder: IModelBinder, skipEmpty!: Bool = true) {
        _arrayTypeInfo = arrayTypeInfo
        _elementBinder = elementBinder
        _skipEmpty = skipEmpty
    }

    /**
     * @brief 检查当前绑定器是否支持指定数组类型。
     * @param typeInfo 要检查的类型信息。
     * @return 如果当前绑定器支持该类型则返回 `true`。
     */
    public func canBind(typeInfo: TypeInfo): Bool {
        return typeInfo == _arrayTypeInfo
    }

    /**
     * @brief 将值提供器中的多值数据绑定为数组。
     * @param context 当前模型绑定上下文。
     * @return 绑定得到的数组值。
     */
    public func bind(context: ModelBindingContext): Any {
        let results = ArrayList<T>()
        // 复用同一个 source 实例 + 同一个元素 context，避免每元素两次堆分配：
        //   ① SingleValueSource 作为 class，不再每次装箱（struct → IValueProvider）
        //   ② child context 只构造一次，通过 source.value 原地切换当前值
        //   ③ 直接遍历 getAll，去掉 filter |> collectArray 的中间 Array 分配
        let elemSource = SingleValueSource()
        let elemCtx = context.nested(context.name, TypeInfo.of<T>())
        elemCtx.source = elemSource
        for (str in context.source.getAll(context.name)) {
            if (_skipEmpty && str.isEmpty()) {
                continue
            }
            elemSource.value = str
            if (let value: T <- _elementBinder.bind(elemCtx)) {
                results.add(value)
            }
            if (!context.modelState.isValid) {
                break
            }
        }
        return results.toArray()
    }
}

/**
 * 单字符串值的 IValueProvider 适配器
 */
class SingleValueSource <: IValueProvider {
    public var value: String = String.empty

    public func get(_: String): ?String {
        return value
    }

    public func getAll(_: String): Collection<String> {
        return [value]
    }
}

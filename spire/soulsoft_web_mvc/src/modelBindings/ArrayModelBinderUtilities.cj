// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_mvc.modelBindings

import std.time.*
import std.reflect.*
import std.math.numeric.*

/**
 * @brief 提供数组模型绑定器构造辅助方法。
 * @description 根据数组元素的类型信息创建对应的 `ArrayModelBinder<T>` 实例。
 */
public class ArrayModelBinderUtilities {
    /**
     * @brief 根据元素类型构建数组模型绑定器。
     * @param arrayTypeInfo 目标数组类型信息。
     * @param elementTypeInfo 数组元素类型信息。
     * @param elementBinder 元素类型对应的模型绑定器。
     * @return 对应的数组模型绑定器；如果元素类型不受支持则返回 `None`。
     */
    public static func buildArrayBinder(arrayTypeInfo: TypeInfo, elementTypeInfo: TypeInfo, elementBinder: IModelBinder): ?IModelBinder {
        if (elementTypeInfo == PrimitiveTypes.bool) {
            return ArrayModelBinder<Bool>(arrayTypeInfo, elementBinder)
        }
        if (elementTypeInfo == PrimitiveTypes.int8) {
            return ArrayModelBinder<Int8>(arrayTypeInfo, elementBinder)
        }
        if (elementTypeInfo == PrimitiveTypes.int16) {
            return ArrayModelBinder<Int16>(arrayTypeInfo, elementBinder)
        }
        if (elementTypeInfo == PrimitiveTypes.int32) {
            return ArrayModelBinder<Int32>(arrayTypeInfo, elementBinder)
        }
        if (elementTypeInfo == PrimitiveTypes.int64) {
            return ArrayModelBinder<Int64>(arrayTypeInfo, elementBinder)
        }
        if (elementTypeInfo == PrimitiveTypes.uint8) {
            return ArrayModelBinder<UInt8>(arrayTypeInfo, elementBinder)
        }
        if (elementTypeInfo == PrimitiveTypes.uint16) {
            return ArrayModelBinder<UInt16>(arrayTypeInfo, elementBinder)
        }
        if (elementTypeInfo == PrimitiveTypes.uint32) {
            return ArrayModelBinder<UInt32>(arrayTypeInfo, elementBinder)
        }
        if (elementTypeInfo == PrimitiveTypes.uint64) {
            return ArrayModelBinder<UInt64>(arrayTypeInfo, elementBinder)
        }
        if (elementTypeInfo == PrimitiveTypes.float16) {
            return ArrayModelBinder<Float16>(arrayTypeInfo, elementBinder)
        }
        if (elementTypeInfo == PrimitiveTypes.float32) {
            return ArrayModelBinder<Float32>(arrayTypeInfo, elementBinder)
        }
        if (elementTypeInfo == PrimitiveTypes.float64) {
            return ArrayModelBinder<Float64>(arrayTypeInfo, elementBinder)
        }
        if (elementTypeInfo == PrimitiveTypes.bigInt) {
            return ArrayModelBinder<BigInt>(arrayTypeInfo, elementBinder)
        }
        if (elementTypeInfo == PrimitiveTypes.decimal) {
            return ArrayModelBinder<Decimal>(arrayTypeInfo, elementBinder)
        }
        if (elementTypeInfo == PrimitiveTypes.string) {
            return ArrayModelBinder<String>(arrayTypeInfo, elementBinder)
        }
        if (elementTypeInfo == PrimitiveTypes.dateTime) {
            return ArrayModelBinder<DateTime>(arrayTypeInfo, elementBinder)
        }
        return None
    }
}

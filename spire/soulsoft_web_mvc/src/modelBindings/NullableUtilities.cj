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
 * @brief 提供 `Option<T>` 值构造辅助方法。
 * @description 为任意类型信息创建类型正确的 `None` 值和 `Some` 包装器，基础类型走静态分支，其他类型通过反射兜底。
 * @note 这里的 Nullable 指 `Option<T>`，不处理嵌套可空类型的递归展开。
 */
public class NullableUtilities {
    /**
     * @brief 创建与目标类型匹配的 `None` 值。
     * @param innerTypeInfo `Option<T>` 中内部类型 `T` 的类型信息。
     * @return 与目标类型匹配的 `Option<T>.None` 值；如果无法构造则返回 `Option<Unit>.None`。
     */
    public static func createNoneValue(innerTypeInfo: TypeInfo): Any {
        if (innerTypeInfo == PrimitiveTypes.bool) {
            return Option<Bool>.None
        }
        if (innerTypeInfo == PrimitiveTypes.int8) {
            return Option<Int8>.None
        }
        if (innerTypeInfo == PrimitiveTypes.int16) {
            return Option<Int16>.None
        }
        if (innerTypeInfo == PrimitiveTypes.int32) {
            return Option<Int32>.None
        }
        if (innerTypeInfo == PrimitiveTypes.int64) {
            return Option<Int64>.None
        }
        if (innerTypeInfo == PrimitiveTypes.uint8) {
            return Option<UInt8>.None
        }
        if (innerTypeInfo == PrimitiveTypes.uint16) {
            return Option<UInt16>.None
        }
        if (innerTypeInfo == PrimitiveTypes.uint32) {
            return Option<UInt32>.None
        }
        if (innerTypeInfo == PrimitiveTypes.uint64) {
            return Option<UInt64>.None
        }
        if (innerTypeInfo == PrimitiveTypes.float16) {
            return Option<Float16>.None
        }
        if (innerTypeInfo == PrimitiveTypes.float32) {
            return Option<Float32>.None
        }
        if (innerTypeInfo == PrimitiveTypes.float64) {
            return Option<Float64>.None
        }
        if (innerTypeInfo == PrimitiveTypes.bigInt) {
            return Option<BigInt>.None
        }
        if (innerTypeInfo == PrimitiveTypes.decimal) {
            return Option<Decimal>.None
        }
        if (innerTypeInfo == PrimitiveTypes.string) {
            return Option<String>.None
        }
        if (innerTypeInfo == PrimitiveTypes.dateTime) {
            return Option<DateTime>.None
        }
        // 反射兜底：适用于 class 类型
        try {
            return EnumTypeInfo.get("Option<${innerTypeInfo.qualifiedName}>").construct("None")
        } catch (_) {}
        return Option<Unit>.None
    }

    /**
     * @brief 创建将值包装为 `Option<T>.Some` 的函数。
     * @param innerTypeInfo `Option<T>` 中内部类型 `T` 的类型信息。
     * @return 一个包装函数，用于将输入值转换为对应的 `Option<T>`；如果包装失败则返回 `Option<Unit>.None`。
     */
    public static func createSomeWrapper(innerTypeInfo: TypeInfo): (Any) -> Any {
        if (innerTypeInfo == PrimitiveTypes.bool) {
            return {
                v: Any => if (let x: Bool <- v) {
                Option<Bool>.Some(x)
            } else {
                Option<Bool>.None
            }
            }
        }
        if (innerTypeInfo == PrimitiveTypes.int8) {
            return {
                v: Any => if (let x: Int8 <- v) {
                Option<Int8>.Some(x)
            } else {
                Option<Int8>.None
            }
            }
        }
        if (innerTypeInfo == PrimitiveTypes.int16) {
            return {
                v: Any => if (let x: Int16 <- v) {
                Option<Int16>.Some(x)
            } else {
                Option<Int16>.None
            }
            }
        }
        if (innerTypeInfo == PrimitiveTypes.int32) {
            return {
                v: Any => if (let x: Int32 <- v) {
                Option<Int32>.Some(x)
            } else {
                Option<Int32>.None
            }
            }
        }
        if (innerTypeInfo == PrimitiveTypes.int64) {
            return {
                v: Any => if (let x: Int64 <- v) {
                Option<Int64>.Some(x)
            } else {
                Option<Int64>.None
            }
            }
        }
        if (innerTypeInfo == PrimitiveTypes.uint8) {
            return {
                v: Any => if (let x: UInt8 <- v) {
                Option<UInt8>.Some(x)
            } else {
                Option<UInt8>.None
            }
            }
        }
        if (innerTypeInfo == PrimitiveTypes.uint16) {
            return {
                v: Any => if (let x: UInt16 <- v) {
                Option<UInt16>.Some(x)
            } else {
                Option<UInt16>.None
            }
            }
        }
        if (innerTypeInfo == PrimitiveTypes.uint32) {
            return {
                v: Any => if (let x: UInt32 <- v) {
                Option<UInt32>.Some(x)
            } else {
                Option<UInt32>.None
            }
            }
        }
        if (innerTypeInfo == PrimitiveTypes.uint64) {
            return {
                v: Any => if (let x: UInt64 <- v) {
                Option<UInt64>.Some(x)
            } else {
                Option<UInt64>.None
            }
            }
        }
        if (innerTypeInfo == PrimitiveTypes.float16) {
            return {
                v: Any => if (let x: Float16 <- v) {
                Option<Float16>.Some(x)
            } else {
                Option<Float16>.None
            }
            }
        }
        if (innerTypeInfo == PrimitiveTypes.float32) {
            return {
                v: Any => if (let x: Float32 <- v) {
                Option<Float32>.Some(x)
            } else {
                Option<Float32>.None
            }
            }
        }
        if (innerTypeInfo == PrimitiveTypes.float64) {
            return {
                v: Any => if (let x: Float64 <- v) {
                Option<Float64>.Some(x)
            } else {
                Option<Float64>.None
            }
            }
        }
        if (innerTypeInfo == PrimitiveTypes.bigInt) {
            return {
                v: Any => if (let x: BigInt <- v) {
                Option<BigInt>.Some(x)
            } else {
                Option<BigInt>.None
            }
            }
        }
        if (innerTypeInfo == PrimitiveTypes.decimal) {
            return {
                v: Any => if (let x: Decimal <- v) {
                Option<Decimal>.Some(x)
            } else {
                Option<Decimal>.None
            }
            }
        }
        if (innerTypeInfo == PrimitiveTypes.string) {
            return {
                v: Any => if (let x: String <- v) {
                Option<String>.Some(x)
            } else {
                Option<String>.None
            }
            }
        }
        if (innerTypeInfo == PrimitiveTypes.dateTime) {
            return {
                v: Any => if (let x: DateTime <- v) {
                Option<DateTime>.Some(x)
            } else {
                Option<DateTime>.None
            }
            }
        }
        // 反射兜底：适用于 class 类型
        let qualName = innerTypeInfo.qualifiedName
        return {
            v: Any => try {
                EnumTypeInfo.get("Option<${qualName}>").construct("Some(${qualName})", v)
            } catch (_) {
                Option<Unit>.None
            }
        }
    }
}

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
 * @brief 提供模型绑定支持的基本类型 TypeInfo 常量。
 */
public class PrimitiveTypes {
    /**
     * @brief 表示 `Bool` 类型的 TypeInfo。
     */
    public static let bool: TypeInfo = TypeInfo.of<Bool>()
    /**
     * @brief 表示 `Int8` 类型的 TypeInfo。
     */
    public static let int8: TypeInfo = TypeInfo.of<Int8>()
    /**
     * @brief 表示 `Int16` 类型的 TypeInfo。
     */
    public static let int16: TypeInfo = TypeInfo.of<Int16>()
    /**
     * @brief 表示 `Int32` 类型的 TypeInfo。
     */
    public static let int32: TypeInfo = TypeInfo.of<Int32>()
    /**
     * @brief 表示 `Int64` 类型的 TypeInfo。
     */
    public static let int64: TypeInfo = TypeInfo.of<Int64>()
    /**
     * @brief 表示 `UInt8` 类型的 TypeInfo。
     */
    public static let uint8: TypeInfo = TypeInfo.of<UInt8>()
    /**
     * @brief 表示 `UInt16` 类型的 TypeInfo。
     */
    public static let uint16: TypeInfo = TypeInfo.of<UInt16>()
    /**
     * @brief 表示 `UInt32` 类型的 TypeInfo。
     */
    public static let uint32: TypeInfo = TypeInfo.of<UInt32>()
    /**
     * @brief 表示 `UInt64` 类型的 TypeInfo。
     */
    public static let uint64: TypeInfo = TypeInfo.of<UInt64>()
    /**
     * @brief 表示 `Float16` 类型的 TypeInfo。
     */
    public static let float16: TypeInfo = TypeInfo.of<Float16>()
    /**
     * @brief 表示 `Float32` 类型的 TypeInfo。
     */
    public static let float32: TypeInfo = TypeInfo.of<Float32>()
    /**
     * @brief 表示 `Float64` 类型的 TypeInfo。
     */
    public static let float64: TypeInfo = TypeInfo.of<Float64>()
    /**
     * @brief 表示 `BigInt` 类型的 TypeInfo。
     */
    public static let bigInt: TypeInfo = TypeInfo.of<BigInt>()
    /**
     * @brief 表示 `Decimal` 类型的 TypeInfo。
     */
    public static let decimal: TypeInfo = TypeInfo.of<Decimal>()
    /**
     * @brief 表示 `String` 类型的 TypeInfo。
     */
    public static let string: TypeInfo = TypeInfo.of<String>()
    /**
     * @brief 表示 `DateTime` 类型的 TypeInfo。
     */
    public static let dateTime: TypeInfo = TypeInfo.of<DateTime>()
}

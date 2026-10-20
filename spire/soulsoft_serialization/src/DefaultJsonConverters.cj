/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_serialization

/**
 * @brief 提供框架内置的 JSON 转换器集合。
 */
internal class DefaultJsonConverters {
    private static let converters: Array<IJsonConverter>

    static init() {
        converters = [
            // 整数类型
            Int8JsonConverter(),
            UInt8JsonConverter(),
            Int16JsonConverter(),
            UInt16JsonConverter(),
            Int32JsonConverter(),
            UInt32JsonConverter(),
            Int64JsonConverter(),
            UInt64JsonConverter(),
            // 浮点类型
            Float16JsonConverter(),
            Float32JsonConverter(),
            Float64JsonConverter(),
            // 高精度数值
            BigIntJsonConverter(),
            DecimalJsonConverter(),
            // 时间类型
            DateTimeJsonConverter(),
            // 可空整数类型
            Int8NullableJsonConverter(),
            UInt8NullableJsonConverter(),
            Int16NullableJsonConverter(),
            UInt16NullableJsonConverter(),
            Int32NullableJsonConverter(),
            UInt32NullableJsonConverter(),
            Int64NullableJsonConverter(),
            UInt64NullableJsonConverter(),
            // 可空浮点类型
            Float16NullableJsonConverter(),
            Float32NullableJsonConverter(),
            Float64NullableJsonConverter(),
            // 可空高精度数值
            BigIntNullableJsonConverter(),
            DecimalNullableJsonConverter(),
            // 可空时间类型
            DateTimeNullableJsonConverter()
        ]
    }

    internal static func getConverter<T>(): ?JsonConverter<T> {
        return findLastConverter<T>(converters)
    }
}

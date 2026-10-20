/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_serialization

/**
 * @brief 定义 JSON 与目标类型之间的转换器。
 * @param T 转换器处理的目标类型。
 */
public abstract class JsonConverter<T> <: IJsonConverter {
    /**
     * @brief 从 JSON 读取目标类型值。
     * @param r JSON 读取器。
     * @param options 转换时使用的选项。
     * @return 读取后的目标类型值。
     */
    public func read(r: JsonReader, options: JsonSerializerOptions): T

    /**
     * @brief 将目标类型值写入 JSON。
     * @param w JSON 写入器。
     * @param value 待写出的目标值。
     * @param options 转换时使用的选项。
     */
    public func write(w: JsonWriter, value: T, options: JsonSerializerOptions): Unit
}

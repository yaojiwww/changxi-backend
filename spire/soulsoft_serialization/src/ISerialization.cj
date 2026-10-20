/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_serialization

/**
 * @brief 定义从 JSON 反序列化对象的能力。
 * @param T 反序列化得到的目标类型。
 */
public interface IDeserializable<T> {  
    /**
     * @brief 从 JSON 读取目标类型实例。
     * @param r JSON 读取器。
     * @param options 反序列化选项。
     * @return 反序列化得到的目标实例。
     */
    static func fromJson(r: JsonReader, options: JsonSerializerOptions): T
}

/**
 * @brief 定义将对象序列化为 JSON 的能力。
 */
public interface ISerializable {
    /**
     * @brief 使用指定选项将当前对象写入 JSON。
     * @param w JSON 写入器。
     * @param options 序列化选项。
     */
    func toJson(w: JsonWriter, options: JsonSerializerOptions): Unit
}

/**
 * @brief 组合序列化与反序列化能力。
 * @param T 当前类型对应的反序列化目标类型。
 */
public interface ISerialization<T> <: ISerializable & IDeserializable<T> {}

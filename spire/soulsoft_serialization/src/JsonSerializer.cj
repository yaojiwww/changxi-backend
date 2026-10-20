/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_serialization

import std.io.*
import std.reflect.*
import stdx.encoding.json.*

/**
 * @brief 提供 JSON 字符串、字节数组、流、JsonValue 与对象之间的统一序列化入口。
 */
public class JsonSerializer {
    /**
     * @brief 使用默认选项将对象序列化为 JSON 字符串。
     * @param data 待序列化的对象。
     * @return 序列化后的 JSON 字符串。
     */
    public static func serialize<T>(data: T): String where T <: ISerializable {
        return serialize<T>(data, JsonSerializerOptions.default)
    }

    /**
     * @brief 使用指定选项将对象序列化为 JSON 字符串。
     * @param data 待序列化的对象。
     * @param options 序列化选项。
     * @return 序列化后的 JSON 字符串。
     */
    public static func serialize<T>(data: T, options: JsonSerializerOptions): String where T <: ISerializable {
        let buffer = ByteBuffer()
        let w = JsonWriter.create(buffer, options)
        data.toJson(w, options)
        w.flush()
        return buffer |> readString
    }

    /**
     * @brief 使用默认选项将对象序列化为 UTF-8 字节数组。
     * @param data 待序列化的对象。
     * @return 序列化后的 UTF-8 字节数组。
     */
    public static func serializeToUtf8Bytes<T>(data: T): Array<Byte> where T <: ISerializable {
        return serializeToUtf8Bytes<T>(data, JsonSerializerOptions.default)
    }

    /**
     * @brief 使用指定选项将对象序列化为 UTF-8 字节数组。
     * @param data 待序列化的对象。
     * @param options 序列化选项。
     * @return 序列化后的 UTF-8 字节数组。
     */
    public static func serializeToUtf8Bytes<T>(data: T, options: JsonSerializerOptions): Array<Byte>
        where T <: ISerializable {
        let buffer = ByteBuffer()
        serialize(buffer, data, options)
        return buffer.bytes()
    }

    /**
     * @brief 使用默认选项将对象写入输出流。
     * @param stream 输出流。
     * @param data 待序列化的对象。
     */
    public static func serialize<T>(stream: OutputStream, data: T): Unit where T <: ISerializable {
        serialize(stream, data, JsonSerializerOptions.default)
    }

    /**
     * @brief 使用指定选项将对象写入输出流。
     * @param stream 输出流。
     * @param data 待序列化的对象。
     * @param options 序列化选项。
     */
    public static func serialize<T>(stream: OutputStream, data: T, options: JsonSerializerOptions): Unit
        where T <: ISerializable {
        let w = JsonWriter.create(stream, options)
        data.toJson(w, options)
        w.flush()
    }

    /**
     * @brief 使用默认选项将对象序列化为 JsonValue。
     * @param data 待序列化的对象。
     * @return 序列化后的 JsonValue。
     */
    public static func serializeToJsonValue<T>(data: T): JsonValue where T <: ISerializable {
        return serializeToJsonValue<T>(data, JsonSerializerOptions.default)
    }

    /**
     * @brief 使用指定选项将对象序列化为 JsonValue。
     * @param data 待序列化的对象。
     * @param options 序列化选项。
     * @return 序列化后的 JsonValue。
     */
    public static func serializeToJsonValue<T>(data: T, options: JsonSerializerOptions): JsonValue
        where T <: ISerializable {
        try {
            return JsonValue.fromStr(serialize(data, options))
        } catch (ex: JsonSerializationException) {
            throw ex
        } catch (ex: Exception) {
            throw JsonSerializationException(ex.message, None, ex)
        }
    }

    /**
     * @brief 使用默认选项从 JSON 字符串反序列化对象。
     * @param json 输入的 JSON 字符串。
     * @return 反序列化后的对象实例。
     * @throws JsonSerializationException 当 JSON 文本无法解析或目标对象构造失败时抛出。
     */
    public static func deserialize<T>(json: String): T where T <: IDeserializable<T> {
        return deserialize<T>(json, JsonSerializerOptions.default)
    }
    /**
     * @brief 使用指定选项从 JSON 字符串反序列化对象。
     * @param json 输入的 JSON 字符串。
     * @param options 反序列化选项。
     * @return 反序列化后的对象实例。
     * @throws JsonSerializationException 当 JSON 文本无法解析或目标对象构造失败时抛出。
     */
    public static func deserialize<T>(json: String, options: JsonSerializerOptions): T where T <: IDeserializable<T> {
        let r = JsonReader.create(json)
        return T.fromJson(r, options)
    }

    /**
     * @brief 使用默认选项从 UTF-8 字节数组反序列化对象。
     * @param json 输入的 UTF-8 字节数组。
     * @return 反序列化后的对象实例。
     * @throws JsonSerializationException 当 JSON 文本无法解析或目标对象构造失败时抛出。
     */
    public static func deserialize<T>(json: Array<Byte>): T where T <: IDeserializable<T> {
        return deserialize<T>(json, JsonSerializerOptions.default)
    }

    /**
     * @brief 使用指定选项从 UTF-8 字节数组反序列化对象。
     * @param json 输入的 UTF-8 字节数组。
     * @param options 反序列化选项。
     * @return 反序列化后的对象实例。
     * @throws JsonSerializationException 当 JSON 文本无法解析或目标对象构造失败时抛出。
     */
    public static func deserialize<T>(json: Array<Byte>, options: JsonSerializerOptions): T
        where T <: IDeserializable<T> {
        let r = JsonReader.create(json)
        return T.fromJson(r, options)
    }

    /**
     * @brief 使用指定选项从输入流反序列化对象。
     * @param stream 输入流。
     * @param options 反序列化选项。
     * @return 反序列化后的对象实例。
     * @throws JsonSerializationException 当 JSON 文本无法解析或目标对象构造失败时抛出。
     */
    public static func deserialize<T>(stream: InputStream, options: JsonSerializerOptions): T
        where T <: IDeserializable<T> {
        let r = JsonReader.create(stream)
        return T.fromJson(r, options)
    }

    /**
     * @brief 使用默认选项从 JsonValue 反序列化对象。
     * @param json 输入的 JsonValue。
     * @return 反序列化后的对象实例。
     * @throws JsonSerializationException 当 JSON 文本无法解析或目标对象构造失败时抛出。
     */
    public static func deserialize<T>(json: JsonValue): T where T <: IDeserializable<T> {
        return deserialize<T>(json, JsonSerializerOptions.default)
    }

    /**
     * @brief 使用指定选项从 JsonValue 反序列化对象。
     * @param json 输入的 JsonValue。
     * @param options 反序列化选项。
     * @return 反序列化后的对象实例。
     * @throws JsonSerializationException 当 JSON 文本无法解析或目标对象构造失败时抛出。
     */
    public static func deserialize<T>(json: JsonValue, options: JsonSerializerOptions): T
        where T <: IDeserializable<T> {
        let r = JsonReader.create(json)
        return T.fromJson(r, options)
    }

    /**
     * @brief 使用运行时类型信息从 JSON 字符串反序列化对象。
     * @param typeInfo 目标类型信息。
     * @param json 输入的 JSON 字符串。
     * @param options 反序列化选项。
     * @return 反序列化后的对象实例。
     * @throws JsonSerializationException 当 JSON 文本无法解析或目标类型不支持反序列化时抛出。
     */
    public static func deserialize(typeInfo: TypeInfo, json: String, options: JsonSerializerOptions): Any {
        let r = JsonReader.create(json)
        return deserialize(typeInfo, r, options)
    }

    /**
     * @brief 使用运行时类型信息从 UTF-8 字节数组反序列化对象。
     * @param typeInfo 目标类型信息。
     * @param json 输入的 UTF-8 字节数组。
     * @param options 反序列化选项。
     * @return 反序列化后的对象实例。
     * @throws JsonSerializationException 当 JSON 文本无法解析或目标类型不支持反序列化时抛出。
     */
    public static func deserialize(typeInfo: TypeInfo, json: Array<Byte>, options: JsonSerializerOptions): Any {
        let r = JsonReader.create(json)
        return deserialize(typeInfo, r, options)
    }

    /**
     * @brief 使用运行时类型信息从输入流反序列化对象。
     * @param typeInfo 目标类型信息。
     * @param stream 输入流。
     * @param options 反序列化选项。
     * @return 反序列化后的对象实例。
     * @throws JsonSerializationException 当 JSON 文本无法解析或目标类型不支持反序列化时抛出。
     */
    public static func deserialize(typeInfo: TypeInfo, stream: InputStream, options: JsonSerializerOptions): Any {
        let r = JsonReader.create(stream)
        return deserialize(typeInfo, r, options)
    }

    /**
     * @brief 使用运行时类型信息从 JsonValue 反序列化对象。
     * @param typeInfo 目标类型信息。
     * @param json 输入的 JsonValue。
     * @param options 反序列化选项。
     * @return 反序列化后的对象实例。
     * @throws JsonSerializationException 当 JSON 文本无法解析或目标类型不支持反序列化时抛出。
     */
    public static func deserialize(typeInfo: TypeInfo, json: JsonValue, options: JsonSerializerOptions): Any {
        let r = JsonReader.create(json)
        return deserialize(typeInfo, r, options)
    }

    private static func deserialize(typeInfo: TypeInfo, r: JsonReader, options: JsonSerializerOptions): Any {
        try {
        let converter = typeInfo.getStaticFunction("fromJson", TypeInfo.of<JsonReader>(),
            TypeInfo.of<JsonSerializerOptions>())
        return converter.apply(typeInfo, r, options)
        } catch (ex: JsonSerializationException) {
            throw ex
        } catch (ex: Exception) {
            throw JsonSerializationException(ex.message, None, ex)
        }
    }

}

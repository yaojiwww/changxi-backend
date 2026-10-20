/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_serialization

import std.io.*
import std.time.*
import std.collection.*
import std.convert.*
import std.math.numeric.*
import stdx.encoding.json.*

extend Int8 <: ISerialization<Int8> {
    public func toJson(w: JsonWriter, options: JsonSerializerOptions): Unit {
        return getRequiredScalarConverter<Int8>(options).write(w, this, options)
    }

    public static func fromJson(r: JsonReader, options: JsonSerializerOptions): Int8 {
        return getRequiredScalarConverter<Int8>(options).read(r, options)
    }
}

extend Int16 <: ISerialization<Int16> {
    public func toJson(w: JsonWriter, options: JsonSerializerOptions): Unit {
        return getRequiredScalarConverter<Int16>(options).write(w, this, options)
    }

    public static func fromJson(r: JsonReader, options: JsonSerializerOptions): Int16 {
        return getRequiredScalarConverter<Int16>(options).read(r, options)
    }
}

extend Int32 <: ISerialization<Int32> {
    public func toJson(w: JsonWriter, options: JsonSerializerOptions): Unit {
        return getRequiredScalarConverter<Int32>(options).write(w, this, options)
    }

    public static func fromJson(r: JsonReader, options: JsonSerializerOptions): Int32 {
        return getRequiredScalarConverter<Int32>(options).read(r, options)
    }
}

extend Int64 <: ISerialization<Int64> {
    public func toJson(w: JsonWriter, options: JsonSerializerOptions): Unit {
        return getRequiredScalarConverter<Int64>(options).write(w, this, options)
    }

    public static func fromJson(r: JsonReader, options: JsonSerializerOptions): Int64 {
        return getRequiredScalarConverter<Int64>(options).read(r, options)
    }
}

extend UInt8 <: ISerialization<UInt8> {
    public func toJson(w: JsonWriter, options: JsonSerializerOptions): Unit {
        return getRequiredScalarConverter<UInt8>(options).write(w, this, options)
    }

    public static func fromJson(r: JsonReader, options: JsonSerializerOptions): UInt8 {
        return getRequiredScalarConverter<UInt8>(options).read(r, options)
    }
}

extend UInt16 <: ISerialization<UInt16> {
    public func toJson(w: JsonWriter, options: JsonSerializerOptions): Unit {
        return getRequiredScalarConverter<UInt16>(options).write(w, this, options)
    }

    public static func fromJson(r: JsonReader, options: JsonSerializerOptions): UInt16 {
        return getRequiredScalarConverter<UInt16>(options).read(r, options)
    }
}

extend UInt32 <: ISerialization<UInt32> {
    public func toJson(w: JsonWriter, options: JsonSerializerOptions): Unit {
        return getRequiredScalarConverter<UInt32>(options).write(w, this, options)
    }

    public static func fromJson(r: JsonReader, options: JsonSerializerOptions): UInt32 {
        return getRequiredScalarConverter<UInt32>(options).read(r, options)
    }
}

extend UInt64 <: ISerialization<UInt64> {
    public func toJson(w: JsonWriter, options: JsonSerializerOptions): Unit {
        return getRequiredScalarConverter<UInt64>(options).write(w, this, options)
    }

    public static func fromJson(r: JsonReader, options: JsonSerializerOptions): UInt64 {
        return getRequiredScalarConverter<UInt64>(options).read(r, options)
    }
}

extend Bool <: ISerialization<Bool> {
    public func toJson(w: JsonWriter, options: JsonSerializerOptions): Unit {
        if (let Some(converter) <- options.getConverter<Bool>()) {
            return converter.write(w, this, options)
        }
        w.writeValue(this)
    }

    public static func fromJson(r: JsonReader, options: JsonSerializerOptions): Bool {
        if (let Some(converter) <- options.getConverter<Bool>()) {
            return converter.read(r, options)
        }
        return r.readValue<Bool>()
    }
}

extend Float16 <: ISerialization<Float16> {
    public func toJson(w: JsonWriter, options: JsonSerializerOptions): Unit {
        return getRequiredScalarConverter<Float16>(options).write(w, this, options)
    }

    public static func fromJson(r: JsonReader, options: JsonSerializerOptions): Float16 {
        return getRequiredScalarConverter<Float16>(options).read(r, options)
    }
}

extend Float32 <: ISerialization<Float32> {
    public func toJson(w: JsonWriter, options: JsonSerializerOptions): Unit {
        return getRequiredScalarConverter<Float32>(options).write(w, this, options)
    }

    public static func fromJson(r: JsonReader, options: JsonSerializerOptions): Float32 {
        return getRequiredScalarConverter<Float32>(options).read(r, options)
    }
}

extend Float64 <: ISerialization<Float64> {
    public func toJson(w: JsonWriter, options: JsonSerializerOptions): Unit {
        return getRequiredScalarConverter<Float64>(options).write(w, this, options)
    }

    public static func fromJson(r: JsonReader, options: JsonSerializerOptions): Float64 {
        return getRequiredScalarConverter<Float64>(options).read(r, options)
    }
}

extend String <: ISerialization<String> {
    public func toJson(w: JsonWriter, options: JsonSerializerOptions): Unit {
        if (let Some(converter) <- options.getConverter<String>()) {
            return converter.write(w, this, options)
        }
        w.writeValue(this)
    }

    public static func fromJson(r: JsonReader, options: JsonSerializerOptions): String {
        if (let Some(converter) <- options.getConverter<String>()) {
            return converter.read(r, options)
        }
        return r.readValue<String>()
    }
}

extend BigInt <: ISerialization<BigInt> {
    public func toJson(w: JsonWriter, options: JsonSerializerOptions): Unit {
        return getRequiredScalarConverter<BigInt>(options).write(w, this, options)
    }

    public static func fromJson(r: JsonReader, options: JsonSerializerOptions): BigInt {
        return getRequiredScalarConverter<BigInt>(options).read(r, options)
    }
}

extend DateTime <: ISerialization<DateTime> {
    public func toJson(w: JsonWriter, options: JsonSerializerOptions): Unit {
        return getRequiredScalarConverter<DateTime>(options).write(w, this, options)
    }

    public static func fromJson(r: JsonReader, options: JsonSerializerOptions): DateTime {
        return getRequiredScalarConverter<DateTime>(options).read(r, options)
    }
}

extend Decimal <: ISerialization<Decimal> {
    public func toJson(w: JsonWriter, options: JsonSerializerOptions): Unit {
        return getRequiredScalarConverter<Decimal>(options).write(w, this, options)
    }

    public static func fromJson(r: JsonReader, options: JsonSerializerOptions): Decimal {
        return getRequiredScalarConverter<Decimal>(options).read(r, options)
    }
}

extend<T> Array<T> <: ISerialization<Array<T>> where T <: ISerialization<T> {
    public func toJson(w: JsonWriter, options: JsonSerializerOptions): Unit {
        w.startArray()
        for (pattern in this) {
            pattern.toJson(w, options)
        }
        w.endArray()
    }

    public static func fromJson(r: JsonReader, options: JsonSerializerOptions): Array<T> {
        return match (r.peek()) {
            case Some(BeginArray) =>
                let list = ArrayList<T>()
                r.startArray()
                while (r.peek() != EndArray) {
                    list.add(T.fromJson(r, options))
                }
                r.endArray()
                list.toArray()
            case _ =>
                r.skip()
                Array<T>()
        }
    }
}

extend<T> ArrayList<T> <: ISerialization<ArrayList<T>> where T <: ISerialization<T> {
    public func toJson(w: JsonWriter, options: JsonSerializerOptions): Unit {
        w.startArray()
        for (pattern in this) {
            pattern.toJson(w, options)
        }
        w.endArray()
    }

    public static func fromJson(r: JsonReader, options: JsonSerializerOptions): ArrayList<T> {
        return match (r.peek()) {
            case Some(BeginArray) =>
                let list = ArrayList<T>()
                r.startArray()
                while (r.peek() != EndArray) {
                    list.add(T.fromJson(r, options))
                }
                r.endArray()
                list
            case _ =>
                r.skip()
                ArrayList<T>()
        }
    }
}

extend<T> HashSet<T> <: ISerialization<HashSet<T>> where T <: ISerialization<T> {
    public func toJson(w: JsonWriter, options: JsonSerializerOptions): Unit {
        w.startArray()
        for (pattern in this) {
            pattern.toJson(w, options)
        }
        w.endArray()
    }

    public static func fromJson(r: JsonReader, options: JsonSerializerOptions): HashSet<T> {
        return match (r.peek()) {
            case Some(BeginArray) =>
                let list = HashSet<T>()
                r.startArray()
                while (r.peek() != EndArray) {
                    list.add(T.fromJson(r, options))
                }
                r.endArray()
                list
            case _ =>
                r.skip()
                HashSet<T>()
        }
    }
}

extend<K, V> HashMap<K, V> <: ISerialization<HashMap<K, V>> where K <: ISerialization<K>, V <: ISerialization<V> {
    public func toJson(w: JsonWriter, options: JsonSerializerOptions): Unit {
        w.startObject()
        for ((key, value) in this) {
            w.writeName(stringifyMapKey<K>(key, options))
            value.toJson(w, options)
        }
        w.endObject()
    }

    public static func fromJson(r: JsonReader, options: JsonSerializerOptions): HashMap<K, V> {
        return match (r.peek()) {
            case Some(BeginObject) =>
                let list = HashMap<K, V>()
                r.startObject()
                while (r.peek() != EndObject) {
                    let key = parseMapKey<K>(r.readName(), options)
                    let value = V.fromJson(r, options)
                    list.add(key, value)
                }
                r.endObject()
                list
            case _ =>
                r.skip()
                HashMap<K, V>()
        }
    }
}

extend JsonValue <: ISerialization<JsonValue> {
    public func toJson(w: JsonWriter, options: JsonSerializerOptions): Unit {
        if (let Some(converter) <- options.getConverter<JsonValue>()) {
            return converter.write(w, this, options)
        }
        w.jsonValue(this.toString())
    }

    public static func fromJson(r: JsonReader, options: JsonSerializerOptions): JsonValue {
        if (let Some(converter) <- options.getConverter<JsonValue>()) {
            return converter.read(r, options)
        }
        try {
            return r.readJsonValue()
        } catch (ex: JsonSerializationException) {
            throw ex
        } catch (ex: Exception) {
            throw JsonSerializationException(ex.message, None, ex)
        }
    }
}

extend<T> Option<T> <: ISerialization<Option<T>> where T <: ISerialization<T> {
    public func toJson(w: JsonWriter, options: JsonSerializerOptions): Unit {
        let converter = options.getConverter<Option<T>>()
        if (converter.isSome()) {
            let converter = converter.getOrThrow()
            return converter.write(w, this, options)
        }
        if (let Some(value) <- this) {
            return value.toJson(w, options)
        }
        w.writeNullValue()
    }

    public static func fromJson(r: JsonReader, options: JsonSerializerOptions): Option<T> {
        let converter = options.getConverter<Option<T>>()
        if (converter.isSome()) {
            let converter = converter.getOrThrow()
            return converter.read(r, options)
        }
        if (r.trySkipNull()) {
            return None
        }
        return T.fromJson(r, options)
    }
}

private func tryStringifyFastMapKey<K>(key: K): ?String where K <: ISerialization<K> {
    if (let value: String <- key) {
        return value
    }
    if (let value: Bool <- key) {
        return value.toString()
    }
    if (let value: Int8 <- key) {
        return value.toString()
    }
    if (let value: UInt8 <- key) {
        return value.toString()
    }
    if (let value: Int16 <- key) {
        return value.toString()
    }
    if (let value: UInt16 <- key) {
        return value.toString()
    }
    if (let value: Int32 <- key) {
        return value.toString()
    }
    if (let value: UInt32 <- key) {
        return value.toString()
    }
    if (let value: Int64 <- key) {
        return value.toString()
    }
    if (let value: UInt64 <- key) {
        return value.toString()
    }
    return None
}

private func tryParseFastMapKey<K>(name: String): ?K where K <: ISerialization<K> {
    if (let value: K <- name) {
        return value
    }
    if (name == "true") {
        if (let value: K <- true) {
            return value
        }
    }
    if (name == "false") {
        if (let value: K <- false) {
            return value
        }
    }
    if (let Some(value) <- Int8.tryParse(name)) {
        if (let key: K <- value) {
            return key
        }
    }
    if (let Some(value) <- UInt8.tryParse(name)) {
        if (let key: K <- value) {
            return key
        }
    }
    if (let Some(value) <- Int16.tryParse(name)) {
        if (let key: K <- value) {
            return key
        }
    }
    if (let Some(value) <- UInt16.tryParse(name)) {
        if (let key: K <- value) {
            return key
        }
    }
    if (let Some(value) <- Int32.tryParse(name)) {
        if (let key: K <- value) {
            return key
        }
    }
    if (let Some(value) <- UInt32.tryParse(name)) {
        if (let key: K <- value) {
            return key
        }
    }
    if (let Some(value) <- Int64.tryParse(name)) {
        if (let key: K <- value) {
            return key
        }
    }
    if (let Some(value) <- UInt64.tryParse(name)) {
        if (let key: K <- value) {
            return key
        }
    }
    return None
}

private func stringifyMapKey<K>(key: K, options: JsonSerializerOptions): String where K <: ISerialization<K> {
    if (let Some(value) <- tryStringifyFastMapKey<K>(key)) {
        return value
    }
    let buffer = ByteBuffer()
    let writer = JsonWriter(buffer)
    key.toJson(writer, options)
    writer.flush()
    let reader = JsonReader.create(buffer |> readString)
    return String.fromJson(reader, options)
}

private func parseMapKey<K>(name: String, options: JsonSerializerOptions): K where K <: ISerialization<K> {
    if (let Some(value) <- tryParseFastMapKey<K>(name)) {
        return value
    }
    let buffer = ByteBuffer()
    let writer = JsonWriter(buffer)
    writer.writeValue(name)
    writer.flush()
    let reader = JsonReader.create(buffer |> readString)
    return K.fromJson(reader, options)
}

private func getRequiredScalarConverter<T>(options: JsonSerializerOptions): JsonConverter<T> {
    if (let Some(converter) <- options.getConverter<T>()) {
        return converter
    }
    throw JsonSerializationException("Missing scalar JsonConverter.")
}

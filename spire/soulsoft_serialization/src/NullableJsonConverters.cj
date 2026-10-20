/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_serialization

import std.time.*
import std.convert.*
import std.math.numeric.*

class Int8NullableJsonConverter <: JsonConverter<?Int8> {
    public func read(r: JsonReader, options: JsonSerializerOptions): ?Int8 {
        match (r.peek()) {
            case Some(JsonToken.JsonNull) =>
                r.skip()
                None
            case Some(JsonToken.JsonNumber) => readFromNumber(r)
            case Some(JsonToken.JsonString) where options
                .numberHandling
                .hasFlag(JsonNumberHandling.AllowReadingFromString) => readFromString(r.readValue<String>())
            case _ => throw JsonSerializationException("must be a valid Int8.")
        }
    }

    public func write(w: JsonWriter, value: ?Int8, options: JsonSerializerOptions): Unit {
        if (options.numberHandling.hasFlag(JsonNumberHandling.WriteAsString)) {
            if (let Some(v) <- value) {
                w.writeValue(v.toString())
                return
            }
            w.writeNullValue()
            return
        }
        w.writeValue(value)
    }

    private func readFromString(str: String): ?Int8 {
        if (str.isEmpty()) {
            return None
        }
        if (let Some(value) <- Int8.tryParse(str)) {
            return value
        } else {
            throw JsonSerializationException("must be a valid Int8.")
        }
    }

    private func readFromNumber(r: JsonReader): ?Int8 {
        try {
            if (let Some(value) <- Int8.tryParse(r.readJsonValueString())) {
                return value
            }
            throw JsonSerializationException("must be a valid Int8.")
        } catch (_) {
            throw JsonSerializationException("must be a valid Int8.")
        }
    }
}

class UInt8NullableJsonConverter <: JsonConverter<?UInt8> {
    public func read(r: JsonReader, options: JsonSerializerOptions): ?UInt8 {
        match (r.peek()) {
            case Some(JsonToken.JsonNull) =>
                r.skip()
                None
            case Some(JsonToken.JsonNumber) => readFromNumber(r)
            case Some(JsonToken.JsonString) where options
                .numberHandling
                .hasFlag(JsonNumberHandling.AllowReadingFromString) => readFromString(r.readValue<String>())
            case _ => throw JsonSerializationException("must be a valid UInt8.")
        }
    }

    public func write(w: JsonWriter, value: ?UInt8, options: JsonSerializerOptions): Unit {
        if (options.numberHandling.hasFlag(JsonNumberHandling.WriteAsString)) {
            if (let Some(v) <- value) {
                w.writeValue(v.toString())
                return
            }
            w.writeNullValue()
            return
        }
        w.writeValue(value)
    }

    private func readFromString(str: String): ?UInt8 {
        if (str.isEmpty()) {
            return None
        }
        if (let Some(value) <- UInt8.tryParse(str)) {
            return value
        } else {
            throw JsonSerializationException("must be a valid UInt8.")
        }
    }

    private func readFromNumber(r: JsonReader): ?UInt8 {
        try {
            if (let Some(value) <- UInt8.tryParse(r.readJsonValueString())) {
                return value
            }
            throw JsonSerializationException("must be a valid UInt8.")
        } catch (_) {
            throw JsonSerializationException("must be a valid UInt8.")
        }
    }
}

class Int16NullableJsonConverter <: JsonConverter<?Int16> {
    public func read(r: JsonReader, options: JsonSerializerOptions): ?Int16 {
        match (r.peek()) {
            case Some(JsonToken.JsonNull) =>
                r.skip()
                None
            case Some(JsonToken.JsonNumber) => readFromNumber(r)
            case Some(JsonToken.JsonString) where options
                .numberHandling
                .hasFlag(JsonNumberHandling.AllowReadingFromString) => readFromString(r.readValue<String>())
            case _ => throw JsonSerializationException("must be a valid Int16.")
        }
    }

    public func write(w: JsonWriter, value: ?Int16, options: JsonSerializerOptions): Unit {
        if (options.numberHandling.hasFlag(JsonNumberHandling.WriteAsString)) {
            if (let Some(v) <- value) {
                w.writeValue(v.toString())
                return
            }
            w.writeNullValue()
            return
        }
        w.writeValue(value)
    }

    private func readFromString(str: String): ?Int16 {
        if (str.isEmpty()) {
            return None
        }
        if (let Some(value) <- Int16.tryParse(str)) {
            return value
        } else {
            throw JsonSerializationException("must be a valid Int16.")
        }
    }

    private func readFromNumber(r: JsonReader): ?Int16 {
        try {
            if (let Some(value) <- Int16.tryParse(r.readJsonValueString())) {
                return value
            }
            throw JsonSerializationException("must be a valid Int16.")
        } catch (_) {
            throw JsonSerializationException("must be a valid Int16.")
        }
    }
}

class UInt16NullableJsonConverter <: JsonConverter<?UInt16> {
    public func read(r: JsonReader, options: JsonSerializerOptions): ?UInt16 {
        match (r.peek()) {
            case Some(JsonToken.JsonNull) =>
                r.skip()
                None
            case Some(JsonToken.JsonNumber) => readFromNumber(r)
            case Some(JsonToken.JsonString) where options
                .numberHandling
                .hasFlag(JsonNumberHandling.AllowReadingFromString) => readFromString(r.readValue<String>())
            case _ => throw JsonSerializationException("must be a valid UInt16.")
        }
    }

    public func write(w: JsonWriter, value: ?UInt16, options: JsonSerializerOptions): Unit {
        if (options.numberHandling.hasFlag(JsonNumberHandling.WriteAsString)) {
            if (let Some(v) <- value) {
                w.writeValue(v.toString())
                return
            }
            w.writeNullValue()
            return
        }
        w.writeValue(value)
    }

    private func readFromString(str: String): ?UInt16 {
        if (str.isEmpty()) {
            return None
        }
        if (let Some(value) <- UInt16.tryParse(str)) {
            return value
        } else {
            throw JsonSerializationException("must be a valid UInt16.")
        }
    }

    private func readFromNumber(r: JsonReader): ?UInt16 {
        try {
            if (let Some(value) <- UInt16.tryParse(r.readJsonValueString())) {
                return value
            }
            throw JsonSerializationException("must be a valid UInt16.")
        } catch (_) {
            throw JsonSerializationException("must be a valid UInt16.")
        }
    }
}

class Int32NullableJsonConverter <: JsonConverter<?Int32> {
    public func read(r: JsonReader, options: JsonSerializerOptions): ?Int32 {
        match (r.peek()) {
            case Some(JsonToken.JsonNull) =>
                r.skip()
                None
            case Some(JsonToken.JsonNumber) => readFromNumber(r)
            case Some(JsonToken.JsonString) where options
                .numberHandling
                .hasFlag(JsonNumberHandling.AllowReadingFromString) => readFromString(r.readValue<String>())
            case _ => throw JsonSerializationException("must be a valid Int32.")
        }
    }

    public func write(w: JsonWriter, value: ?Int32, options: JsonSerializerOptions): Unit {
        if (options.numberHandling.hasFlag(JsonNumberHandling.WriteAsString)) {
            if (let Some(v) <- value) {
                w.writeValue(v.toString())
                return
            }
            w.writeNullValue()
            return
        }
        w.writeValue(value)
    }

    private func readFromString(str: String): ?Int32 {
        if (str.isEmpty()) {
            return None
        }
        if (let Some(value) <- Int32.tryParse(str)) {
            return value
        } else {
            throw JsonSerializationException("must be a valid Int32.")
        }
    }

    private func readFromNumber(r: JsonReader): ?Int32 {
        try {
            if (let Some(value) <- Int32.tryParse(r.readJsonValueString())) {
                return value
            }
            throw JsonSerializationException("must be a valid Int32.")
        } catch (_) {
            throw JsonSerializationException("must be a valid Int32.")
        }
    }
}

class UInt32NullableJsonConverter <: JsonConverter<?UInt32> {
    public func read(r: JsonReader, options: JsonSerializerOptions): ?UInt32 {
        match (r.peek()) {
            case Some(JsonToken.JsonNull) =>
                r.skip()
                None
            case Some(JsonToken.JsonNumber) => readFromNumber(r)
            case Some(JsonToken.JsonString) where options
                .numberHandling
                .hasFlag(JsonNumberHandling.AllowReadingFromString) => readFromString(r.readValue<String>())
            case _ => throw JsonSerializationException("must be a valid UInt32.")
        }
    }

    public func write(w: JsonWriter, value: ?UInt32, options: JsonSerializerOptions): Unit {
        if (options.numberHandling.hasFlag(JsonNumberHandling.WriteAsString)) {
            if (let Some(v) <- value) {
                w.writeValue(v.toString())
                return
            }
            w.writeNullValue()
            return
        }
        w.writeValue(value)
    }

    private func readFromString(str: String): ?UInt32 {
        if (str.isEmpty()) {
            return None
        }
        if (let Some(value) <- UInt32.tryParse(str)) {
            return value
        } else {
            throw JsonSerializationException("must be a valid UInt32.")
        }
    }

    private func readFromNumber(r: JsonReader): ?UInt32 {
        try {
            if (let Some(value) <- UInt32.tryParse(r.readJsonValueString())) {
                return value
            }
            throw JsonSerializationException("must be a valid UInt32.")
        } catch (_) {
            throw JsonSerializationException("must be a valid UInt32.")
        }
    }
}

class Int64NullableJsonConverter <: JsonConverter<?Int64> {
    public func read(r: JsonReader, options: JsonSerializerOptions): ?Int64 {
        match (r.peek()) {
            case Some(JsonToken.JsonNull) =>
                r.skip()
                None
            case Some(JsonToken.JsonNumber) => readFromNumber(r)
            case Some(JsonToken.JsonString) where options
                .numberHandling
                .hasFlag(JsonNumberHandling.AllowReadingFromString) => readFromString(r.readValue<String>())
            case _ => throw JsonSerializationException("must be a valid Int64.")
        }
    }

    public func write(w: JsonWriter, value: ?Int64, options: JsonSerializerOptions): Unit {
        if (options.numberHandling.hasFlag(JsonNumberHandling.WriteAsString)) {
            if (let Some(v) <- value) {
                w.writeValue(v.toString())
                return
            }
            w.writeNullValue()
            return
        }
        w.writeValue(value)
    }

    private func readFromString(str: String): ?Int64 {
        if (str.isEmpty()) {
            return None
        }
        if (let Some(value) <- Int64.tryParse(str)) {
            return value
        } else {
            throw JsonSerializationException("must be a valid Int64.")
        }
    }

    private func readFromNumber(r: JsonReader): ?Int64 {
        try {
            if (let Some(value) <- Int64.tryParse(r.readJsonValueString())) {
                return value
            }
            throw JsonSerializationException("must be a valid Int64.")
        } catch (_) {
            throw JsonSerializationException("must be a valid Int64.")
        }
    }
}

class UInt64NullableJsonConverter <: JsonConverter<?UInt64> {
    public func read(r: JsonReader, options: JsonSerializerOptions): ?UInt64 {
        match (r.peek()) {
            case Some(JsonToken.JsonNull) =>
                r.skip()
                None
            case Some(JsonToken.JsonNumber) => readFromNumber(r)
            case Some(JsonToken.JsonString) where options
                .numberHandling
                .hasFlag(JsonNumberHandling.AllowReadingFromString) => readFromString(r.readValue<String>())
            case _ => throw JsonSerializationException("must be a valid UInt64.")
        }
    }

    public func write(w: JsonWriter, value: ?UInt64, options: JsonSerializerOptions): Unit {
        if (options.numberHandling.hasFlag(JsonNumberHandling.WriteAsString)) {
            if (let Some(v) <- value) {
                w.writeValue(v.toString())
                return
            }
            w.writeNullValue()
            return
        }
        w.writeValue(value)
    }

    private func readFromString(str: String): ?UInt64 {
        if (str.isEmpty()) {
            return None
        }
        if (let Some(value) <- UInt64.tryParse(str)) {
            return value
        } else {
            throw JsonSerializationException("must be a valid UInt64.")
        }
    }

    private func readFromNumber(r: JsonReader): ?UInt64 {
        try {
            if (let Some(value) <- UInt64.tryParse(r.readJsonValueString())) {
                return value
            }
            throw JsonSerializationException("must be a valid UInt64.")
        } catch (_) {
            throw JsonSerializationException("must be a valid UInt64.")
        }
    }
}

class Float16NullableJsonConverter <: JsonConverter<?Float16> {
    public func read(r: JsonReader, options: JsonSerializerOptions): ?Float16 {
        match (r.peek()) {
            case Some(JsonToken.JsonNull) =>
                r.skip()
                None
            case Some(JsonToken.JsonNumber) => readFromNumber(r)
            case Some(JsonToken.JsonString) where options
                .numberHandling
                .hasFlag(JsonNumberHandling.AllowReadingFromString) => readFromString(r.readValue<String>())
            case _ => throw JsonSerializationException("must be a valid Float16.")
        }
    }

    public func write(w: JsonWriter, value: ?Float16, options: JsonSerializerOptions): Unit {
        if (options.numberHandling.hasFlag(JsonNumberHandling.WriteAsString)) {
            if (let Some(v) <- value) {
                w.writeValue(v.toString())
                return
            }
            w.writeNullValue()
            return
        }
        w.writeValue(value)
    }

    private func readFromString(str: String): ?Float16 {
        if (str.isEmpty()) {
            return None
        }
        if (let Some(value) <- Float16.tryParse(str)) {
            return value
        } else {
            throw JsonSerializationException("must be a valid Float16.")
        }
    }

    private func readFromNumber(r: JsonReader): ?Float16 {
        try {
            return r.readValue<Float16>()
        } catch (_) {
            throw JsonSerializationException("must be a valid Float16.")
        }
    }
}

class Float32NullableJsonConverter <: JsonConverter<?Float32> {
    public func read(r: JsonReader, options: JsonSerializerOptions): ?Float32 {
        match (r.peek()) {
            case Some(JsonToken.JsonNull) =>
                r.skip()
                None
            case Some(JsonToken.JsonNumber) => readFromNumber(r)
            case Some(JsonToken.JsonString) where options
                .numberHandling
                .hasFlag(JsonNumberHandling.AllowReadingFromString) => readFromString(r.readValue<String>())
            case _ => throw JsonSerializationException("must be a valid Float32.")
        }
    }

    public func write(w: JsonWriter, value: ?Float32, options: JsonSerializerOptions): Unit {
        if (options.numberHandling.hasFlag(JsonNumberHandling.WriteAsString)) {
            if (let Some(v) <- value) {
                w.writeValue(v.toString())
                return
            }
            w.writeNullValue()
            return
        }
        w.writeValue(value)
    }

    private func readFromString(str: String): ?Float32 {
        if (str.isEmpty()) {
            return None
        }
        if (let Some(value) <- Float32.tryParse(str)) {
            return value
        } else {
            throw JsonSerializationException("must be a valid Float32.")
        }
    }

    private func readFromNumber(r: JsonReader): ?Float32 {
        try {
            return r.readValue<Float32>()
        } catch (_) {
            throw JsonSerializationException("must be a valid Float32.")
        }
    }
}

class Float64NullableJsonConverter <: JsonConverter<?Float64> {
    public func read(r: JsonReader, options: JsonSerializerOptions): ?Float64 {
        match (r.peek()) {
            case Some(JsonToken.JsonNull) =>
                r.skip()
                None
            case Some(JsonToken.JsonNumber) => readFromNumber(r)
            case Some(JsonToken.JsonString) where options
                .numberHandling
                .hasFlag(JsonNumberHandling.AllowReadingFromString) => readFromString(r.readValue<String>())
            case _ => throw JsonSerializationException("must be a valid Float64.")
        }
    }

    public func write(w: JsonWriter, value: ?Float64, options: JsonSerializerOptions): Unit {
        if (options.numberHandling.hasFlag(JsonNumberHandling.WriteAsString)) {
            if (let Some(v) <- value) {
                w.writeValue(v.toString())
                return
            }
            w.writeNullValue()
            return
        }
        w.writeValue(value)
    }

    private func readFromString(str: String): ?Float64 {
        if (str.isEmpty()) {
            return None
        }
        if (let Some(value) <- Float64.tryParse(str)) {
            return value
        } else {
            throw JsonSerializationException("must be a valid Float64.")
        }
    }

    private func readFromNumber(r: JsonReader): ?Float64 {
        try {
            return r.readValue<Float64>()
        } catch (_) {
            throw JsonSerializationException("must be a valid Float64.")
        }
    }
}

class BigIntNullableJsonConverter <: JsonConverter<?BigInt> {
    public func read(r: JsonReader, options: JsonSerializerOptions): ?BigInt {
        match (r.peek()) {
            case Some(JsonToken.JsonNull) =>
                r.skip()
                None
            case Some(JsonToken.JsonNumber) => readFromNumber(r)
            case Some(JsonToken.JsonString) => readFromString(r.readValue<String>())
            case _ => throw JsonSerializationException("must be a valid BigInt.")
        }
    }

    public func write(w: JsonWriter, value: ?BigInt, options: JsonSerializerOptions): Unit {
        if (let Some(value) <- value) {
            w.writeValue(value.toString())
            return
        }
        w.writeNullValue()
    }

    private func readFromString(str: String): ?BigInt {
        if (str.isEmpty()) {
            return None
        }
        if (let Some(value) <- BigInt.tryParse(str)) {
            return value
        } else {
            throw JsonSerializationException("must be a valid BigInt.")
        }
    }

    private func readFromNumber(r: JsonReader): ?BigInt {
        try {
            return r.readValue<BigInt>()
        } catch (_) {
            throw JsonSerializationException("must be a valid BigInt.")
        }
    }
}

class DecimalNullableJsonConverter <: JsonConverter<?Decimal> {
    public func read(r: JsonReader, options: JsonSerializerOptions): ?Decimal {
        match (r.peek()) {
            case Some(JsonToken.JsonNull) =>
                r.skip()
                None
            case Some(JsonToken.JsonNumber) => readFromNumber(r)
            case Some(JsonToken.JsonString) => readFromString(r.readValue<String>())
            case _ => throw JsonSerializationException("must be a valid Decimal.")
        }
    }

    public func write(w: JsonWriter, value: ?Decimal, options: JsonSerializerOptions): Unit {
        if (let Some(v) <- value) {
            if (options.numberHandling.hasFlag(JsonNumberHandling.WriteAsString)) {
                w.writeValue(v.toString())
                return
            }
            w.writeValue(v)
            return
        }
        w.writeNullValue()
    }

    private func readFromString(str: String): ?Decimal {
        if (str.isEmpty()) {
            return None
        }
        if (let Some(value) <- Decimal.tryParse(str)) {
            return value
        } else {
            throw JsonSerializationException("must be a valid Decimal.")
        }
    }

    private func readFromNumber(r: JsonReader): ?Decimal {
        try {
            return r.readValue<Decimal>()
        } catch (_) {
            throw JsonSerializationException("must be a valid Decimal.")
        }
    }
}

class DateTimeNullableJsonConverter <: JsonConverter<?DateTime> {
    public func read(r: JsonReader, options: JsonSerializerOptions): ?DateTime {
        match ((r.peek(), options.dateFormatString)) {
            case (Some(JsonToken.JsonNull), _) =>
                r.skip()
                None
            case (Some(JsonToken.JsonString), None) => try {
                DateTime.parse(r.readValue<String>())
            } catch (ex: Exception) {
                throw JsonSerializationException(ex.message, None, ex)
            }
            case (Some(JsonToken.JsonString), Some(format)) => try {
                DateTime.parse(r.readValue<String>(), format)
            } catch (ex: Exception) {
                throw JsonSerializationException(ex.message, None, ex)
            }
            case _ => throw JsonSerializationException("must be a valid DateTime.")
        }
    }

    public func write(w: JsonWriter, value: ?DateTime, options: JsonSerializerOptions): Unit {
        if (let Some(value) <- value) {
            if (let Some(format) <- options.dateFormatString) {
                w.writeValue(value.format(format))
            } else {
                w.writeValue(value.toString())
            }
            return
        }
        w.writeNullValue()
    }
}

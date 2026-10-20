/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_serialization

import std.io.*
import stdx.encoding.json.*

extend JsonReader {
    internal static func create(json: String): JsonReader {
        return JsonReader(ByteBuffer(json.toArray()))
    }

    internal static func create(json: Array<Byte>): JsonReader {
        return JsonReader(ByteBuffer(json))
    }

    internal static func create(stream: InputStream): JsonReader {
        return JsonReader(stream)
    }

    internal static func create(json: JsonValue): JsonReader {
        return JsonReader.create(json.toString())
    }

    internal func trySkipNull(): Bool {
        if (this.peek() == JsonToken.JsonNull) {
            this.skip()
            return true
        }
        return false
    }

    internal func readJsonValueString(): String {
        return unsafe { String.fromUtf8Unchecked(this.readValueBytes()) }
    }

    internal func readJsonValue(): JsonValue {
        return JsonValue.fromStr(this.readJsonValueString())
    }
}

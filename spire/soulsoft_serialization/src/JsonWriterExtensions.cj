/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_serialization

import std.io.*

extend JsonWriter {
    internal static func create(stream: OutputStream, options: JsonSerializerOptions): JsonWriter {
        let writer = JsonWriter(stream)
        if (options.writeIndented) {
            writer.writeConfig = WriteConfig.pretty
        }
        return writer
    }
}

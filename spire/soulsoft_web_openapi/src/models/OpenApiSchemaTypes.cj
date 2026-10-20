/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_web_openapi.models

import std.reflect.*


private let numbers = ["Float16", "Float32", "Float64", "Decimal"]
private let integers = ["Int8", "Int16", "Int32", "Int64", "UInt8", "UInt16", "UInt32", "UInt64"]

protected class OpenApiSchemaTypes {
    public static const OBJECT = "object"
    public static const STRING = "string"
    public static const ARRAY = "array"

    /**
     * @brief 将类型信息转换为 OpenAPI Schema 类型名称。
     * @param typeInfo 要转换的类型信息。
     * @return 对应的 OpenAPI Schema 类型名称。
     */
    public static func convert(typeInfo: TypeInfo): String {
        if (typeInfo.name == "Bool") {
            return "boolean"
        }
        if (typeInfo.name == "String" || typeInfo.name == "DateTime" || typeInfo.name == "BigInt" ||
            typeInfo.name == "Rune") {
            return "string"
        }
        if (numbers.contains(typeInfo.name)) {
            return "number"
        }
        if (integers.contains(typeInfo.name)) {
            return "integer"
        }
        return OpenApiSchemaTypes.OBJECT
    }
}

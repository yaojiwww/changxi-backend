// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_configuration

import stdx.encoding.json.*
import std.collection.*

class JsonConfigurationProvider <: ConfigurationProvider {
    private let _json: String

    init(json: String) {
        _json = json
    }

    private func parse(jsonValue: JsonValue, currentPath: String): Unit {
        match (jsonValue.kind()) {
            case JsonKind.JsArray => parseArray(jsonValue.asArray(), currentPath)
            case JsonKind.JsObject => parseObject(jsonValue.asObject(), currentPath)
            case _ => data[currentPath] = parseValue(jsonValue)
        }
    }

    private func parseObject(jsonObject: JsonObject, currentPath: String) {
        for ((key, value) in jsonObject.getFields()) {
            let childPath = if (currentPath.isEmpty()) {
                key
            } else {
                ConfigurationPath.combine(currentPath, key)
            }
            parse(value, childPath)
        }
    }

    private func parseArray(jsonArray: JsonArray, currentPath: String) {
        for ((i, item) in jsonArray.getItems() |> enumerate) {
            let childPath = if (currentPath.isEmpty()) {
                "${i}"
            } else {
                ConfigurationPath.combine(currentPath, "${i}")
            }
            parse(item, childPath)
        }
    }

    private func parseValue(jsonValue: JsonValue): ?String {
        match (jsonValue.kind()) {
            case JsonKind.JsBool => jsonValue.asBool().toString()
            case JsonKind.JsNull => None
            case JsonKind.JsString => jsonValue.asString().getValue()
            case JsonKind.JsInt => jsonValue.asInt().getValue().toString()
            case JsonKind.JsFloat => jsonValue.asFloat().getValue().toString()
            case _ => throw UnsupportedException("Unsupported JSON value type")
        }
    }

    public override func load() {
        let jsonValue = JsonValue.fromStr(_json)
        parse(jsonValue, "")
    }
}

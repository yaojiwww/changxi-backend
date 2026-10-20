// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_tokens

import stdx.encoding.json.*

/**
 * @brief 提供 `JsonWebKeySet` 的 JSON 序列化与反序列化能力。
 */
public class JsonWebKeySetSerializer {
    /**
     * @brief 从 JSON 字符串读取 JWK 集合。
     * @param json 包含 JWKS 数据的 JSON 字符串。
     * @param jsonWebKeySet 要写入的 JWK 集合对象。
     */
    public static func read(json: String, jsonWebKeySet: JsonWebKeySet): Unit {
        let jsonObj = JsonValue.fromStr(json).asObject()
        if (let Some(keys) <- jsonObj.get("keys").flatMap {f => f.asArray()}) {
            for (key in keys.getItems()) {
                let jsonWebKey = JsonWebKey()
                JsonWebKeySerializer.read(key, jsonWebKey)
                jsonWebKeySet.keys.add(jsonWebKey)
            }
        }
    }

    /**
     * @brief 将 JWK 集合写为 JSON 字符串。
     * @param jsonWebKeySet 要序列化的 JWK 集合。
     * @return 序列化后的 JSON 字符串。
     */
    public static func write(jsonWebKeySet: JsonWebKeySet): String {
        return writeAsJson(jsonWebKeySet).toJsonString()
    }

    /**
     * @brief 将 JWK 集合写为 JSON 对象。
     * @param jsonWebKeySet 要序列化的 JWK 集合。
     * @return 序列化后的 JSON 对象。
     */
    public static func writeAsJson(jsonWebKeySet: JsonWebKeySet): JsonObject {
        let keys = JsonArray()
        for (key in jsonWebKeySet.keys) {
            keys.add(JsonWebKeySerializer.writeAsJson(key))
        }
        let jsonObj = JsonObject()
        jsonObj.put("keys", keys)
        return jsonObj
    }
}

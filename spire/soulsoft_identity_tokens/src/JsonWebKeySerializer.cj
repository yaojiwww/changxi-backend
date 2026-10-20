// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_tokens

import std.collection.*
import stdx.encoding.json.*

/**
 * @brief 提供 `JsonWebKey` 的 JSON 序列化与反序列化能力。
 */
public class JsonWebKeySerializer {
    /**
     * @brief 从 JSON 值读取 JWK 字段。
     * @param jsonValue 包含 JWK 数据的 JSON 值。
     * @param jsonWebKey 要写入的 JWK 对象。
     */
    public static func read(jsonValue: JsonValue, jsonWebKey: JsonWebKey): Unit {
        let jsonObj = jsonValue.asObject()
        jsonWebKey.e = jsonObj.get(JsonWebKeyParameterNames.e).flatMap {f => f.asString().getValue()}
        jsonWebKey.k = jsonObj.get(JsonWebKeyParameterNames.k).flatMap {f => f.asString().getValue()}
        jsonWebKey.n = jsonObj.get(JsonWebKeyParameterNames.n).flatMap {f => f.asString().getValue()}
        jsonWebKey.d = jsonObj.get(JsonWebKeyParameterNames.d).flatMap {f => f.asString().getValue()}
        jsonWebKey.x = jsonObj.get(JsonWebKeyParameterNames.x).flatMap {f => f.asString().getValue()}
        jsonWebKey.y = jsonObj.get(JsonWebKeyParameterNames.y).flatMap {f => f.asString().getValue()}
        jsonWebKey.p = jsonObj.get(JsonWebKeyParameterNames.p).flatMap {f => f.asString().getValue()}
        jsonWebKey.q = jsonObj.get(JsonWebKeyParameterNames.q).flatMap {f => f.asString().getValue()}
        jsonWebKey.qi = jsonObj.get(JsonWebKeyParameterNames.qi).flatMap {f => f.asString().getValue()}
        jsonWebKey.dp = jsonObj.get(JsonWebKeyParameterNames.dp).flatMap {f => f.asString().getValue()}
        jsonWebKey.dq = jsonObj.get(JsonWebKeyParameterNames.dq).flatMap {f => f.asString().getValue()}
        jsonWebKey.kid = jsonObj.get(JsonWebKeyParameterNames.kid).flatMap {f => f.asString().getValue()}
        if (let Some(array) <- jsonObj.get(JsonWebKeyParameterNames.x5c).flatMap {f => f.asArray()}) {
            jsonWebKey.x5c = array.getItems() |> filterMap {f => (f as JsonString).flatMap {a => a.getValue()}} |>
                collectArray
        }
        jsonWebKey.x5t = jsonObj.get(JsonWebKeyParameterNames.x5t).flatMap {f => f.asString().getValue()}
        jsonWebKey.x5u = jsonObj.get(JsonWebKeyParameterNames.x5u).flatMap {f => f.asString().getValue()}
        jsonWebKey.crv = jsonObj.get(JsonWebKeyParameterNames.crv).flatMap {f => f.asString().getValue()}
        jsonWebKey.kty = jsonObj.get(JsonWebKeyParameterNames.kty).flatMap {f => f.asString().getValue()}
        jsonWebKey.use = jsonObj.get(JsonWebKeyParameterNames.use).flatMap {f => f.asString().getValue()}
        jsonWebKey.alg = jsonObj.get(JsonWebKeyParameterNames.alg).flatMap {f => f.asString().getValue()}
        jsonWebKey.x5tS256 = jsonObj.get(JsonWebKeyParameterNames.x5tS256).flatMap {f => f.asString().getValue()}
    }

    /**
     * @brief 从 JSON 字符串读取 JWK 字段。
     * @param json 包含 JWK 数据的 JSON 字符串。
     * @param jsonWebKey 要写入的 JWK 对象。
     */
    public static func read(json: String, jsonWebKey: JsonWebKey): Unit {
        read(JsonValue.fromStr(json), jsonWebKey)
    }

    /**
     * @brief 将 JWK 写为 JSON 对象。
     * @param jsonWebKey 要序列化的 JWK。
     * @return 序列化后的 JSON 对象。
     */
    public static func writeAsJson(jsonWebKey: JsonWebKey): JsonObject {
        let obj = JsonObject()
        if (let Some(e) <- jsonWebKey.e) {
            obj.put(JsonWebKeyParameterNames.e, JsonString(e))
        }
        if (let Some(k) <- jsonWebKey.k) {
            obj.put(JsonWebKeyParameterNames.k, JsonString(k))
        }
        if (let Some(n) <- jsonWebKey.n) {
            obj.put(JsonWebKeyParameterNames.n, JsonString(n))
        }
        if (let Some(d) <- jsonWebKey.d) {
            obj.put(JsonWebKeyParameterNames.d, JsonString(d))
        }
        if (let Some(x) <- jsonWebKey.x) {
            obj.put(JsonWebKeyParameterNames.x, JsonString(x))
        }
        if (let Some(y) <- jsonWebKey.y) {
            obj.put(JsonWebKeyParameterNames.y, JsonString(y))
        }
        if (let Some(p) <- jsonWebKey.p) {
            obj.put(JsonWebKeyParameterNames.p, JsonString(p))
        }
        if (let Some(q) <- jsonWebKey.q) {
            obj.put(JsonWebKeyParameterNames.q, JsonString(q))
        }
        if (let Some(qi) <- jsonWebKey.qi) {
            obj.put(JsonWebKeyParameterNames.qi, JsonString(qi))
        }
        if (let Some(dp) <- jsonWebKey.dp) {
            obj.put(JsonWebKeyParameterNames.dp, JsonString(dp))
        }
        if (let Some(dq) <- jsonWebKey.dq) {
            obj.put(JsonWebKeyParameterNames.dq, JsonString(dq))
        }
        if (let Some(kid) <- jsonWebKey.kid) {
            obj.put(JsonWebKeyParameterNames.kid, JsonString(kid))
        }
        if (jsonWebKey.x5c.size > 0) {
            let x5c = jsonWebKey.x5c |> map {f => JsonString(f)} |> filterMap {f => f as JsonValue} |> collectArrayList
            obj.put(JsonWebKeyParameterNames.x5c, JsonArray(x5c))
        }
        if (let Some(x5t) <- jsonWebKey.x5t) {
            obj.put(JsonWebKeyParameterNames.x5t, JsonString(x5t))
        }
        if (let Some(x5u) <- jsonWebKey.x5u) {
            obj.put(JsonWebKeyParameterNames.x5u, JsonString(x5u))
        }
        if (let Some(crv) <- jsonWebKey.crv) {
            obj.put(JsonWebKeyParameterNames.crv, JsonString(crv))
        }
        if (let Some(kty) <- jsonWebKey.kty) {
            obj.put(JsonWebKeyParameterNames.kty, JsonString(kty))
        }
        if (let Some(use) <- jsonWebKey.use) {
            obj.put(JsonWebKeyParameterNames.use, JsonString(use))
        }
        if (let Some(alg) <- jsonWebKey.alg) {
            obj.put(JsonWebKeyParameterNames.alg, JsonString(alg))
        }
        if (let Some(x5tS256) <- jsonWebKey.x5tS256) {
            obj.put(JsonWebKeyParameterNames.x5tS256, JsonString(x5tS256))
        }
        return obj
    }

    /**
     * @brief 将 JWK 写为 JSON 字符串。
     * @param jsonWebKey 要序列化的 JWK。
     * @return 序列化后的 JSON 字符串。
     */
    public static func write(jsonWebKey: JsonWebKey): String {
        return writeAsJson(jsonWebKey).toJsonString()
    }
}

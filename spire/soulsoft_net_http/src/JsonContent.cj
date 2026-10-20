// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_net_http

import soulsoft_serialization.*

/**
 * @brief 表示 JSON 格式的 HTTP 内容。
 */
public class JsonContent <: ByteArrayContent {
    private init(json: String) {
        super(json.toArray())
        headers.add(HeaderNames.ContentType, "application/json; charset=utf-8")
    }

    /**
     * @brief 使用可序列化对象创建 JSON 内容。
     * @param data 要序列化的对象。
     * @return 创建出的 JSON 内容对象。
     */
    public static func create<T>(data: T): JsonContent where T <: ISerializable {
        let json = JsonSerializer.serialize(data)
        return JsonContent(json)
    }

    /**
     * @brief 使用指定序列化选项创建 JSON 内容。
     * @param data 要序列化的对象。
     * @param options JSON 序列化选项。
     * @return 创建出的 JSON 内容对象。
     */
    public static func create<T>(data: T, options: JsonSerializerOptions): JsonContent where T <: ISerializable {
        let json = JsonSerializer.serialize(data, options)
        return JsonContent(json)
    }

    /**
     * @brief 使用现成 JSON 字符串创建内容对象。
     * @param json JSON 字符串。
     * @return 创建出的 JSON 内容对象。
     */
    public static func create(json: String): JsonContent {
        return JsonContent(json)
    }
}

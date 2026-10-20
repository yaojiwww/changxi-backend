// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_web_openapi.services

import std.io.*
import stdx.encoding.json.stream.*
import soulsoft_web_openapi.interfaces.*

/**
 * @brief 提供基于 JSON 的 OpenAPI 写入器实现。
 */
public class JsonOpenApiWriter <: IOpenApiWriter {
    private let _writer: JsonWriter

    /**
     * @brief 创建 JSON OpenAPI 写入器实例。
     * @param stream 输出流。
     */
    public init(stream: OutputStream) {
        _writer = JsonWriter(stream)
    }

    /**
     * @brief 开始写入对象。
     */
    public func startObject(): Unit {
        _writer.startObject()
    }

    /**
     * @brief 结束写入对象。
     */
    public func endObject(): Unit {
        _writer.endObject()
    }

    /**
     * @brief 开始写入数组。
     */
    public func startArray(): Unit {
        _writer.startArray()
    }

    /**
     * @brief 结束写入数组。
     */
    public func endArray(): Unit {
        _writer.endArray()
    }

    /**
     * @brief 写入属性名称。
     * @param name 要写入的属性名称。
     */
    public func writeName(name: String): Unit {
        _writer.writeName(name)
    }

    /**
     * @brief 写入字符串值。
     * @param value 要写入的字符串值。
     */
    public func writeValue(value: String): Unit {
        _writer.writeValue(value)
    }

    /**
     * @brief 写入整数值。
     * @param value 要写入的整数值。
     */
    public func writeValue(value: Int64): Unit {
        _writer.writeValue(value)
    }

    /**
     * @brief 写入布尔值。
     * @param value 要写入的布尔值。
     */
    public func writeValue(value: Bool): Unit {
        _writer.writeValue(value)
    }

    /**
     * @brief 刷新当前写入器。
     */
    public func flush(): Unit {
        _writer.flush()
    }
}

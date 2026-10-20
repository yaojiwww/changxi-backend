// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_web_openapi.models

import std.collection.*

/**
 * @brief 表示 OpenAPI 可扩展字典基类。
 */
public abstract class OpenApiExtensibleDictionary<T> <: IOpenApiSerializable where T <: IOpenApiSerializable {
    private let _items: HashMap<String, T>

    /**
     * @brief 创建一个空的 OpenAPI 可扩展字典。
     */
    protected init() {
        this(HashMap<String, T>())
    }

    /**
     * @brief 使用已有项创建 OpenAPI 可扩展字典。
     * @param items 初始字典项集合。
     */
    protected init(items: HashMap<String, T>) {
        _items = items
    }

    /**
     * @brief 返回内部字典项集合。
     * @return 当前字典中的所有项。
     */
    protected prop items: HashMap<String, T> {
        get() {
            _items
        }
    }

    /**
     * @brief 添加字典项。
     * @param key 字典键。
     * @param value 字典值。
     */
    public func add(key: String, value: T): Unit {
        _items.add(key, value)
    }

    /**
     * @brief 检查是否包含指定键。
     * @param key 要检查的字典键。
     * @return 如果包含指定键则返回 `true`。
     */
    public func contains(key: String): Bool {
        _items.contains(key)
    }

    /**
     * @brief 通过键读取字典值。
     * @param key 要读取的字典键。
     * @return 对应的字典值。
     */
    public operator func [](key: String): T {
        _items[key]
    }

    /**
     * @brief 通过键设置字典值。
     * @param key 要设置的字典键。
     * @param value 要设置的字典值。
     */
    public operator func [](key: String, value!: T): Unit {
        _items[key] = value
    }

    /**
     * @brief 按 OpenAPI V3 格式写出当前字典对象。
     * @param writer OpenAPI 写入器。
     */
    public func serializeAsV3(writer: IOpenApiWriter): Unit {
        writer.startObject()
        for ((key, value) in _items) {
            writer.writeName(key)
            value.serializeAsV3(writer)
        }
        writer.endObject()
    }

    /**
     * @brief 检查当前字典是否为空。
     * @return 如果当前字典没有任何项则返回 `true`。
     */
    public func isEmpty(): Bool {
        return _items.isEmpty()
    }
}

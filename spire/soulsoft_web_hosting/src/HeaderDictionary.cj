// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_hosting

import stdx.net.http.*
import std.collection.*

protected class HeaderDictionary <: IHeaderDictionary {
    private let _headers: HttpHeaders
    // 仅响应头场景会注入该 guard；请求头默认不受 started 语义约束。
    private var _ensureMutable: ?() -> Unit = None

    /**
     * @brief 创建一个空的请求头字典。
     */
    public init() {
        this(HttpHeaders())
    }

    /**
     * @brief 使用指定请求头集合创建字典。
     * @param headers 要包装的底层请求头集合。
     */
    public init(headers: HttpHeaders) {
        _headers = headers
    }

    /**
     * @brief 返回当前请求头数量。
     * @return 当前请求头数量。
     */
    public prop size: Int64 {
        get() {
            _headers |> count
        }
    }

    /**
     * @brief 向指定名称的请求头追加值。
     * @param name 请求头名称。
     * @param values 要追加的请求头值集合。
     */
    public func add(name: String, values: StringValues): Unit {
        ensureMutable()
        for (value in values) {
            _headers.add(name, value)
        }
    }

    /**
     * @brief 移除指定名称的请求头。
     * @param name 要移除的请求头名称。
     */
    public func remove(name: String): Unit {
        ensureMutable()
        _headers.del(name)
    }

    /**
     * @brief 检查是否存在指定名称的请求头。
     * @param name 要检查的请求头名称。
     * @return 如果存在则返回 true，否则返回 false。
     */
    public func contains(name: String): Bool {
        _headers.getFirst(name).isSome()
    }

    /**
     * @brief 获取指定名称的所有请求头值。
     * @param name 要获取的请求头名称。
     * @return 指定名称的所有请求头值。
     */
    public operator func [](name: String): StringValues {
        _headers.get(name).toArray()
    }

    /**
     * @brief 设置指定名称的请求头值集合。
     * @param name 要设置的请求头名称。
     * @param value 要写入的请求头值集合。
     */
    public operator func [](name: String, value!: StringValues): Unit {
        ensureMutable()
        // 先清空该 header 的已有值，再逐一追加，避免 set 的"替换"语义导致只保留最后一个值
        _headers.del(name)
        for (pattern in value) {
            _headers.add(name, pattern)
        }
    }

    /**
     * @brief 获取指定名称的第一个请求头值。
     * @param name 要获取的请求头名称。
     * @return 指定名称的第一个请求头值；如果不存在则返回空。
     */
    public func get(name: String): ?String {
        _headers.getFirst(name)
    }

    /**
     * @brief 获取指定名称的所有请求头值。
     * @param name 要获取的请求头名称。
     * @return 指定名称的所有请求头值集合。
     */
    public func getAll(name: String): Collection<String> {
        _headers.get(name)
    }

    /**
     * @brief 检查请求头字典是否为空。
     * @return 如果请求头字典为空则返回 true，否则返回 false。
     */
    public func isEmpty(): Bool {
        _headers.isEmpty()
    }

    /**
     * @brief 返回请求头字典的迭代器。
     * @return 当前请求头字典的迭代器。
     */
    public func iterator(): Iterator<(String, Collection<String>)> {
        return _headers.iterator()
    }

    private func ensureMutable(): Unit {
        _ensureMutable?()
    }

    /**
     * @brief 为写操作安装可选保护逻辑。
     * @details 响应头会在 response started 后通过该 guard 阻止继续修改；请求头不设置该 guard。
     */
    internal func setMutationGuard(guard: () -> Unit): Unit {
        _ensureMutable = guard
    }
}

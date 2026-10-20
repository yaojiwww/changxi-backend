// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_net_http

import stdx.net.http.*

/**
 * @brief 表示 HTTP 头集合的抽象基类。
 */
public abstract class HttpHeadersBase <: Iterable<(String, Collection<String>)> {
    private let _headers: HttpHeaders

    /**
     * @brief 使用底层头集合创建头基类实例。
     * @param headers 底层 HTTP 头集合。
     */
    protected init(headers: HttpHeaders) {
        _headers = headers
    }

    /**
     * @brief 获取头集合迭代器。
     * @return 当前头集合的迭代器。
     */
    public func iterator(): Iterator<(String, Collection<String>)> {
        _headers.iterator()
    }

    /**
     * @brief 添加一个头值。
     * @param name 头名称。
     * @param value 头值。
     * @return 无返回值。
     */
    public open func add(name: String, value: String): Unit {
        _headers.add(name, value)
    }

    /**
     * @brief 尝试绕过头类型校验直接写入头值。
     * @param name 头名称。
     * @param value 头值。
     * @return 当前实现始终返回 `true`。
     */
    public open func tryAddWithoutValidation(name: String, value: String): Bool {
        _headers.add(name, value)
        return true
    }

    /**
     * @brief 检查是否包含指定头。
     * @param name 头名称。
     * @return 存在该头时返回 `true`。
     */
    public func contains(name: String): Bool {
        return _headers.getFirst(name).isSome()
    }

    /**
     * @brief 设置指定头值。
     * @param name 头名称。
     * @param value 头值。
     * @return 无返回值。
     */
    public open func set(name: String, value: String): Unit {
        _headers.set(name, value)
    }

    /**
     * @brief 删除指定头。
     * @param name 头名称。
     * @return 无返回值。
     */
    public func remove(name: String): Unit {
        _headers.del(name)
    }

    /**
     * @brief 获取指定头的全部值。
     * @param name 头名称。
     * @return 指定头的值集合；不存在时返回 `None`。
     */
    public func get(name: String): ?Collection<String> {
        _headers.get(name)
    }

    /**
     * @brief 获取指定头的第一个值。
     * @param name 头名称。
     * @return 指定头的第一个值；不存在时返回 `None`。
     */
    public func getFirst(name: String): ?String {
        _headers.getFirst(name)
    }
}

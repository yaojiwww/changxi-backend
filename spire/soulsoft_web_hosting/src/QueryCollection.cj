// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_hosting

import std.collection.*
import stdx.encoding.url.*

protected class QueryCollection <: IQueryCollection {
    private let _form: Form
    private let _keys = HashSet<String>()

    /**
     * @brief 创建一个空的查询参数集合。
     */
    public init() {
        this(Form())
    }

    /**
     * @brief 使用指定查询表单创建查询参数集合。
     * @param form 底层查询表单对象。
     */
    public init(form: Form) {
        _form = form
    }

    /**
     * @brief 返回当前查询参数中的键集合。
     * @return 当前查询参数中的键集合。
     */
    public func keys(): HashSet<String> {
        _keys
    }

    /**
     * @brief 向查询参数集合追加键值对。
     * @param name 参数名称。
     * @param value 要追加的参数值。
     */
    public func add(name: String, value: String): Unit {
        // 由于form暂时不支持keys
        _keys.add(name)
        _form.add(name, value)
    }

    /**
     * @brief 检查查询参数集合是否为空。
     * @return 如果查询参数集合为空则返回 true，否则返回 false。
     */
    public func isEmpty(): Bool {
        _form.isEmpty()
    }

    /**
     * @brief 获取指定参数的第一个值。
     * @param name 参数名称。
     * @return 指定参数的第一个值；如果不存在则返回空。
     */
    public func get(name: String): ?String {
        return _form.get(name)
    }

    /**
     * @brief 获取指定参数的所有值。
     * @param name 参数名称。
     * @return 指定参数的所有值集合。
     */
    public func getAll(name: String): ArrayList<String> {
        return _form.getAll(name)
    }
}

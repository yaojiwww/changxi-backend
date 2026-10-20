// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_hosting

import std.reflect.*
import std.collection.*
import soulsoft_web_http.*

class FeatureCollection <: IFeatureCollection {
    private let _items = HashMap<TypeInfo, Any>()

    /**
     * @brief 按类型获取已注册的功能实例。
     * @return 返回匹配类型的功能实例；如果不存在则返回空。
     */
    public func get<T>(): ?T {
        let typeInfo = TypeInfo.of<T>()
        if (_items.contains(typeInfo)) {
            return _items[typeInfo] as T
        }
        return None
    }

    /**
     * @brief 按类型注册功能实例。
     * @param value 要注册的功能实例。
     */
    public func set<T>(value: T): Unit {
        let typeInfo = TypeInfo.of<T>()
        _items[typeInfo] = value
    }

    /**
     * @brief 返回功能集合的迭代器。
     * @return 当前功能集合的迭代器。
     */
    public func iterator(): Iterator<(TypeInfo, Any)> {
        _items.iterator()
    }
}

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_http

import std.collection.*

/**
 * @brief 表示路由参数键值对集合。
 */
public class RouteValueDictionary <: Collection<(String, String)> & IValueProvider {
    private let _items: HashMap<String, String>

    /**
     * @brief 创建一个空的路由值字典。
     */
    public init() {
        _items = HashMap<String, String>()
    }

    /**
     * @brief 使用指定键值对集合创建路由值字典。
     * @param items 初始路由值集合。
     */
    public init(items: Collection<(String, String)>) {
        _items = HashMap<String, String>(items)
    }

    /**
     * @brief 获取指定键对应的路由值。
     * @param key 路由键。
     * @return 指定键对应的路由值。
     */
    public operator func [](key: String): String {
        _items[key]
    }

    /**
     * @brief 获取指定键对应的路由值。
     * @param key 路由键。
     * @return 指定键对应的路由值；如果不存在则返回空。
     */
    public func get(key: String): ?String {
        return _items.get(key)
    }

    /**
     * @brief 获取指定键对应的所有路由值。
     * @param key 路由键。
     * @return 指定键对应的所有路由值集合。
     */
    public func getAll(key: String): Collection<String> {
        if (let Some(v) <- get(key)) {
            return [v]
        }
        return []
    }

    /**
     * @brief 检查是否存在指定路由键。
     * @param key 路由键。
     * @return 如果存在则返回 true，否则返回 false。
     */
    public func contains(key: String): Bool {
        return _items.contains(key)
    }

    /**
     * @brief 检查是否同时存在指定键集合。
     * @param all 要检查的路由键集合。
     * @return 如果全部存在则返回 true，否则返回 false。
     */
    public func contains(all!: Collection<String>): Bool {
        return _items.contains(all: all)
    }

    /**
     * @brief 返回当前字典中的所有路由键。
     * @return 当前字典中的所有路由键。
     */
    public func keys(): EquatableCollection<String> {
        _items.keys()
    }

    /**
     * @brief 返回当前字典中的所有路由值。
     * @return 当前字典中的所有路由值。
     */
    public func values(): Collection<String> {
        _items.values()
    }

    /**
     * @brief 检查当前字典是否为空。
     * @return 如果当前字典为空则返回 true，否则返回 false。
     */
    public func isEmpty(): Bool {
        _items.isEmpty()
    }

    /**
     * @brief 返回当前字典的迭代器。
     * @return 当前字典的迭代器。
     */
    public func iterator(): Iterator<(String, String)> {
        _items.iterator()
    }

    /**
     * @brief 返回当前字典中的键值对数量。
     * @return 当前字典中的键值对数量。
     */
    public prop size: Int64 {
        get() {
            _items.size
        }
    }

    /**
     * @brief 设置指定键对应的路由值。
     * @param key 路由键。
     * @param value 要设置的路由值。
     */
    public operator func [](key: String, value!: String): Unit {
        _items[key] = value
    }

    /**
     * @brief 添加一个路由键值对。
     * @param key 路由键。
     * @param value 路由值。
     * @return 如果存在旧值则返回旧值，否则返回空。
     */
    public func add(key: String, value: String): ?String {
        _items.add(key, value)
    }

    /**
     * @brief 批量添加路由键值对。
     * @param all 要添加的路由键值对集合。
     */
    public func add(all!: Collection<(String, String)>): Unit {
        _items.add(all: all)
    }

    /**
     * @brief 在键不存在时添加路由键值对。
     * @param key 路由键。
     * @param value 路由值。
     * @return 如果存在旧值则返回旧值，否则返回空。
     */
    public func addIfAbsent(key: String, value: String): ?String {
        _items.addIfAbsent(key, value)
    }

    /**
     * @brief 移除指定键对应的路由值。
     * @param key 要移除的路由键。
     * @return 如果存在旧值则返回旧值，否则返回空。
     */
    public func remove(key: String): ?String {
        _items.remove(key)
    }

    /**
     * @brief 批量移除指定键集合。
     * @param all 要移除的路由键集合。
     */
    public func remove(all!: Collection<String>): Unit {
        _items.remove(all: all)
    }

    /**
     * @brief 按条件移除路由键值对。
     * @param predicate 用于判断是否移除的条件函数。
     */
    public func removeIf(predicate: (String, String) -> Bool): Unit {
        _items.removeIf(predicate)
    }

    /**
     * @brief 替换指定键对应的路由值。
     * @param key 路由键。
     * @param value 新的路由值。
     * @return 如果存在旧值则返回旧值，否则返回空。
     */
    public func replace(key: String, value: String): ?String {
        _items.replace(key, value)
    }

    /**
     * @brief 清空当前路由值字典。
     */
    public func clear(): Unit {
        _items.clear()
    }

    /**
     * @brief 返回指定键的条目视图。
     * @param k 路由键。
     * @return 指定键的条目视图。
     */
    public func entryView(k: String): MapEntryView<String, String> {
        _items.entryView(k)
    }

    /**
     * @brief 从数组创建路由值字典。
     * @param items 路由键值对数组。
     * @return 创建后的路由值字典。
     */
    public static func fromArray(items: Array<(String, String)>): RouteValueDictionary {
        return RouteValueDictionary(items |> filter {f => !f[0].isEmpty()} |> collectArray)
    }
}

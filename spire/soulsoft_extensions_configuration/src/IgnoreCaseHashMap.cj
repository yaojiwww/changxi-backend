/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_extensions_configuration

import std.collection.*

class IgnoreCaseHashMap<TValue> <: Map<String, TValue> {
    private let _items: HashMap<String, TValue>

    init() {
        _items = HashMap<String, TValue>()
    }

    init(capacity: Int64) {
        _items = HashMap<String, TValue>(capacity)
    }

    public operator func [](key: String) {
        _items[key.toLowerStr()]
    }

    public operator func [](key: String, value!: TValue) {
        _items[key.toLowerStr()] = value
    }

    /**
     * @brief 添加一个键值对并以不区分大小写的方式保存键。
     * @param key 要添加的键。
     * @param value 要添加的值。
     * @return 如果已存在同名键则返回旧值，否则返回 None。
     */
    public func add(key: String, value: TValue): ?TValue {
        _items.add(key.toLowerStr(), value)
    }

    /**
     * @brief 批量添加键值对并以不区分大小写的方式保存键。
     * @param all 要添加的键值对集合。
     */
    public func add(all!: Collection<(String, TValue)>): Unit {
        _items.add(all: all |> map {f => (f[0].toLowerStr(), f[1])} |> collectArray)
    }

    /**
     * @brief 删除指定键对应的项。
     * @param key 要删除的键。
     * @return 如果存在被删除的值则返回该值，否则返回 None。
     */
    public func remove(key: String): ?TValue {
        _items.remove(key.toLowerStr())
    }

    /**
     * @brief 批量删除指定键集合对应的项。
     * @param all 要删除的键集合。
     */
    public func remove(all!: Collection<String>): Unit {
        _items.remove(all: all |> map {key => key.toLowerStr()} |> collectArray)
    }

    /**
     * @brief 删除满足条件的项。
     * @param predicate 用于判断是否删除项的条件。
     */
    public func removeIf(predicate: (String, TValue) -> Bool): Unit {
        _items.removeIf(predicate)
    }

    /**
     * @brief 清空当前映射中的全部项。
     */
    public func clear(): Unit {
        _items.clear()
    }

    /**
     * @brief 检查是否包含指定键。
     * @param key 要检查的键。
     * @return 如果包含指定键则返回 true，否则返回 false。
     */
    public func contains(key: String): Bool {
        _items.contains(key.toLowerStr())
    }

    /**
     * @brief 检查是否包含指定键集合中的所有键。
     * @param all 要检查的键集合。
     * @return 如果包含指定键集合中的所有键则返回 true，否则返回 false。
     */
    public func contains(all!: Collection<String>): Bool {
        _items.contains(all: all |> map {key => key.toLowerStr()} |> collectArray)
    }

    /**
     * @brief 返回指定键对应的条目视图。
     * @param key 要查询的键。
     * @return 返回指定键对应的条目视图。
     */
    public func entryView(key: String): MapEntryView<String, TValue> {
        _items.entryView(key.toLowerStr())
    }

    /**
     * @brief 替换指定键对应的值。
     * @param key 要替换的键。
     * @param value 替换后的值。
     * @return 如果存在被替换的旧值则返回该值，否则返回 None。
     */
    public func replace(key: String, value: TValue): ?TValue {
        _items.replace(key.toLowerStr(), value)
    }

    /**
     * @brief 返回指定键对应的值。
     * @param key 要查询的键。
     * @return 返回指定键对应的值；如果不存在则返回 None。
     */
    public func get(key: String): ?TValue {
        _items.get(key.toLowerStr())
    }

    /**
     * @brief 返回当前映射中的全部键。
     * @return 返回当前映射中的全部键。
     */
    public func keys(): EquatableCollection<String> {
        _items.keys()
    }

    /**
     * @brief 返回当前映射中的全部值。
     * @return 返回当前映射中的全部值。
     */
    public func values(): Collection<TValue> {
        _items.values()
    }

    /**
     * @brief 检查当前映射是否为空。
     * @return 如果当前映射为空则返回 true，否则返回 false。
     */
    public func isEmpty(): Bool {
        _items.isEmpty()
    }

    /**
     * @brief 返回当前映射的迭代器。
     * @return 返回当前映射的迭代器。
     */
    public func iterator(): Iterator<(String, TValue)> {
        _items.iterator()
    }

    /**
     * @brief 返回当前映射中的项数量。
     * @return 返回当前映射中的项数量。
     */
    public prop size: Int64 {
        get() {
            _items.size
        }
    }
}

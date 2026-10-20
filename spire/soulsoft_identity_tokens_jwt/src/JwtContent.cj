// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_tokens_jwt

import std.time.*
import std.convert.*
import std.collection.*
import std.math.numeric.*
import soulsoft_identity_claims.*
import soulsoft_identity_tokens.*

/**
 * @brief 表示 JWT 头部或载荷的键值内容基类。
 */
public abstract class JwtContent <: Map<String, Any> {
    private let _items = HashMap<String, Any>()

    /**
     * @brief 按名称读取内容项。
     * @param name 要读取的键名。
     * @return 对应的内容值。
     * @throws NoneValueException 当指定键名不存在时抛出。
     */
    public operator func [](name: String): Any {
        _items[name]
    }

    /**
     * @brief 按名称写入内容项。
     * @param name 要写入的键名。
     * @param value 要写入的值。
     * @return 无返回值。
     */
    public operator func [](name: String, value!: Any): Unit {
        _items[name] = value
    }

    /**
     * @brief 添加单个内容项。
     * @param name 要添加的键名。
     * @param value 要添加的值。
     * @return 被替换或聚合前的旧值；首次添加时返回 `None`。
     */
    public func add(name: String, value: Any): ?Any {
        if (_items.contains(name)) {
            let oldValue = _items[name]
            if (let list: ArrayList<Any> <- oldValue) {
                list.add(value)
                return oldValue
            } else {
                let list = ArrayList<Any>()
                list.add(oldValue)
                list.add(value)
                return _items.add(name, list)
            }
        } else {
            return _items.add(name, value)
        }
    }

    /**
     * @brief 批量添加内容项。
     * @param all 要添加的键值集合。
     * @return 无返回值。
     */
    public func add(all!: Collection<(String, Any)>): Unit {
        for ((key, value) in all) {
            add(key, value)
        }
    }

    /**
     * @brief 清空全部内容项。
     * @return 无返回值。
     */
    public func clear(): Unit {
        _items.clear()
    }

    /**
     * @brief 检查是否包含指定键名。
     * @param name 要检查的键名。
     * @return 包含该键名时返回 `true`。
     */
    public func contains(name: String): Bool {
        _items.contains(name)
    }

    /**
     * @brief 检查是否同时包含指定键名集合。
     * @param all 要检查的键名集合。
     * @return 全部键名都存在时返回 `true`。
     */
    public func contains(all!: Collection<String>): Bool {
        _items.contains(all: all)
    }

    /**
     * @brief 获取指定键的条目视图。
     * @param name 要查看的键名。
     * @return 对应键的条目视图。
     */
    public func entryView(name: String): MapEntryView<String, Any> {
        _items.entryView(name)
    }

    /**
     * @brief 按名称获取内容值。
     * @param name 要获取的键名。
     * @return 对应的内容值；不存在时返回 `None`。
     */
    public func get(name: String): ?Any {
        _items.get(name)
    }

    /**
     * @brief 检查当前内容是否为空。
     * @return 没有任何内容项时返回 `true`。
     */
    public func isEmpty(): Bool {
        _items.isEmpty()
    }

    /**
     * @brief 获取内容项迭代器。
     * @return 当前内容项的迭代器。
     */
    public func iterator(): Iterator<(String, Any)> {
        _items.iterator()
    }

    /**
     * @brief 删除指定键名的内容项。
     * @param name 要删除的键名。
     * @return 被删除的值；不存在时返回 `None`。
     */
    public func remove(name: String): ?Any {
        _items.remove(name)
    }

    /**
     * @brief 批量删除指定键名集合。
     * @param all 要删除的键名集合。
     * @return 无返回值。
     */
    public func remove(all!: Collection<String>): Unit {
        _items.remove(all: all)
    }

    /**
     * @brief 删除满足条件的内容项。
     * @param predicate 用于判断是否删除的条件函数。
     * @return 无返回值。
     */
    public func removeIf(predicate: (String, Any) -> Bool): Unit {
        _items.removeIf(predicate)
    }

    /**
     * @brief 获取全部键名集合。
     * @return 当前内容的键名集合视图。
     */
    public func keys(): EquatableCollection<String> {
        _items.keys()
    }

    /**
     * @brief 获取内容项数量。
     * @return 当前内容项总数。
     */
    public prop size: Int64 {
        get() {
            _items.size
        }
    }

    /**
     * @brief 获取全部内容值集合。
     * @return 当前内容的值集合视图。
     */
    public func values(): Collection<Any> {
        _items.values()
    }

    /**
     * @brief 将当前内容序列化为 JSON 字符串。
     * @return 序列化后的 JSON 字符串。
     */
    public func serializeToJson(): String {
        return JwtSerializer.serialize(this._items)
    }

    /**
     * @brief 将当前内容编码为 Base64Url 字符串。
     * @return Base64Url 编码后的内容字符串。
     */
    public func base64UrlEncode(): String {
        Base64UrlEncoder.encode(serializeToJson())
    }

    /**
     * @brief 将当前内容转换为声明集合。
     * @return 转换得到的声明列表。
     */
    public func toClaims(): ArrayList<Claim> {
        let claims = ArrayList<Claim>()
        for ((key, value) in this) {
            if (let list: ArrayList<Any> <- value) {
                for (value in list) {
                    if (let Some(claim) <- toClaim(key, value)) {
                        claims.add(claim)
                    }
                }
            } else {
                if (let Some(claim) <- toClaim(key, value)) {
                    claims.add(claim)
                }
            }
        }
        return claims
    }

    private static func toClaim(name: String, value: Any): ?Claim {
        if (let data: String <- value) {
            return Claim(name, data)
        } else if (let data: UInt8 <- value) {
            return Claim(name, data.toString(), ClaimValueTypes.Integer)
        } else if (let data: UInt16 <- value) {
            return Claim(name, data.toString(), ClaimValueTypes.Integer)
        } else if (let data: UInt32 <- value) {
            return Claim(name, data.toString(), ClaimValueTypes.Integer)
        } else if (let data: UInt64 <- value) {
            return Claim(name, data.toString(), ClaimValueTypes.Integer)
        } else if (let data: Int8 <- value) {
            return Claim(name, data.toString(), ClaimValueTypes.Integer)
        } else if (let data: Int16 <- value) {
            return Claim(name, data.toString(), ClaimValueTypes.Integer)
        } else if (let data: Int32 <- value) {
            return Claim(name, data.toString(), ClaimValueTypes.Integer)
        } else if (let data: Int64 <- value) {
            return Claim(name, data.toString(), ClaimValueTypes.Integer)
        } else if (let data: Bool <- value) {
            return Claim(name, data.toString(), ClaimValueTypes.Boolean)
        } else if (let data: Decimal <- value) {
            return Claim(name, data.toString(), ClaimValueTypes.Double)
        } else if (let data: BigInt <- value) {
            return Claim(name, data.toString(), ClaimValueTypes.Integer)
        } else if (let data: DateTime <- value) {
            return Claim(name, data.toString(), ClaimValueTypes.DateTime)
        } else if (let data: Float16 <- value) {
            return Claim(name, data.toString(), ClaimValueTypes.Double)
        } else if (let data: Float32 <- value) {
            return Claim(name, data.toString(), ClaimValueTypes.Double)
        } else if (let data: Float64 <- value) {
            return Claim(name, data.toString(), ClaimValueTypes.Double)
        }
        return None
    }
}

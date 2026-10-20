// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_authentication

import std.time.*
import std.convert.*
import std.collection.*
import stdx.serialization.serialization.*

private let IssuedUtcKey = ".issued"
private let RefreshKey = ".refresh"
private let ExpiresUtcKey = ".expires"
private let RedirectUriKey = '.redirect'
private let IsPersistentKey = ".persistent"
private let TokenNameDelimiter = '|'
private let TokenKeyPrefix = ".Token."
private let TokenNamesKey = ".TokenNames"

/**
 * @brief 保存身份验证流程中的附加属性。
 */
public class AuthenticationProperties <: Serializable<AuthenticationProperties> {
    private let _items: HashMap<String, String>

    /**
     * @brief 使用已有属性字典创建身份验证属性。
     * @param items 属性字典。
     */
    public init(items: HashMap<String, String>) {
        _items = items
    }

    /**
     * @brief 创建一个空的身份验证属性集合。
     */
    public init() {
        this(HashMap<String, String>())
    }

    /**
     * @brief 返回底层属性字典。
     * @return 属性字典。
     */
    public prop items: HashMap<String, String> {
        get() {
            _items
        }
    }

    /**
     * @brief 获取或设置重定向地址。
     */
    public mut prop redirectUri: ?String {
        get() {
            getString(RedirectUriKey)
        }
        set(value) {
            setString(RedirectUriKey, value)
        }
    }

    /**
     * @brief 获取或设置是否持久化登录状态。
     */
    public mut prop isPersistent: Bool {
        get() {
            getString(IsPersistentKey).isSome()
        }
        set(value) {
            setString(IsPersistentKey, if (value) {
                String.empty
            } else {
                None
            })
        }
    }

    /**
     * @brief 获取或设置是否允许刷新。
     */
    public mut prop allowRefresh: ?Bool {
        get() {
            getBool(RefreshKey)
        }
        set(value) {
            setBool(RefreshKey, value)
        }
    }

    /**
     * @brief 获取或设置票据签发时间。
     */
    public mut prop issuedUtc: ?DateTime {
        get() {
            getDateTimeOffset(IssuedUtcKey)
        }
        set(value) {
            setDateTimeOffset(IssuedUtcKey, value)
        }
    }

    /**
     * @brief 获取或设置票据过期时间。
     */
    public mut prop expiresUtc: ?DateTime {
        get() {
            getDateTimeOffset(ExpiresUtcKey)
        }
        set(value) {
            setDateTimeOffset(ExpiresUtcKey, value)
        }
    }

    private func getDateTimeOffset(key: String): ?DateTime {
        if (let Some(value) <- _items.get(key)) {
            return DateTime.parse(value)
        }
        return None
    }

    private func setDateTimeOffset(key: String, value: ?DateTime) {
        if (let Some(value) <- value) {
            _items[key] = value.toString()
        }
    }

    private func getString(key: String): ?String {
        _items.get(key)
    }

    private func setString(key: String, value: ?String): Unit {
        if (let Some(value) <- value) {
            _items[key] = value
        } else {
            _items.remove(key)
        }
    }

    private func getBool(key: String): ?Bool {
        if (let Some(value) <- _items.get(key)) {
            return Bool.tryParse(value.toAsciiLower())
        }
        return None
    }

    private func setBool(key: String, value: ?Bool): Unit {
        if (let Some(value) <- value) {
            _items[key] = value.toString()
        } else {
            _items.remove(key)
        }
    }

    /**
     * @brief 将当前身份验证属性序列化为数据模型。
     * @return 序列化后的数据模型。
     */
    public func serialize(): DataModelStruct {
        let dms = DataModelStruct()
        dms.add(field("items", items))
        return dms
    }

    /**
     * @brief 从数据模型反序列化身份验证属性。
     * @param dm 输入的数据模型。
     * @return 反序列化后的身份验证属性。
     * @throws DataModelException 当输入数据不是对象结构时抛出。
     */
    public static func deserialize(dm: DataModel): AuthenticationProperties {
        let dms = match (dm) {
            case dms: DataModelStruct => dms
            case _ => throw DataModelException("The data is not DataModelStruct.")
        }
        let items = HashMap<String, String>.deserialize(dms.get("items"))
        return AuthenticationProperties(items)
    }
}

extend AuthenticationProperties {
    /**
     * @brief 批量存储身份验证令牌。
     * @param tokens 待存储的令牌数组。
     * @throws IllegalArgumentException 当令牌名称为空或包含非法分隔符时抛出。
     */
    public func storeTokens(tokens: Array<AuthenticationToken>): Unit {
        // 清空令牌
        for (token in getTokens()) {
            items.remove("${TokenKeyPrefix}${token.name}")
        }
        items.remove(TokenNamesKey)

        // 重新设置
        let tokenNames = ArrayList<String>()
        for (token in tokens) {
            if (token.name.isEmpty()) {
                throw IllegalArgumentException("Token name cannot be null for any token.")
            }
            if (token.name.contains('|')) {
                throw IllegalArgumentException("Token name cannot contain the '|' character.")
            }
            tokenNames.add(token.name)
            items["${TokenKeyPrefix}${token.name}"] = token.value
        }

        if (tokenNames.size > 0) {
            items[TokenNamesKey] = String.join(tokenNames.toArray(), delimiter: TokenNameDelimiter)
        }
    }

    /**
     * @brief 更新指定令牌的值。
     * @param tokenName 令牌名称。
     * @param tokenValue 新的令牌值。
     * @return 更新成功时返回 true；令牌不存在时返回 false。
     */
    public func updateTokenValue(tokenName: String, tokenValue: String): Bool {
        let tokenKey = "${TokenKeyPrefix}${tokenName}"
        if (!items.contains(tokenKey)) {
            return false
        }
        items[tokenKey] = tokenValue
        return true
    }

    /**
     * @brief 返回当前已存储的令牌集合。
     * @return 身份验证令牌集合。
     */
    public func getTokens(): Collection<AuthenticationToken> {
        let tokens = ArrayList<AuthenticationToken>()

        if (let Some(tokenNames) <- items
            .get(TokenNamesKey)
            .flatMap {f => f.split(TokenNameDelimiter, removeEmpty: true)}) {
            for (name in tokenNames) {
                if (let Some(token) <- getTokenValue(name)) {
                    tokens.add(AuthenticationToken(name, token))
                }
            }
        }

        return tokens
    }

    /**
     * @brief 返回指定名称的令牌值。
     * @param tokenName 令牌名称。
     * @return 令牌值；不存在时返回 None。
     */
    public func getTokenValue(tokenName: String): ?String {
        items.get("${TokenKeyPrefix}${tokenName}").flatMap {f => f as String}
    }
}

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_hosting

import std.collection.*

protected class RequestCookieCollection <: IRequestCookieCollection {
    private static let EMPTY = HashMap<String, String>()
    private let _cookieHeaderValue: ?String
    private var _items: ?HashMap<String, String> = None

    /**
     * @brief 使用原始 Cookie 头值创建请求 Cookie 集合。
     * @param cookieHeaderValue 原始 Cookie 头值。
     */
    public init(cookieHeaderValue: ?String) {
        _cookieHeaderValue = cookieHeaderValue
    }

    /**
     * @brief 返回当前 Cookie 键集合。
     * @return 当前 Cookie 键集合。
     */
    public prop keys: Collection<String> {
        get() {
            getItems().keys()
        }
    }

    /**
     * @brief 获取指定 Cookie 的值。
     * @param key Cookie 名称。
     * @return 指定 Cookie 的值；如果不存在则返回空。
     */
    public func get(key: String): ?String {
        getItems().get(key)
    }

    private func getItems(): HashMap<String, String> {
        if (let Some(items) <- _items) {
            return items
        }
        if (let Some(cookieValue) <- _cookieHeaderValue) {
            let map = parseCookies(cookieValue)
            _items = map
            return map
        }
        return EMPTY
    }

    private static func parseCookies(cookieHeaderValue: String): HashMap<String, String> {
        let map = HashMap<String, String>()
        for (pair in cookieHeaderValue.split("; ")) {
            let parts = pair.split("=")
            if (parts.size < 2) {
                continue
            }
            let key = HttpUtility.urlDecode(parts[0].trimAscii())
            if (key.isEmpty()) {
                continue
            }
            // Cookie 值可能含有 '='（如 Base64），从 parts[1] 起重新拼接
            var value = parts[1]
            var i = 2
            while (i < parts.size) {
                value = value + "=" + parts[i]
                i++
            }
            map[key] = HttpUtility.urlDecode(value)
        }
        return map
    }
}

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_hosting

import std.time.*

class ResponseCookies <: IResponseCookies {
    private let _response: HttpResponse

    init(response: HttpResponse) {
        _response = response
    }

    /**
     * @brief 追加一个响应 Cookie。
     * @param key Cookie 名称。
     * @param value Cookie 值。
     */
    public func append(key: String, value: String): Unit {
        setCookieValue(key, value, None)
    }

    /**
     * @brief 使用指定选项追加一个响应 Cookie。
     * @param key Cookie 名称。
     * @param value Cookie 值。
     * @param options Cookie 选项。
     */
    public func append(key: String, value: String, options: CookieOptions): Unit {
        setCookieValue(key, value, options)
    }

    /**
     * @brief 批量追加响应 Cookie。
     * @param keyValuePairs 要追加的 Cookie 键值对集合。
     * @param options Cookie 选项。
     */
    public func append(keyValuePairs: Collection<(String, String)>, options: CookieOptions): Unit {
        for ((key, value) in keyValuePairs) {
            setCookieValue(key, value, options)
        }
    }

    /**
     * @brief 删除指定名称的响应 Cookie。
     * @param key 要删除的 Cookie 名称。
     */
    public func delete(key: String): Unit {
        setCookieValue(key, None, None)
    }

    /**
     * @brief 使用指定选项删除响应 Cookie。
     * @param key 要删除的 Cookie 名称。
     * @param options 删除时使用的 Cookie 选项。
     */
    public func delete(key: String, options: CookieOptions): Unit {
        if (options.expires.isNone()) {
            options.expires = DateTime.ofUTC(year: 1970, month: 1, dayOfMonth: 1)
        }
        setCookieValue(key, None, options)
    }

    private func setCookieValue(key: String, value: ?String, options: ?CookieOptions) {
        let headerValue = (options ?? CookieOptions()).createCookieHeaderValue(key, value)
        _response.headers.add(HeaderNames.SetCookie, headerValue)
    }
}

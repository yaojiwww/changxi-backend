// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_http

import std.time.*
import std.collection.*

/**
 * @brief 表示写入响应 Cookie 时使用的选项。
 */
public class CookieOptions {
    /**
     * @brief 指定 Cookie 生效的域名。
     */
    public var domain: ?String = None
    /**
     * @brief 指定 Cookie 生效的路径。
     */
    public var path: ?String = '/'
    /**
     * @brief 指定 Cookie 的过期时间。
     */
    public var expires: ?DateTime = None
    /**
     * @brief 指示是否仅通过安全连接发送 Cookie。
     */
    public var secure: Bool = false
    /**
     * @brief 指定 Cookie 的 SameSite 模式。
     */
    public var sameSite: CookieSameSiteMode = CookieSameSiteMode.None
    /**
     * @brief 指示 Cookie 是否仅允许 HTTP 访问。
     */
    public var httpOnly: Bool = false
    /**
     * @brief 指定 Cookie 的最大生存时长。
     */
    public var maxAge: ?Duration = None
    /**
     * @brief 指示 Cookie 是否为必需项。
     */
    public var isEssential: Bool = false
    /**
     * @brief 保存额外的 Cookie 扩展属性。
     */
    public var extensions: Array<String> = []

    /**
     * @brief 使用显式选项值创建 Cookie 选项实例。
     * @param domain Cookie 生效域名。
     * @param path Cookie 生效路径。
     * @param expires Cookie 过期时间。
     * @param secure 是否仅通过安全连接发送。
     * @param sameSite Cookie 的 SameSite 模式。
     * @param httpOnly 是否仅允许 HTTP 访问。
     * @param maxAge Cookie 最大生存时长。
     * @param isEssential 是否为必需项。
     * @param extensions 附加扩展属性集合。
     */
    public init(domain!: ?String = None, path!: ?String = '/', expires!: ?DateTime = None, secure!: Bool = false,
        sameSite!: CookieSameSiteMode = CookieSameSiteMode.None, httpOnly!: Bool = false, maxAge!: ?Duration = None,
        isEssential!: Bool = false, extensions!: Array<String> = []) {
        this.domain = domain
        this.path = path
        this.expires = expires
        this.secure = secure
        this.sameSite = sameSite
        this.httpOnly = httpOnly
        this.maxAge = maxAge
        this.isEssential = isEssential
        this.extensions = extensions.clone()
    }

    /**
     * @brief 使用现有 Cookie 选项创建副本。
     * @param options 要复制的 Cookie 选项。
     */
    public init(options: CookieOptions) {
        this.domain = options.domain
        this.path = options.path
        this.expires = options.expires
        this.secure = options.secure
        this.sameSite = options.sameSite
        this.httpOnly = options.httpOnly
        this.maxAge = options.maxAge
        this.isEssential = options.isEssential
        this.extensions = options.extensions.clone()
    }

    /**
     * @brief 根据名称创建 Cookie 头值。
     * @param name Cookie 名称。
     * @return 生成后的 Cookie 头值。
     */
    public func createCookieHeaderValue(name: String): String {
        return createCookieHeaderValue(name, None)
    }

    /**
     * @brief 根据名称和值创建 Cookie 头值。
     * @param name Cookie 名称。
     * @param value Cookie 值。
     * @return 生成后的 Cookie 头值。
     */
    public func createCookieHeaderValue(name: String, value: ?String): String {
        // RFC 6265: cookie-pair 必须排在第一位，其后依次跟各属性
        let items = ArrayList<String>(8)
        if (let Some(value) <- value) {
            items.add("${name}=${value}")
        } else {
            // deleted
            items.add("${name}=")
        }

        if (let Some(expires) <- expires) {
            items.add("expires=${expires.format(DateTimeFormat.RFC1123)}")
        } else if (value.isNone()) {
            let expires = DateTime.UnixEpoch
            items.add("expires=${expires.format(DateTimeFormat.RFC1123)}")
        }

        if (let Some(maxAge) <- maxAge) {
            items.add("max-age=${maxAge.toSeconds()}")
        }

        if (let Some(domain) <- domain) {
            items.add("domain=${domain}")
        }

        if (let Some(path) <- path) {
            items.add("path=${path}")
        }

        if (secure) {
            items.add("secure")
        }

        if (sameSite != CookieSameSiteMode.None) {
            items.add("samesite=${sameSite}")
        }

        if (httpOnly) {
            items.add("httponly")
        }

        for (pattern in extensions) {
            items.add(pattern)
        }

        return String.join(items.toArray(), delimiter: '; ')
    }
}

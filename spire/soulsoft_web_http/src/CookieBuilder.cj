// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_http

import std.time.*

/**
 * @brief 提供按上下文构建 Cookie 选项的能力。
 */
public class CookieBuilder {
    /**
     * @brief 指定要构建的 Cookie 名称。
     */
    public var name: ?String = None
    /**
     * @brief 指定 Cookie 生效的域名。
     */
    public var domain: ?String = None
    /**
     * @brief 指定 Cookie 生效的路径。
     */
    public var path: ?String = '/'
    /**
     * @brief 指定 Cookie 相对当前时间的过期时长。
     */
    public var expiration: ?Duration = None
    /**
     * @brief 指示是否启用安全传输。
     */
    public var secure: Bool = false
    /**
     * @brief 指示是否仅允许 HTTP 访问。
     */
    public var httpOnly: Bool = false
    /**
     * @brief 指定 Cookie 最大生存时长。
     */
    public var maxAge: ?Duration = None
    /**
     * @brief 指示 Cookie 是否为必需项。
     */
    public var isEssential: Bool = false
    /**
     * @brief 保存附加扩展属性。
     */
    public var extensions: Array<String> = []
    /**
     * @brief 指定 Cookie 的 SameSite 模式。
     */
    public var sameSite = CookieSameSiteMode.None
    /**
     * @brief 指定安全传输策略。
     */
    public var securePolicy = CookieSecurePolicy.None

    /**
     * @brief 基于当前时间构建 Cookie 选项。
     * @param context 当前 HTTP 上下文。
     * @return 构建后的 Cookie 选项。
     */
    public func build(context: HttpContext): CookieOptions {
        build(context, DateTime.nowUTC())
    }

    /**
     * @brief 使用显式选项值创建 Cookie 构建器。
     * @param domain Cookie 生效域名。
     * @param path Cookie 生效路径。
     * @param expiration Cookie 相对过期时长。
     * @param secure 是否启用安全传输。
     * @param sameSite Cookie 的 SameSite 模式。
     * @param httpOnly 是否仅允许 HTTP 访问。
     * @param maxAge Cookie 最大生存时长。
     * @param isEssential 是否为必需项。
     * @param extensions 附加扩展属性集合。
     */
    public init(domain!: ?String = None, path!: ?String = '/', expiration!: ?Duration = None, secure!: Bool = false,
        sameSite!: CookieSameSiteMode = CookieSameSiteMode.None, httpOnly!: Bool = false, maxAge!: ?Duration = None,
        isEssential!: Bool = false, extensions!: Array<String> = []) {
        this.domain = domain
        this.path = path
        this.expiration = expiration
        this.secure = secure
        this.sameSite = sameSite
        this.httpOnly = httpOnly
        this.maxAge = maxAge
        this.isEssential = isEssential
        this.extensions = extensions.clone()
    }

    /**
     * @brief 基于指定时间构建 Cookie 选项。
     * @param context 当前 HTTP 上下文。
     * @param expiresFrom 计算绝对过期时间的基准时间。
     * @return 构建后的 Cookie 选项。
     */
    public func build(context: HttpContext, expiresFrom: DateTime): CookieOptions {
        let secure = if (securePolicy == CookieSecurePolicy.Always || (securePolicy == CookieSecurePolicy.SameAsRequest &&
            context.request.isHttps)) {
            true
        } else {
            false
        }

        let expires = if (let Some(expiration) <- expiration) {
            expiresFrom + expiration
        } else {
            Option<DateTime>.None
        }
        let options = CookieOptions(path: path ?? '/', sameSite: sameSite, httpOnly: httpOnly, maxAge: maxAge,
            domain: domain, isEssential: isEssential, secure: secure, expires: expires, extensions: extensions)
        return options
    }
}

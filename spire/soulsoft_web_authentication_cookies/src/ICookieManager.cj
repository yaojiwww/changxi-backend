// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_web_authentication_cookies

import soulsoft_web_http.*

/**
 * @brief 定义认证 Cookie 的读写管理能力。
 */
public interface ICookieManager {
    /**
     * @brief 从请求中读取指定 Cookie 值。
     * @param context 当前 HTTP 上下文。
     * @param key Cookie 名称。
     * @return Cookie 值；不存在时返回 None。
     */
    func getRequestCookie(context: HttpContext, key: String): ?String
    /**
     * @brief 向响应写入指定 Cookie 值。
     * @param context 当前 HTTP 上下文。
     * @param key Cookie 名称。
     * @param value Cookie 值。
     * @param options Cookie 选项。
     */
    func appendResponseCookie(context: HttpContext, key: String, value: ?String, options: CookieOptions): Unit
    /**
     * @brief 从响应中删除指定 Cookie。
     * @param context 当前 HTTP 上下文。
     * @param key Cookie 名称。
     * @param options Cookie 选项。
     */
    func deleteCookie(context: HttpContext, key: String, options: CookieOptions): Unit
}

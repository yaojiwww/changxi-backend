// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_web_http

/**
 * @brief 定义操作响应 Cookie 的能力。
 */
public interface IResponseCookies {
    /**
     * @brief 追加一个响应 Cookie。
     * @param key Cookie 名称。
     * @param value Cookie 值。
     */
    func append(key: String, value: String): Unit
    /**
     * @brief 使用指定选项追加一个响应 Cookie。
     * @param key Cookie 名称。
     * @param value Cookie 值。
     * @param options Cookie 选项。
     */
    func append(key: String, value: String, options: CookieOptions): Unit
    /**
     * @brief 批量追加响应 Cookie。
     * @param keyValuePairs 要追加的 Cookie 键值对集合。
     * @param options Cookie 选项。
     */
    func append(keyValuePairs: Collection<(String, String)>, options: CookieOptions): Unit
    /**
     * @brief 删除指定名称的响应 Cookie。
     * @param key 要删除的 Cookie 名称。
     */
    func delete(key: String): Unit
    /**
     * @brief 使用指定选项删除响应 Cookie。
     * @param key 要删除的 Cookie 名称。
     * @param options 删除时使用的 Cookie 选项。
     */
    func delete(key: String, options: CookieOptions): Unit
}

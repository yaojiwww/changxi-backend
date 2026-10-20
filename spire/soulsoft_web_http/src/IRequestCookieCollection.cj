// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_http

/**
 * @brief 定义请求 Cookie 集合。
 */
public interface IRequestCookieCollection {
    /**
     * @brief 返回当前 Cookie 键集合。
     * @return 当前 Cookie 键集合。
     */
    prop keys: Collection<String>
    /**
     * @brief 获取指定 Cookie 的值。
     * @param key Cookie 名称。
     * @return 指定 Cookie 的值；如果不存在则返回空。
     */
    func get(key: String): ?String
}

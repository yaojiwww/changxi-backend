// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_http

/**
 * @brief 定义访问当前 HTTP 上下文的能力。
 */
public interface IHttpContextAccessor {
    /**
     * @brief 返回当前作用域中的 HTTP 上下文。
     * @return 当前 HTTP 上下文；如果不存在则返回空。
     */
    prop context: ?HttpContext
}

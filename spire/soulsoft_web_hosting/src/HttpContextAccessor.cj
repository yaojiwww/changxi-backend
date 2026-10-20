// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_hosting

class HttpContextAccessor <: IHttpContextAccessor {
    private var _context: ?HttpContext = None

    /**
     * @brief 返回当前作用域保存的 HTTP 上下文。
     * @return 当前 HTTP 上下文；如果尚未设置则返回空。
     */
    public prop context: ?HttpContext {
        get() {
            _context
        }
    }

    /**
     * @brief 设置当前作用域的 HTTP 上下文。
     * @param context 要保存的 HTTP 上下文。
     */
    public func setup(context: HttpContext): Unit {
        _context = context
    }
}

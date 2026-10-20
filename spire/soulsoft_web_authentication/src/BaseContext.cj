// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_authentication

import soulsoft_web_http.*

/**
 * @brief 提供身份验证上下文的基础数据。
 * @param TOptions 当前上下文使用的方案选项类型。
 */
public abstract class BaseContext<TOptions> where TOptions <: AuthenticationSchemeOptions {
    private let _context: HttpContext
    private let _scheme: AuthenticationScheme
    private let _options: TOptions

    /**
     * @brief 创建一个身份验证上下文基类实例。
     * @param context 当前 HTTP 上下文。
     * @param scheme 当前身份验证方案。
     * @param options 当前方案选项。
     */
    protected init(context: HttpContext, scheme: AuthenticationScheme, options: TOptions) {
        _context = context
        _scheme = scheme
        _options = options
    }

    /**
     * @brief 返回当前请求对象。
     * @return 当前 HTTP 请求。
     */
    public prop request: HttpRequest {
        get() {
            _context.request
        }
    }

    /**
     * @brief 返回当前响应对象。
     * @return 当前 HTTP 响应。
     */
    public prop response: HttpResponse {
        get() {
            _context.response
        }
    }

    /**
     * @brief 返回当前 HTTP 上下文。
     * @return 当前 HTTP 上下文。
     */
    public prop context: HttpContext {
        get() {
            _context
        }
    }

    /**
     * @brief 返回当前身份验证方案。
     * @return 当前身份验证方案。
     */
    public prop scheme: AuthenticationScheme {
        get() {
            _scheme
        }
    }

    /**
     * @brief 返回当前方案选项。
     * @return 当前方案选项。
     */
    public prop options: TOptions {
        get() {
            _options
        }
    }
}

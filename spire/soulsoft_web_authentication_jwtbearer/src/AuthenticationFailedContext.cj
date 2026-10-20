// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_web_authentication_jwtbearer

import soulsoft_web_http.*
import soulsoft_web_authentication.*

/**
 * @brief 表示 JWT Bearer 身份验证失败时的上下文。
 */
public class AuthenticationFailedContext <: ResultContext<JwtBearerOptions> {
    private let _exception: Exception

    /**
     * @brief 创建一个身份验证失败上下文。
     * @param context 当前 HTTP 上下文。
     * @param scheme 当前身份验证方案。
     * @param options 当前 JWT Bearer 选项。
     * @param exception 导致失败的异常。
     */
    protected init(context: HttpContext, scheme: AuthenticationScheme, options: JwtBearerOptions, exception: Exception) {
        super(context, scheme, options)
        _exception = exception
    }

    /**
     * @brief 获取导致身份验证失败的异常。
     * @return 导致当前身份验证失败的异常实例。
     */
    public prop exception: Exception {
        get() {
            _exception
        }
    }
}

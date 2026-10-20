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
 * @brief 表示 JWT Bearer 接收到消息后的上下文。
 */
public class MessageReceivedContext <: ResultContext<JwtBearerOptions> {
    private var _token: ?String = None

    /**
     * @brief 创建一个消息接收上下文。
     * @param context 当前 HTTP 上下文。
     * @param scheme 当前身份验证方案。
     * @param options 当前 JWT Bearer 选项。
     */
    protected init(context: HttpContext, scheme: AuthenticationScheme, options: JwtBearerOptions) {
        super(context, scheme, options)
    }

    /**
     * @brief 获取或修改待验证的 Bearer 令牌。
     */
    public mut prop token: ?String {
        get() {
            _token
        }
        set(value) {
            _token = value
        }
    }
}

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_web_authentication_jwtbearer

import soulsoft_web_http.*
import soulsoft_identity_tokens.*
import soulsoft_web_authentication.*

/**
 * @brief 表示 JWT Bearer 令牌验证成功后的上下文。
 */
public class TokenValidatedContext <: ResultContext<JwtBearerOptions> {
    private var _securityToken: SecurityToken

    /**
     * @brief 创建一个令牌验证成功上下文。
     * @param context 当前 HTTP 上下文。
     * @param scheme 当前身份验证方案。
     * @param options 当前 JWT Bearer 选项。
     * @param securityToken 已验证的安全令牌。
     */
    protected init(context: HttpContext, scheme: AuthenticationScheme, options: JwtBearerOptions, securityToken: SecurityToken) {
        super(context, scheme, options)
        _securityToken = securityToken
    }

    /**
     * @brief 获取已通过验证的安全令牌。
     * @return 已完成验证的安全令牌。
     */
    public prop securityToken: SecurityToken {
        get() {
            _securityToken
        }
    }
}

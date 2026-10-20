// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_authentication

import soulsoft_identity_claims.*

/**
 * @brief 同时提供身份验证结果与用户主体特性。
 */
public class AuthenticationFeatures <: IAuthenticateResultFeature & IHttpAuthenticationFeature {
    private var _result: AuthenticateResult

    /**
     * @brief 创建一个身份验证特性集合。
     * @param result 身份验证结果。
     */
    public init(result: AuthenticateResult) {
        _result = result
    }

    /**
     * @brief 获取或设置当前身份验证结果。
     */
    public mut prop result: AuthenticateResult {
        get() {
            _result
        }
        set(value) {
            _result = value
        }
    }

    /**
     * @brief 返回当前身份验证用户主体。
     * @return 用户主体；不存在时返回 None。
     */
    public prop user: ?ClaimsPrincipal {
        get() {
            _result.principal
        }
    }
}

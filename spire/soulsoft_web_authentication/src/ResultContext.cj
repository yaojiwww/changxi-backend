// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_web_authentication

import soulsoft_web_http.*
import soulsoft_identity_claims.*

/**
 * @brief 提供身份验证结果处理的上下文基类。
 * @param TOptions 当前上下文使用的方案选项类型。
 */
public abstract class ResultContext<TOptions> <: BaseContext<TOptions> where TOptions <: AuthenticationSchemeOptions {
    private var _result: ?AuthenticateResult = None
    private var _principal: ?ClaimsPrincipal = None
    private var _properties: ?AuthenticationProperties = None

    /**
     * @brief 创建一个身份验证结果上下文基类实例。
     * @param context 当前 HTTP 上下文。
     * @param scheme 当前身份验证方案。
     * @param options 当前方案选项。
     */
    protected init(context: HttpContext, scheme: AuthenticationScheme, options: TOptions) {
        super(context, scheme, options)
    }

    /**
     * @brief 获取或设置当前用户主体。
     */
    public mut prop principal: ?ClaimsPrincipal {
        get() {
            _principal
        }
        set(value) {
            _principal = value
        }
    }

    /**
     * @brief 获取或设置当前身份验证结果。
     */
    public mut prop result: ?AuthenticateResult {
        get() {
            _result
        }
        set(value) {
            _result = value
        }
    }

    /**
     * @brief 返回当前身份验证属性。
     * @return 身份验证属性。
     */
    public prop properties: AuthenticationProperties {
        get() {
            if (let Some(properties) <- _properties) {
                return properties
            }
            _properties = AuthenticationProperties()
            return _properties.getOrThrow()
        }
    }
}

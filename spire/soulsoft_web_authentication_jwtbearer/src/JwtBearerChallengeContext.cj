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
 * @brief 表示 JWT Bearer 发起质询时的上下文。
 */
public class JwtBearerChallengeContext <: PropertiesContext<JwtBearerOptions> {
    private var _handled = false
    private var _error: ?String = None
    private var _errorUri: ?String = None
    private var _errorDescription: ?String = None
    private var _authenticateFailure: ?Exception = None

    /**
     * @brief 创建一个 JWT Bearer 质询上下文。
     * @param context 当前 HTTP 上下文。
     * @param scheme 当前身份验证方案。
     * @param options 当前 JWT Bearer 选项。
     * @param properties 身份验证属性。
     */
    protected init(context: HttpContext, scheme: AuthenticationScheme, options: JwtBearerOptions,
        properties: ?AuthenticationProperties) {
        super(context, scheme, options, properties)
    }

    /**
     * @brief 标记当前质询响应已由事件处理器接管。
     */
    public func handleResponse(): Unit {
        _handled = true
    }

    /**
     * @brief 获取当前质询响应是否已被接管。
     * @return 已被事件处理器接管时返回 `true`。
     */
    public prop handled: Bool {
        get() {
            _handled
        }
    }

    /**
     * @brief 获取或修改质询响应中的错误代码。
     */
    public mut prop error: ?String {
        get() {
            _error
        }
        set(value) {
            _error = value
        }
    }

    /**
     * @brief 获取或修改质询响应中的错误说明地址。
     */
    public mut prop errorUri: ?String {
        get() {
            _errorUri
        }
        set(value) {
            _errorUri = value
        }
    }

    /**
     * @brief 获取或修改质询响应中的错误描述。
     */
    public mut prop errorDescription: ?String {
        get() {
            _errorDescription
        }
        set(value) {
            _errorDescription = value
        }
    }

    /**
     * @brief 获取或修改导致质询的身份验证异常。
     */
    public mut prop authenticateFailure: ?Exception {
        get() {
            _authenticateFailure
        }
        set(value) {
            _authenticateFailure = value
        }
    }
}

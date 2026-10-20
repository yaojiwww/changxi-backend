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
 * @brief 提供附带身份验证属性的上下文基类。
 * @param TOptions 当前上下文使用的方案选项类型。
 */
public abstract class PropertiesContext<TOptions> <: BaseContext<TOptions> where TOptions <: AuthenticationSchemeOptions {
    private let _properties: AuthenticationProperties

    /**
     * @brief 创建一个带身份验证属性的上下文基类实例。
     * @param context 当前 HTTP 上下文。
     * @param scheme 当前身份验证方案。
     * @param options 当前方案选项。
     * @param properties 身份验证属性。
     */
    protected init(context: HttpContext, scheme: AuthenticationScheme, options: TOptions,
        properties: ?AuthenticationProperties) {
        super(context, scheme, options)
        _properties = properties ?? AuthenticationProperties()
    }

    /**
     * @brief 返回当前身份验证属性。
     * @return 身份验证属性。
     */
    public prop properties: AuthenticationProperties {
        get() {
            _properties
        }
    }
}

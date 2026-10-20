// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_authentication

import soulsoft_extensions_options.*
import soulsoft_extensions_logging.*

/**
 * @brief 提供支持登出流程的身份验证处理器基类。
 * @param TOptions 当前处理器使用的方案选项类型。
 */
public abstract class SignOutAuthenticationHandler<TOptions> <: AuthenticationHandler<TOptions> & IAuthenticationSignOutHandler where TOptions <: AuthenticationSchemeOptions {
    /**
     * @brief 创建一个登出身份验证处理器基类实例。
     * @param optionsMonitor 方案选项监视器。
     * @param logFactory 日志工厂。
     */
    protected init(optionsMonitor: IOptionsMonitor<TOptions>, logFactory: ILoggerFactory) {
        super(optionsMonitor, logFactory)
    }

    /**
     * @brief 执行登出处理。
     * @param properties 登出附带属性。
     */
    public open func signOut(properties: ?AuthenticationProperties): Unit {
        if (let Some(target) <- resolveTarget(options.forwardSignOut)) {
            this.context.signOut(target, properties)
        } else {
            handleSignOut(properties ?? AuthenticationProperties())
        }
    }

    protected func handleSignOut(properties: ?AuthenticationProperties): Unit
}

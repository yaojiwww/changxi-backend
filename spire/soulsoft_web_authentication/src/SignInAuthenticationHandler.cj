// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_authentication

import soulsoft_identity_claims.*
import soulsoft_extensions_options.*
import soulsoft_extensions_logging.*

/**
 * @brief 提供支持登录流程的身份验证处理器基类。
 * @param TOptions 当前处理器使用的方案选项类型。
 */
public abstract class SignInAuthenticationHandler<TOptions> <: SignOutAuthenticationHandler<TOptions> & IAuthenticationSignInHandler where TOptions <: AuthenticationSchemeOptions {
    /**
     * @brief 创建一个登录身份验证处理器基类实例。
     * @param optionsMonitor 方案选项监视器。
     * @param logFactory 日志工厂。
     */
    protected init(optionsMonitor: IOptionsMonitor<TOptions>, logFactory: ILoggerFactory) {
        super(optionsMonitor, logFactory)
    }

    /**
     * @brief 执行登录处理。
     * @param user 待登录的用户主体。
     * @param properties 登录附带属性。
     */
    public open func signIn(user: ClaimsPrincipal, properties: ?AuthenticationProperties): Unit {
        if (let Some(target) <- resolveTarget(options.forwardSignIn)) {
            this.context.signIn(target, user, properties)
        } else {
            handleSignIn(user, properties ?? AuthenticationProperties())
        }
    }

    protected func handleSignIn(user: ClaimsPrincipal, properties: ?AuthenticationProperties): Unit
}

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
 * @brief 表示身份验证操作的结果。
 */
public open class AuthenticateResult {
    AuthenticateResult(public let none!: Bool = false, public let ticket!: ?AuthenticationTicket = None,
        public let properties!: ?AuthenticationProperties = None, public let failure!: ?Exception = None) {
    }

    /**
     * @brief 返回身份验证是否成功。
     * @return 当票据存在时返回 true。
     */
    public prop succeeded: Bool {
        get() {
            !ticket.isNone()
        }
    }

    /**
     * @brief 返回身份验证得到的用户主体。
     * @return 用户主体；不存在时返回 None。
     */
    public prop principal: ?ClaimsPrincipal {
        get() {
            ticket.flatMap {f => f.principal}
        }
    }

    /**
     * @brief 使用失败消息创建身份验证失败结果。
     * @param failureMessage 失败消息。
     * @return 失败的身份验证结果。
     */
    public static func fail(failureMessage: String): AuthenticateResult {
        return fail(AuthenticationFailureException(failureMessage))
    }

    /**
     * @brief 使用异常创建身份验证失败结果。
     * @param failure 失败异常。
     * @return 失败的身份验证结果。
     */
    public static func fail(failure: Exception): AuthenticateResult {
        return AuthenticateResult(failure: failure)
    }

    /**
     * @brief 使用异常和属性创建身份验证失败结果。
     * @param failure 失败异常。
     * @param properties 附带的身份验证属性。
     * @return 失败的身份验证结果。
     */
    public static func fail(failure: Exception, properties: AuthenticationProperties): AuthenticateResult {
        return AuthenticateResult(failure: failure, properties: properties)
    }

    /**
     * @brief 使用票据创建身份验证成功结果。
     * @param ticket 身份验证票据。
     * @return 成功的身份验证结果。
     */
    public static func success(ticket: AuthenticationTicket): AuthenticateResult {
        return AuthenticateResult(ticket: ticket, properties: ticket.properties)
    }

    /**
     * @brief 创建没有结果的身份验证结果。
     * @return 无结果的身份验证结果。
     */
    public static func noResult(): AuthenticateResult {
        return AuthenticateResult(none: true)
    }
}

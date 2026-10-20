// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_web_authentication

/**
 * @brief 表示请求处理阶段的身份验证结果。
 */
public open class HandleRequestResult <: AuthenticateResult {
    private static let _noResult = HandleRequestResult(none: true)
    private static let _skippedResult = HandleRequestResult(skipped: true)
    private static let _handledResult = HandleRequestResult(handled: true)

    private var _handled = false
    private var _skipped = false

    /**
     * @brief 创建一个请求处理结果实例。
     * @param none 是否表示无结果。
     * @param ticket 身份验证票据。
     * @param properties 附带的身份验证属性。
     * @param failure 失败异常。
     * @param skipped 是否跳过当前处理器。
     * @param handled 请求是否已被处理。
     */
    public HandleRequestResult(none!: Bool = false, ticket!: ?AuthenticationTicket = None,
        properties!: ?AuthenticationProperties = None, failure!: ?Exception = None, skipped!: Bool = false,
        handled!: Bool = false) {
        super(none: none, ticket: ticket, properties: properties, failure: failure)
        _handled = handled
        _skipped = skipped
    }

    /**
     * @brief 使用票据创建成功结果。
     * @param ticket 身份验证票据。
     * @return 成功的请求处理结果。
     */
    public static func success(ticket: AuthenticationTicket): HandleRequestResult {
        return HandleRequestResult(ticket: ticket, properties: ticket.properties)
    }

    /**
     * @brief 使用异常创建失败结果。
     * @param failure 失败异常。
     * @return 失败的请求处理结果。
     */
    public static func fail(failure: Exception): HandleRequestResult {
        return HandleRequestResult(failure: failure)
    }

    /**
     * @brief 使用异常和属性创建失败结果。
     * @param failure 失败异常。
     * @param properties 附带的身份验证属性。
     * @return 失败的请求处理结果。
     */
    public static func fail(failure: Exception, properties: ?AuthenticationProperties): HandleRequestResult {
        return HandleRequestResult(failure: failure, properties: properties)
    }

    /**
     * @brief 使用失败消息创建失败结果。
     * @param failureMessage 失败消息。
     * @return 失败的请求处理结果。
     */
    public static func fail(failureMessage: String): HandleRequestResult {
        return fail(AuthenticationFailureException(failureMessage))
    }

    /**
     * @brief 使用失败消息和属性创建失败结果。
     * @param failureMessage 失败消息。
     * @param properties 附带的身份验证属性。
     * @return 失败的请求处理结果。
     */
    public static func fail(failureMessage: String, properties: ?AuthenticationProperties): HandleRequestResult {
        return fail(AuthenticationFailureException(failureMessage), properties)
    }

    /**
     * @brief 创建已处理请求的结果。
     * @return 已处理请求的结果实例。
     */
    public static func handle(): HandleRequestResult {
        return _handledResult
    }

    /**
     * @brief 创建跳过当前处理器的结果。
     * @return 跳过处理器的结果实例。
     */
    public static func skipHandler(): HandleRequestResult {
        return _skippedResult
    }

    /**
     * @brief 创建无结果的请求处理结果。
     * @return 无结果的请求处理结果。
     */
    public static func noResult(): HandleRequestResult {
        return _noResult
    }
}

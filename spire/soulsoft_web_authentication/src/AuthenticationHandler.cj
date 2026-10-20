// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_authentication

import soulsoft_web_http.*
import soulsoft_extensions_options.*
import soulsoft_extensions_logging.*

/**
 * @brief 提供身份验证处理器的基础实现。
 * @param TOptions 当前处理器使用的方案选项类型。
 */
public abstract class AuthenticationHandler<TOptions> <: IAuthenticationHandler where TOptions <: AuthenticationSchemeOptions {
    private var _options: ?TOptions = None
    private var _context: ?HttpContext = None
    private var _result: ?AuthenticateResult = None
    private var _scheme: ?AuthenticationScheme = None
    private let _logger: ILogger
    private let _optionsMonitor: IOptionsMonitor<TOptions>

    /**
     * @brief 创建一个身份验证处理器基类实例。
     * @param optionsMonitor 方案选项监视器。
     * @param logFactory 日志工厂。
     */
    protected init(optionsMonitor: IOptionsMonitor<TOptions>, logFactory: ILoggerFactory) {
        _optionsMonitor = optionsMonitor
        _logger = logFactory.createLogger<AuthenticationHandler<TOptions>>()
    }

    /**
     * @brief 返回当前身份验证方案。
     * @return 当前身份验证方案。
     */
    public prop scheme: AuthenticationScheme {
        get() {
            return _scheme.getOrThrow()
        }
    }

    /**
     * @brief 返回当前 HTTP 上下文。
     * @return 当前 HTTP 上下文。
     */
    public prop context: HttpContext {
        get() {
            return _context.getOrThrow()
        }
    }

    /**
     * @brief 返回当前日志记录器。
     * @return 日志记录器实例。
     */
    public prop logger: ILogger {
        get() {
            _logger
        }
    }

    /**
     * @brief 返回当前处理器选项。
     * @return 当前处理器选项。
     */
    public prop options: TOptions {
        get() {
            _options.getOrThrow()
        }
    }

    /**
     * @brief 初始化当前处理器。
     * @param scheme 当前身份验证方案。
     * @param context 当前 HTTP 上下文。
     */
    public func initialize(scheme: AuthenticationScheme, context: HttpContext): Unit {
        _scheme = scheme
        _context = context
        _options = _optionsMonitor.get(scheme.name)
        initializeHandler()
    }

    /**
     * @brief 初始化当前处理器的扩展状态。
     */
    protected open func initializeHandler(): Unit {
    }

    /**
     * @brief 执行身份验证。
     * @return 身份验证结果。
     */
    public func authenticate(): AuthenticateResult {
        if (let Some(target) <- resolveTarget(options.forwardAuthenticate)) {
            return context.authenticate(target)
        }
        let result = handleAuthenticateOnce()
        if (let Some(failure) <- result.failure) {
            logger.info("${scheme.name} was not authenticated. Failure message: ${failure.message}")
        }
        return result
    }

    /**
     * @brief 执行质询处理。
     * @param properties 质询附带属性。
     */
    public func challenge(properties: ?AuthenticationProperties): Unit {
        handleChallenge(properties ?? AuthenticationProperties())
    }

    /**
     * @brief 执行禁止访问处理。
     * @param properties 禁止访问附带属性。
     */
    public func forbid(properties: ?AuthenticationProperties): Unit {
        handleForbidden(properties ?? AuthenticationProperties())
    }

    protected func handleAuthenticateOnce() {
        if (let Some(result) <- _result) {
            return result
        }
        let result = handleAuthenticate()
        _result = result
        return result
    }

    protected func handleAuthenticate(): AuthenticateResult

    protected func handleAuthenticateOnceSafe() {
        try {
            return handleAuthenticateOnce()
        } catch (ex: Exception) {
            return AuthenticateResult.fail(ex)
        }
    }

    /**
     * @brief 执行默认的禁止访问处理。
     * @param _ 禁止访问附带属性。
     */
    protected open func handleForbidden(_: AuthenticationProperties): Unit {
        context.response.statusCode = StatusCodes.Forbidden
    }

    /**
     * @brief 执行默认的质询处理。
     * @param _ 质询附带属性。
     */
    protected open func handleChallenge(_: AuthenticationProperties): Unit {
        context.response.statusCode = StatusCodes.Unauthorized
    }

    protected func resolveTarget(scheme: ?String): ?String {
        // 优先使用传入的scheme，其次使用forwardDefaultSelector，最后使用forwardDefault
        let target = if (let Some(s) <- scheme) {
            s
        } else if (let Some(selector) <- options.forwardDefaultSelector) {
            selector(context)
        } else {
            options.forwardDefault
        }

        // Prevent self targeting - compare with current scheme name
        if (target == this.scheme.name) {
            return None
        }

        return target
    }
}

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_authorization

import std.collection.*
import soulsoft_identity_claims.*
import soulsoft_extensions_options.*
import soulsoft_extensions_logging.*

/**
 * @brief 提供默认的授权服务实现。
 */
public class DefaultAuthorizationService <: IAuthorizationService {
    private let _options: AuthorizationOptions
    private let _handlers: IAuthorizationHandlerProvider
    private let _evaluator: IAuthorizationEvaluator
    private let _policyProvider: IAuthorizationPolicyProvider
    private let _contextFactory: IAuthorizationHandlerContextFactory
    private let _logger: ILogger

    /**
     * @brief 创建一个默认授权服务。
     * @param policyProvider 授权策略提供器。
     * @param handlers 授权处理器提供器。
     * @param contextFactory 授权处理上下文工厂。
     * @param evaluator 授权结果求值器。
     * @param options 授权选项。
     * @param loggerFactory 日志工厂。
     */
    public init(
        policyProvider: IAuthorizationPolicyProvider,
        handlers: IAuthorizationHandlerProvider,
        contextFactory: IAuthorizationHandlerContextFactory,
        evaluator: IAuthorizationEvaluator,
        options: IOptions<AuthorizationOptions>,
        loggerFactory: ILoggerFactory
    ) {
        _handlers = handlers
        _evaluator = evaluator
        _options = options.value
        _contextFactory = contextFactory
        _policyProvider = policyProvider
        _logger = loggerFactory.createLogger<DefaultAuthorizationService>()
    }

    /**
     * @brief 使用命名策略执行授权。
     * @param user 待授权的用户主体。
     * @param resource 当前授权资源。
     * @param policyName 策略名称。
     * @return 授权结果。
     * @throws Exception 当指定策略不存在时抛出。
     */
    public func authorize(user: ClaimsPrincipal, resource: ?Object, policyName: String): AuthorizationResult {
        let policy = _policyProvider.getPolicy(policyName) ?? throw Exception("No policy found: ${policyName}.")
        this.authorize(user, resource, policy)
    }

    /**
     * @brief 使用授权要求集合执行授权。
     * @param user 待授权的用户主体。
     * @param resource 当前授权资源。
     * @param requirements 授权要求集合。
     * @return 授权结果。
     */
    public func authorize(user: ClaimsPrincipal, resource: ?Object, requirements: Collection<IAuthorizationRequirement>): AuthorizationResult {
        let context = _contextFactory.createContext(requirements, user, resource)
        let handlers = _handlers.getHandlers(context)
        for (pattern in handlers) {
            pattern.handle(context)
            if (!_options.invokeHandlersAfterFailure && context.hasFailed) {
                break
            }
        }

        let result = _evaluator.evaluate(context)
        if (result.succeeded) {
            _logger.debug("Authorization was successful.")
        } else if (_logger.isEnabled(LogLevel.Info)) {
            let detail = buildFailureDetail(result.failure)
            _logger.info("Authorization failed. These requirements were not met: ${detail}")
        }
        return result
    }

    private static func buildFailureDetail(failure: ?AuthorizationFailure): String {
        if (let Some(f) <- failure) {
            let reasons = f.failureReasons |> map {r: AuthorizationFailureReason => r.message} |> collectArray
            if (!reasons.isEmpty()) {
                return String.join(reasons, delimiter: "; ")
            }
            let pending = f.failedRequirements |> map {r: IAuthorizationRequirement => r.toString()} |> collectArray
            if (!pending.isEmpty()) {
                return String.join(pending, delimiter: "; ")
            }
        }
        return "unknown"
    }
}

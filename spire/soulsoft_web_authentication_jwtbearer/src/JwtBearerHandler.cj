// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
package soulsoft_web_authentication_jwtbearer

import std.collection.*
import soulsoft_web_http.*
import soulsoft_identity_tokens.*
import soulsoft_identity_claims.*
import soulsoft_web_authentication.*
import soulsoft_extensions_options.*
import soulsoft_extensions_logging.*

/**
 * @brief 提供 JWT Bearer 身份验证处理器。
 */
public class JwtBearerHandler <: AuthenticationHandler<JwtBearerOptions> {
    /**
     * @brief 创建一个 JWT Bearer 身份验证处理器。
     * @param options JWT Bearer 选项监视器。
     * @param logger 日志工厂。
     */
    public init(options: IOptionsMonitor<JwtBearerOptions>, logger: ILoggerFactory) {
        super(options, logger)
    }

    /**
     * @brief 执行当前请求的 JWT Bearer 身份验证。
     * @return 当前请求的身份验证结果。
     * @throws Exception 当身份验证过程抛出异常且失败事件未处理该异常时抛出。
     */
    public func handleAuthenticate(): AuthenticateResult {
        try {
            let messageReceivedContext = MessageReceivedContext(this.context, this.scheme, this.options)
            this.options.events.messageReceived(messageReceivedContext)
            if (let Some(result) <- messageReceivedContext.result) {
                return result
            }
            var token = messageReceivedContext.token ?? String.empty
            if (token.isEmpty()) {
                let authorization = this.context.request.headers.authorization.first ?? String.empty
                if (authorization.isEmpty()) {
                    return AuthenticateResult.noResult()
                }

                if (authorization.toAsciiLower().startsWith("bearer ")) {
                    token = authorization[7..]
                }

                if (token.isEmpty()) {
                    return AuthenticateResult.noResult()
                }
            }

            // 初始化令牌验证参数：OpenID Connect
            let tokenValidationParameters = setupTokenValidationParameters()

            // 提示信息
            if (tokenValidationParameters.issuerSigningKeys.isEmpty()) {
                this.logger.warn("options.tokenValidationParameters.issuerSigningKeys.size is empty")
            }

            // 运行验证
            var tokenValidateResult = TokenValidationResult.Failed(
                SecurityTokenValidationException("JwtBearerOptions.securityTokenValidators is empty"))
            for (validator in options.securityTokenValidators) {
                if (validator.canReadToken(token)) {
                    tokenValidateResult = validator.validateToken(token, tokenValidationParameters)
                    match (tokenValidateResult) {
                        case TokenValidationResult.Failed(exception) => recordTokenValidationError(exception)
                        case _ => ()
                    }
                }
            }

            // 返回计算结果
            match (tokenValidateResult) {
                case TokenValidationResult.Success(claimsIdentity, securityToken) =>
                    let tokenValidatedContext = TokenValidatedContext(context, scheme, options, securityToken)
                    tokenValidatedContext.principal = ClaimsPrincipal(claimsIdentity)
                    options.events.tokenValidated(tokenValidatedContext)
                    if (let Some(result) <- tokenValidatedContext.result) {
                        return result
                    }
                    let properties = AuthenticationProperties()
                    if (this.options.saveToken) {
                        properties.storeTokens(AuthenticationToken("access_token", token))
                    }
                    let subject = ClaimsPrincipal(claimsIdentity)
                    let ticket = AuthenticationTicket(subject, JwtBearerDefaults.Scheme, properties)
                    return AuthenticateResult.success(ticket)
                case TokenValidationResult.Failed(exception) =>
                    recordTokenValidationError(exception)
                    let authenticationFailedContext = AuthenticationFailedContext(context, scheme, options, exception)
                    options.events.authenticationFailed(authenticationFailedContext)
                    if (let Some(result) <- authenticationFailedContext.result) {
                        return result
                    }
                    return AuthenticateResult.fail(authenticationFailedContext.exception)
            }
        } catch (exception: Exception) {
            let authenticationFailedContext = AuthenticationFailedContext(context, scheme, options, exception)
            options.events.authenticationFailed(authenticationFailedContext)
            if (let Some(result) <- authenticationFailedContext.result) {
                return result
            }
            throw exception
        }
    }

    protected override func handleChallenge(properties: AuthenticationProperties): Unit {
        let authenticateResult = handleAuthenticateOnceSafe()

        let challengeContext = JwtBearerChallengeContext(this.context, this.scheme, this.options, properties)
        challengeContext.authenticateFailure = authenticateResult.failure
        if (options.includeErrorDetails && let Some(failure) <- authenticateResult.failure) {
            challengeContext.error = "invalid_token"
            challengeContext.errorDescription = failure.message
        }
        options.events.challenge(challengeContext)
        if (challengeContext.handled) {
            return
        }
        context.response.statusCode = StatusCodes.Unauthorized
        let error = challengeContext.error ?? String.empty
        let errorUri = challengeContext.errorUri ?? String.empty
        // RFC 6750 §3.1: error_description 不允许包含控制字符（CR/LF 等），
        // 将换行符替换为空格以确保 HTTP 头部值合法。
        let rawErrorDescription = challengeContext.errorDescription ?? String.empty
        let errorDescription = rawErrorDescription.replace("\r\n", " ").replace("\r", " ").replace("\n", " ")
        if (error.isEmpty() && errorUri.isEmpty() && errorDescription.isEmpty()) {
            context.response.headers.add("WWW-Authenticate", options.challenge)
        } else {
            // 参照 RFC 6750 Section 3.1 构建 WWW-Authenticate Header
            let builder = StringBuilder(options.challenge)
            if (options.challenge.contains(" ")) {
                builder.append(",")
            }
            if (!error.isEmpty()) {
                builder.append(" error=\"")
                builder.append(error)
                builder.append("\"")
            }
            if (!errorDescription.isEmpty()) {
                if (!error.isEmpty()) {
                    builder.append(",")
                }
                builder.append(" error_description=\"")
                builder.append(errorDescription)
                builder.append("\"")
            }
            if (!errorUri.isEmpty()) {
                if (!error.isEmpty() || !errorDescription.isEmpty()) {
                    builder.append(",")
                }
                builder.append(" error_uri=\"")
                builder.append(errorUri)
                builder.append("\"")
            }
            context.response.headers.add("WWW-Authenticate", builder.toString())
        }
    }

    protected override func handleForbidden(properties: AuthenticationProperties): Unit {
        var forbiddenContext = ForbiddenContext(context, scheme, options)
        this.context.response.statusCode = StatusCodes.Forbidden
        this.options.events.forbidden(forbiddenContext)
    }

    private func setupTokenValidationParameters() {
        if (let Some(configurationManager) <- options.configurationManager) {
            let tokenValidationParameters = options.tokenValidationParameters.clone()
            let configuration = configurationManager.getConfiguration()

            let issuers = ArrayList<String>()
            issuers.add(configuration.issuer)
            issuers.add(all: tokenValidationParameters.validIssuers)
            tokenValidationParameters.validIssuers = issuers |> collectArray

            let signingKeys = ArrayList<SecurityKey>()
            signingKeys.add(all: configuration.signingKeys)
            signingKeys.add(all: tokenValidationParameters.issuerSigningKeys)
            tokenValidationParameters.issuerSigningKeys = signingKeys.toArray()
            return tokenValidationParameters
        } else {
            return options.tokenValidationParameters
        }
    }

    private func recordTokenValidationError(exception: Exception) {
        // 仅当配置启用且异常为 SecurityTokenValidationException 时才刷新
        // 避免用户传入无效令牌时触发不必要的 OIDC 元数据刷新
        if (this.options.refreshOnIssuerKeyNotFound) {
            if (exception is SecurityTokenValidationException) {
                if (let Some(configurationManager) <- this.options.configurationManager) {
                    configurationManager.requestRefresh()
                }
            }
        }
    }
}

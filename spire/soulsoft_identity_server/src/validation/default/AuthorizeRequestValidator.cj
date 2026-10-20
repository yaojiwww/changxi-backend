/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.validation.default

import std.time.*
import soulsoft_web_http.*
import soulsoft_identity_claims.*
import soulsoft_identity_server.stores.*
import soulsoft_identity_server.models.*
import soulsoft_identity_protocols_oidc.*
import soulsoft_identity_server.options.*
import soulsoft_identity_server.validation.*

protected class AuthorizeRequestValidator <: IAuthorizeRequestValidator {
    public AuthorizeRequestValidator(
        let options: IdentityServerOptions,
        let clientStore: IClientStore,
        let consentStore: IConsentStore,
        let resourceValidator: IResourceValidator
    ) {}

    public func validate(user: ClaimsPrincipal, parameters: IValueProvider) {
        // ========== 第1层：提取必需参数 ==========
        let clientId = getRequiredParameter(parameters, OpenIdConnectParameterNames.ClientId, "client_id")
        let redirectUri = getRequiredParameter(parameters, OpenIdConnectParameterNames.RedirectUri, "redirect_uri")
        let responseType = getRequiredParameter(parameters, OpenIdConnectParameterNames.ResponseType, "response_type")
        let responseMode = parameters.get(OpenIdConnectParameterNames.ResponseMode)
        let scope = getRequiredParameter(parameters, OpenIdConnectParameterNames.Scope, "scope")
        let state = parameters.get(OpenIdConnectParameterNames.State)

        // ========== 第2层：验证客户端 ==========
        let client = validateClient(clientId)
        validateClientAuthorization(client, GrantTypes.AuthorizationCode)
        validateRedirectUri(client, redirectUri)

        // ========== 第3层：验证协议参数 ==========
        validateResponseType(responseType)

        // ========== 第4层：检查同意状态 ==========
        let consent = checkUserConsent(user, client)
        if (client.requireConsent && !isConsentValid(consent)) {
            return NeedConsent
        }

        // ========== 第5层：验证资源和作用域 ==========
        var scopes = readRequestScopes(scope, client)

        // 如果有有效的同意记录，使用同意中的作用域
        if (let Some(c) <- consent) {
            scopes = c.scopes
        }

        let resources = resourceValidator.validate(client, GrantTypes.AuthorizationCode, scopes)
        validateOpenIdScope(resources)

        // ========== 第6层：验证安全参数 ==========
        let codeChallenge = parameters.get("code_challenge")
        let codeChallengeMethod = parameters.get("code_challenge_method")
        validatePkce(codeChallenge, codeChallengeMethod, client)

        let nonce = parameters.get(OpenIdConnectParameterNames.Nonce)
        validateNonce(nonce, responseType)

        // ========== 构建验证结果 ==========
        return Success(
            ValidatedAuthorizeRequest(
                state: state,
                scope: scope,
                clientId: clientId,
                redirectUri: redirectUri,
                responseType: responseType,
                responseMode: responseMode,
                client: client,
                subject: user,
                resources: resources,
                codeChallenge: codeChallenge,
                codeChallengeMethod: codeChallengeMethod,
                nonce: nonce
            )
        )
    }

    // ============ Helper Methods ============

    /// 检查用户同意
    private func checkUserConsent(user: ClaimsPrincipal, client: Client): ?Consent {
        if (!client.requireConsent) {
            return None
        }

        let sub = user.findFirstValue(ClaimTypes.Sub).getOrThrow()
        return consentStore.find(sub, client.clientId)
    }

    /// 判断同意记录是否有效
    private func isConsentValid(consent: ?Consent): Bool {
        // 无同意记录 → 无效
        if (consent.isNone()) {
            return false
        }

        let c = consent.getOrThrow()

        // lifetime 为 None → 永不过期
        if (c.lifetime.isNone()) {
            return true
        }

        // 检查是否在有效期内：creationTime + lifetime > now
        let lifetime = c.lifetime.getOrThrow()
        let expirationTime = c.creationTime + Duration.second * lifetime
        return expirationTime > DateTime.now().inUTC()
    }

    /// 验证客户端是否存在
    private func validateClient(clientId: String): Client {
        return clientStore.find(clientId).getOrThrow {
            ValidationException(ValidationErrors.InvalidClient, "Client not found: ${clientId}")
        }
    }

    /// 验证客户端是否被授权使用指定的授权类型
    private func validateClientAuthorization(client: Client, grantType: String) {
        if (!client.allowedGrantTypes.contains(grantType)) {
            throw ValidationException(
                ValidationErrors.UnauthorizedClient,
                "Client '${client.clientId}' is not authorized to use grant type '${grantType}'"
            )
        }
    }

    /// 验证重定向 URI 是否在客户端的允许列表中
    private func validateRedirectUri(client: Client, redirectUri: String) {
        if (!client.allowedRedirectUris.contains(redirectUri)) {
            throw ValidationException(ValidationErrors.InvalidRequest, "Invalid redirect_uri: ${redirectUri}")
        }
    }

    private func readRequestScopes(scope: String, client: Client) {
        let scopes = scope.split(' ')
        if (client.allowOfflineAccess && !scopes.contains(OpenIdConnectScopes.OfflineAccess)) {
            return scopes.concat(OpenIdConnectScopes.OfflineAccess)
        } else {
            return scopes
        }
    }

    private func getRequiredParameter(parameters: IValueProvider, parameterName: String, displayName: String) {
        return parameters.get(parameterName).getOrThrow {
            ValidationException(ValidationErrors.InvalidRequest, "Missing required parameter '${displayName}'")
        }
    }

    private func validateResponseType(responseType: String) {
        // OAuth 2.0 和 OpenID Connect 支持的标准响应类型
        let supportedTypes = ["code", "token", "id_token", "code token", "code id_token", "id_token token",
            "code id_token token"]

        if (!supportedTypes.contains(responseType)) {
            throw ValidationException(
                ValidationErrors.UnsupportedResponseType,
                "Unsupported response_type: ${responseType}"
            )
        }
    }

    private func validateOpenIdScope(resources: ResourceCollection) {
        if (!resources.getScopes().contains(OpenIdConnectScopes.OpenId)) {
            throw ValidationException(ValidationErrors.InvalidScope, "Missing required 'openid' scope")
        }
    }

    private func validatePkce(codeChallenge: ?String, codeChallengeMethod: ?String, client: Client) {
        // RFC 7636: PKCE 验证

        // 1. 检查是否提供了 code_challenge
        if (codeChallenge.isNone()) {
            if (client.requirePkce) {
                throw ValidationException(
                    ValidationErrors.InvalidRequest,
                    "code_challenge is required for this client"
                )
            }
            return
        }

        // 2. 验证 code_challenge 长度（RFC 7636 Section 4.2）
        let challenge = codeChallenge.getOrThrow()
        if (challenge.size < 43 || challenge.size > 128) {
            throw ValidationException(
                ValidationErrors.InvalidRequest,
                "code_challenge must be between 43 and 128 characters"
            )
        }

        // 3. 验证 code_challenge_method
        let method = codeChallengeMethod.getOrDefault {"plain"} // RFC 7636: 默认为 plain

        if (method != "plain" && method != "S256") {
            throw ValidationException(
                ValidationErrors.InvalidRequest,
                "code_challenge_method must be 'plain' or 'S256'"
            )
        }

        // 4. 检查客户端是否允许 plain 方法
        if (method == "plain" && !client.allowPlainTextPkce) {
            throw ValidationException(
                ValidationErrors.InvalidRequest,
                "plain code_challenge_method is not allowed for this client"
            )
        }
    }

    private func validateNonce(nonce: ?String, responseType: String) {
        // OpenID Connect Core 1.0 Section 3.1.2.1: nonce 验证

        // 1. 检查 nonce 长度限制
        if (let Some(nonceValue) <- nonce) {
            if (nonceValue.size > 512) {
                throw ValidationException(
                    ValidationErrors.InvalidRequest,
                    "nonce is too long"
                )
            }
        }

        // 2. 如果 response_type 包含 id_token，必须提供 nonce（防止重放攻击）
        let responseTypes = responseType.split(' ')
        if (responseTypes.contains("id_token")) {
            if (nonce.isNone() || nonce.getOrThrow().isEmpty()) {
                throw ValidationException(
                    ValidationErrors.InvalidRequest,
                    "nonce is required for response_type containing id_token"
                )
            }
        }
    }
}

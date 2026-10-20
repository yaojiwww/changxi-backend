/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.services.default

import std.time.*
import std.crypto.digest.*
import stdx.crypto.digest.*
import soulsoft_identity_tokens.*
import soulsoft_identity_server.stores.*
import soulsoft_identity_server.models.*
import soulsoft_identity_server.services.*
import soulsoft_identity_server.validation.*

/**
 * 授权码服务的默认实现
 *
 * 提供授权码的验证和消费功能，确保授权码的安全使用。
 */

protected class AuthorizationCodeService <: IAuthorizationCodeService {
  
    public AuthorizationCodeService(let store: IAuthorizationCodeStore) {
    }

    public func validate(request: AuthorizationCodeValidationRequest): AuthorizationCode {
        let authorizationCode = findAuthorizationCode(request.code)
        validateLifetime(authorizationCode)
        validateClientId(authorizationCode, request.client.clientId)
        validateRedirectUri(authorizationCode, request.redirectUri)
        validatePkce(authorizationCode, request.client, request.codeVerifier)

        // RFC 6749 Section 4.1.2: 授权码一次性使用，验证后立即删除
        consumeAuthorizationCode(request.code)

        return authorizationCode
    }

    // ============ Validation Methods ============

    private func findAuthorizationCode(code: String): AuthorizationCode {
        return store.find(code).getOrThrow {
            ValidationException(
                ValidationErrors.InvalidGrant,
                "Invalid or unknown authorization code"
            )
        }
    }

    private func validateLifetime(authorizationCode: AuthorizationCode) {
        let currentTime = DateTime.now().inUTC()
        // 使用客户端配置的授权码生命周期
        let expirationTime = authorizationCode.creationTime + (authorizationCode.lifetime * Duration.second)

        if (currentTime > expirationTime) {
            throw ValidationException(
                ValidationErrors.InvalidGrant,
                "Authorization code has expired"
            )
        }
    }

    private func validateClientId(authorizationCode: AuthorizationCode, clientId: String) {
        // RFC 6749 Section 4.1.3: 验证授权码是否属于该客户端
        if (authorizationCode.clientId != clientId) {
            throw ValidationException(
                ValidationErrors.InvalidGrant,
                "Authorization code was issued to a different client"
            )
        }
    }

    private func validateRedirectUri(authorizationCode: AuthorizationCode, redirectUri: String) {
        // RFC 6749 Section 4.1.3: redirect_uri 必须与授权请求时的一致
        if (authorizationCode.redirectUri != redirectUri) {
            throw ValidationException(
                ValidationErrors.InvalidGrant,
                "redirect_uri does not match the authorization request"
            )
        }
    }

    private func validatePkce(authorizationCode: AuthorizationCode, client: Client, codeVerifier: ?String) {
        // RFC 7636: PKCE 验证
        // 检查客户端是否要求 PKCE 或授权码包含 code_challenge
        if (client.requirePkce || authorizationCode.codeChallenge.isSome()) {
            if (let Some(codeChallenge) <- authorizationCode.codeChallenge) {
                // 如果授权码包含 code_challenge，则必须提供 code_verifier
                if (codeVerifier.isNone()) {
                    throw ValidationException(
                        ValidationErrors.InvalidGrant,
                        "code_verifier is required for PKCE"
                    )
                }

                let requestCodeVerifier = codeVerifier.getOrThrow()
                let method = authorizationCode.codeChallengeMethod.getOrDefault {"plain"}

                // 检查客户端是否允许 plain 方法
                if (method == "plain" && !client.allowPlainTextPkce) {
                    throw ValidationException(
                        ValidationErrors.InvalidGrant,
                        "Plain text code challenge method is not allowed for this client"
                    )
                }

                // 验证 code_verifier 长度（RFC 7636 Section 4.1）
                if (requestCodeVerifier.size < 43 || requestCodeVerifier.size > 128) {
                    throw ValidationException(
                        ValidationErrors.InvalidGrant,
                        "code_verifier must be between 43 and 128 characters"
                    )
                }

                // 计算挑战值并比较
                let computedChallenge = match (method) {
                    case "plain" => requestCodeVerifier
                    case "S256" => computeS256Challenge(requestCodeVerifier)
                    case _ => throw ValidationException(
                        ValidationErrors.InvalidGrant,
                        "Unsupported code_challenge_method: ${method}"
                    )
                }

                if (computedChallenge != codeChallenge) {
                    throw ValidationException(
                        ValidationErrors.InvalidGrant,
                        "Invalid code_verifier"
                    )
                }
            } else if (client.requirePkce) {
                // 客户端要求 PKCE 但授权码没有 code_challenge
                throw ValidationException(
                    ValidationErrors.InvalidGrant,
                    "Client requires PKCE but authorization code was not issued with code challenge"
                )
            }
        } else if (codeVerifier.isSome()) {
            throw ValidationException(
                ValidationErrors.InvalidGrant,
                "Unexpected code_verifier. Client does not require PKCE. Set RequirePkce to true."
            )
        }
    }

    private func computeS256Challenge(codeVerifier: String): String {
        // RFC 7636 Section 4.2: S256 = BASE64URL(SHA256(ASCII(code_verifier)))
        let bytes = digest(SHA256(), codeVerifier.toArray())
        return Base64UrlEncoder.encode(bytes)
    }

    private func consumeAuthorizationCode(code: String) {
        // RFC 6749 Section 4.1.2: 授权码必须只能使用一次
        // 删除授权码确保一次性使用，重用时会自动失败（找不到授权码）
        store.remove(code)
    }
}

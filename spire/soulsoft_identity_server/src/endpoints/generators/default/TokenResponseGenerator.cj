/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.endpoints.generators.default

import soulsoft_extensions_injection.*
import soulsoft_identity_protocols_oidc.*
import soulsoft_identity_server.models.*
import soulsoft_identity_server.options.*
import soulsoft_identity_server.services.*
import soulsoft_identity_server.validation.*
import soulsoft_identity_server.endpoints.generators.*

protected class TokenResponseGenerator <: ITokenResponseGenerator {
    public TokenResponseGenerator(let tokenService: ITokenService, let claimService: IClaimService,
        let options: IdentityServerOptions, let serviceProvider: IServiceProvider) {
    }

    public func createToken(request: ValidatedTokenRequest): TokenResponse {
        var scopes = request.resources.getScopes()

        // 创建访问令牌和刷新令牌
        let (accessToken, refreshToken) = createAccessToken(request)

        // 创建身份令牌（如果请求了 openid scope）
        let idToken = if (scopes.contains(OpenIdConnectScopes.OpenId)) {
            createIdentityToken(request)
        } else {
            Option<String>.None
        }

        // 返回令牌响应
        let accessTokenLifetime = request.client.accessTokenLifetime
        return TokenResponse(accessToken, idToken, refreshToken, accessTokenLifetime, scopes)
    }

    private func createAccessToken(tokenValidationResult: ValidatedTokenRequest) {
        let claimsRequest = ClaimsRequest(tokenValidationResult.client, tokenValidationResult.subject,
            tokenValidationResult.resources)
        let claims = claimService.getAccessTokenClaims(claimsRequest)
        let tokenCreationRequest = TokenCreationRequest(claims, tokenValidationResult.client,
            tokenValidationResult.resources)
        let token = tokenService.createAccessToken(tokenCreationRequest)
        let accessToken = tokenService.createSecurityToken(token)

        // 创建刷新令牌
        let refreshToken = if (tokenValidationResult.resources.isAllowedOfflineAccess()) {
            if (tokenValidationResult.grantType == GrantTypes.RefreshToken) {
                updateRefreshToken(token, tokenValidationResult)
            } else {
                createRefreshToken(token, tokenValidationResult)
            }
        } else {
            Option<String>.None
        }
        return (accessToken, refreshToken)
    }

    private func createIdentityToken(tokenValidationResult: ValidatedTokenRequest) {
        let claimsRequest = ClaimsRequest(tokenValidationResult.client, tokenValidationResult.subject,
            tokenValidationResult.resources)
        let claims = claimService.getIdentityTokenClaims(claimsRequest)
        let tokenCreationRequest = TokenCreationRequest(claims, tokenValidationResult.client,
            tokenValidationResult.resources)
        let token = tokenService.createIdentityToken(tokenCreationRequest)
        let identityToken = tokenService.createSecurityToken(token)
        return identityToken
    }

    private func createRefreshToken(accessToken: Token, tokenValidationResult: ValidatedTokenRequest) {
        let refreshTokenCreationRequest = RefreshTokenCreationRequest(accessToken, tokenValidationResult.client,
            tokenValidationResult.resources)
        let refreshTokenService = serviceProvider.getOrThrow<IRefreshTokenService>()
        let refreshToken = refreshTokenService.createRefreshToken(refreshTokenCreationRequest)
        return refreshToken
    }

    private func updateRefreshToken(accessToken: Token, tokenValidationResult: ValidatedTokenRequest) {
        let refreshTokenHandle = tokenValidationResult.refreshTokenHandle.getOrThrow()
        let refreshToken = tokenValidationResult.refreshToken.getOrThrow()
        let refreshTokenService = serviceProvider.getOrThrow<IRefreshTokenService>()
        let request = RefreshTokenUpdateRequest(refreshTokenHandle, refreshToken, tokenValidationResult.client,
            tokenValidationResult.resources)
        return refreshTokenService.updateRefreshToken(request)
    }
}

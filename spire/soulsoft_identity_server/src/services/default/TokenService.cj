/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.services.default

import std.time.*
import std.collection.*
import soulsoft_identity_claims.*
import soulsoft_identity_tokens.*
import soulsoft_identity_tokens_jwt.*
import soulsoft_identity_server.models.*
import soulsoft_identity_server.options.*
import soulsoft_identity_server.services.*

protected class TokenService <: ITokenService {
    public TokenService(let keys: IKeyManager, let handleGenerator: IHandleGenerator, let options: IdentityServerOptions) {
    }

    public func createSecurityToken(token: Token): String {
        let signingCredentials = keys.getActiveSigningKeys() |> first
        let descriptor = SecurityTokenDescriptor(signingCredentials.getOrThrow())
        let currentTime = DateTime.now().inUTC()
        descriptor.notBefore = currentTime
        descriptor.issuer = token.issuer
        descriptor.issuedAt = currentTime
        descriptor.expires = currentTime.addSeconds(token.lifetime)
        for (audience in token.audiences) {
            descriptor.audiences.add(audience)
        }
        let claims = ArrayList<Claim>(token.subject.claims)
        if (token.tokenType == TokenTypes.AccessToken) {
            claims.add(Claim(ClaimTypes.ClientId, token.clientId))
        }
        claims.add(Claim(ClaimTypes.Jti, handleGenerator.generate()))
        descriptor.claims = claims
        let handler = JwtSecurityTokenHandler()
        return handler.createEncodedJwt(descriptor)
    }

    public func createAccessToken(request: TokenCreationRequest): Token {
        let token = Token()
        token.issuer = options.issuer
        token.clientId = request.client.clientId
        token.tokenType = TokenTypes.AccessToken
        token.lifetime = request.client.accessTokenLifetime
        token.subject = ClaimsPrincipal(ClaimsIdentity(request.claims))
        token.audiences = request.resources.getApiResources() |> map {f => f.name} |> collectArray
        return token
    }

    public func createIdentityToken(request: TokenCreationRequest) {
        let token = Token()
        token.issuer = options.issuer
        token.clientId = request.client.clientId
        token.tokenType = TokenTypes.IdentityToken
        token.lifetime = request.client.identityTokenLifetime
        token.subject = ClaimsPrincipal(ClaimsIdentity(request.claims))
        token.audiences = [request.client.clientId]
        return token
    }
}

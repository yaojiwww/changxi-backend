/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.validation.default

import std.time.*
import std.collection.*
import soulsoft_identity_claims.*
import soulsoft_identity_tokens.*
import soulsoft_identity_tokens_jwt.*
import soulsoft_identity_server.stores.*
import soulsoft_identity_server.models.*
import soulsoft_identity_server.options.*
import soulsoft_identity_server.services.*
import soulsoft_identity_server.validation.*

protected class TokenValidator <: ITokenValidator {
    public TokenValidator(let options: IdentityServerOptions, let keyManager: IKeyManager,
        let clientStore: IClientStore, let refreshTokenStore: IRefreshTokenStore) {
    }

    public func validateAccessToken(token: String) {
        let signingKeys = keyManager.getActiveSigningKeys() |> map {f => f.key} |> collectArray
        let parameters = TokenValidationParameters()
        parameters.validateAudience = false
        parameters.validIssuers = [options.issuer]
        parameters.issuerSigningKeys = signingKeys
        let handler = JwtSecurityTokenHandler()
        let subject = match (handler.validateToken(token, parameters)) {
            case Success(subject, _) => subject
            case Failed(ex) => throw ex
        }
        let clientId = subject.findFirstValue(ClaimTypes.ClientId).getOrThrow {
            ValidationException(ValidationErrors.InvalidToken, "Access token missing required 'client_id' claim")
        }
        let client = clientStore.find(clientId).getOrThrow {
            ValidationException(ValidationErrors.InvalidClient,
                "Client specified in access token 'client_id' claim not found or invalid")
        }
        return AccessTokenValidationResult(client, subject.claims)
    }

    public func validateIdentityToken(token: String) {
        let signingKeys = keyManager.getActiveSigningKeys() |> map {f => f.key} |> collectArray
        let parameters = TokenValidationParameters()
        parameters.validateAudience = false
        parameters.validIssuers = [options.issuer]
        parameters.issuerSigningKeys = signingKeys
        let handler = JwtSecurityTokenHandler()
        let subject = match (handler.validateToken(token, parameters)) {
            case Success(subject, _) => subject
            case Failed(ex) => throw ex
        }
        let clientId = subject.findFirstValue(ClaimTypes.Aud).getOrThrow {
            ValidationException(ValidationErrors.InvalidToken, "Identity token missing required 'aud' (audience) claim")
        }
        let client = clientStore.find(clientId).getOrThrow {
            ValidationException(ValidationErrors.InvalidClient,
                "Client specified in identity token 'aud' claim not found or invalid")
        }
        return IdentityTokenValidationResult(client, subject.claims)
    }

    public func validateRefreshToken(refreshTokenHandle: String) {
        let refreshToken = refreshTokenStore.find(refreshTokenHandle).getOrThrow {
            ValidationException(ValidationErrors.InvalidGrant, "Refresh token not found or invalid")
        }

        let client = clientStore.find(refreshToken.clientId).getOrThrow {
            ValidationException(ValidationErrors.InvalidClient, "Client specified in refresh token not found or invalid")
        }

        let consumedTime = match (client.refreshTokenExpiration) {
            case RefreshTokenExpiration.Sliding => refreshToken.consumedTime ?? refreshToken.creationTime
            case RefreshTokenExpiration.Absolute => refreshToken.creationTime
        }

        let expirationTime = consumedTime.addSeconds(refreshToken.lifetime)

        if (DateTime.now().inUTC() > expirationTime) {
            throw ValidationException(ValidationErrors.InvalidGrant, "Refresh token expired")
        }

        return RefreshTokenValidationResult(client, refreshToken)
    }
}

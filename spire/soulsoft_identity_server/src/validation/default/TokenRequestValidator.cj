/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.validation.default

import soulsoft_web_http.*
import soulsoft_identity_claims.*
import soulsoft_extensions_injection.*
import soulsoft_identity_server.models.*
import soulsoft_identity_protocols_oidc.*
import soulsoft_identity_server.services.*
import soulsoft_identity_server.validation.*

protected class TokenRequestValidator <: ITokenRequestValidator {
    public TokenRequestValidator(let resourceValidator: IResourceValidator, let serviceProvider: IServiceProvider) {
    }

    public func validate(client: Client, parameters: IValueProvider) {
        let grantType = getRequiredParameter(parameters, OpenIdConnectParameterNames.GrantType, "grant_type")
        validateClientGrantType(client, grantType)

        let scope = parameters.get(OpenIdConnectParameterNames.Scope)
        let scopes = getRequestScopes(scope, client)
        let resources = resourceValidator.validate(client, grantType, scopes)

        return match (grantType) {
            case x where x == GrantTypes.ClientCredentials => validateClientCredentials(client, resources)
            case x where x == GrantTypes.AuthorizationCode => validateAuthorizationCode(client, resources, parameters)
            case x where x == GrantTypes.RefreshToken => validateRefreshToken(client, resources, parameters)
            case x where x == GrantTypes.Password => validateResourceOwnerPassword(client, resources, parameters)
            case _ => validateExtensionGrant(client, resources, parameters, grantType)
        }
    }

    // ============ Grant Type Validators ============

    private func validateClientCredentials(client: Client, resources: ResourceCollection) {
        let grantType = GrantTypes.ClientCredentials
        let subject = ClaimsPrincipal()
        return ValidatedTokenRequest(client, resources, subject, grantType, None, None)
    }

    private func validateAuthorizationCode(
        client: Client,
        resources: ResourceCollection,
        parameters: IValueProvider
    ) {
        let grantType = GrantTypes.AuthorizationCode
        let code = getRequiredParameter(parameters, OpenIdConnectParameterNames.Code, "code")

        // RFC 6749 Section 4.1.3: 提取 redirect_uri
        let redirectUri = getRequiredParameter(parameters, OpenIdConnectParameterNames.RedirectUri, "redirect_uri")

        // RFC 7636: 提取 code_verifier（可选）
        let codeVerifier = parameters.get("code_verifier")

        // 验证授权码
        let authorizationCodeService = serviceProvider.getOrThrow<IAuthorizationCodeService>()
        let request = AuthorizationCodeValidationRequest(code, client, redirectUri, codeVerifier)
        let authorizationCode = authorizationCodeService.validate(request)

        let subject = authorizationCode.subject
        return ValidatedTokenRequest(client, resources, subject, grantType, None, None)
    }

    private func validateRefreshToken(
        client: Client,
        resources: ResourceCollection,
        parameters: IValueProvider
    ) {
        if (!client.allowOfflineAccess) {
            throw ValidationException(ValidationErrors.InvalidScope, "Client is not allowed to use refresh tokens")
        }
        let grantType = GrantTypes.RefreshToken
        let refreshTokenHandle = getRequiredParameter(parameters, OpenIdConnectParameterNames.RefreshToken,
            "refresh_token")
        let tokenValidator = serviceProvider.getOrThrow<ITokenValidator>()
        let refreshToken = tokenValidator.validateRefreshToken(refreshTokenHandle).refreshToken
        if (client.clientId != refreshToken.clientId) {
            throw ValidationException(ValidationErrors.InvalidGrant, "Refresh token is not issued for this client")
        }
        var scopes = resources.getScopes()
        for (scope in scopes) {
            if (!refreshToken.scopes.contains(scope)) {
                throw ValidationException(ValidationErrors.InvalidScope, "Requested scope exceeds granted scope")
            }
        }
        return ValidatedTokenRequest(
            client,
            resources,
            refreshToken.subject,
            grantType,
            refreshTokenHandle,
            refreshToken
        )
    }

    private func validateResourceOwnerPassword(
        client: Client,
        resources: ResourceCollection,
        parameters: IValueProvider
    ) {
        let username = getRequiredParameter(parameters, OpenIdConnectParameterNames.Username, "username")
        let password = getRequiredParameter(parameters, OpenIdConnectParameterNames.Password, "password")

        let validator = serviceProvider.get<IResourceOwnerPasswordValidator>().getOrThrow {
            ValidationException(ValidationErrors.UnsupportedGrantType, "Password grant not supported")
        }

        let request = ResourceOwnerPasswordValidationRequest(parameters, username, password, client, resources)
        let user = validator.validate(request)
        let subject = user.toPrincipal()
        return ValidatedTokenRequest(client, resources, subject, GrantTypes.Password, None, None)
    }

    private func validateExtensionGrant(
        client: Client,
        resources: ResourceCollection,
        parameters: IValueProvider,
        grantType: String
    ) {
        let validator = tryGetExtensionGrantValidator(grantType).getOrThrow {
            ValidationException(ValidationErrors.UnsupportedGrantType, "Unsupported grant type: ${grantType}")
        }

        let request = ExtensionGrantValidationRequest(parameters, client, resources)
        let user = validator.validate(request)
        let subject = user.toPrincipal()
        return ValidatedTokenRequest(client, resources, subject, grantType, None, None)
    }

    // ============ Helper Methods ============

    private func getRequiredParameter(parameters: IValueProvider, parameterName: String, displayName: String) {
        return parameters.get(parameterName).getOrThrow {
            ValidationException(ValidationErrors.InvalidRequest, "Missing ${displayName} parameter")
        }
    }

    private func validateClientGrantType(client: Client, grantType: String) {
        if (!client.allowedGrantTypes.contains(grantType)) {
            throw ValidationException(ValidationErrors.UnauthorizedClient, "Grant type not allowed for this client")
        }
    }

    private func getRequestScopes(scope: ?String, client: Client) {
        let scopes = if (let Some(scope) <- scope && !scope.isEmpty()) {
            scope.split(' ')
        } else {
            client.allowedScopes
        }
        if (client.allowOfflineAccess && !scopes.contains(OpenIdConnectScopes.OfflineAccess)) {
            return scopes.concat(OpenIdConnectScopes.OfflineAccess)
        }
        return scopes
    }

    private func validateRequiredClaim(subject: ClaimsPrincipal, claimType: String, claimName: String) {
        if (!subject.hasClaim {f => f.`type` == claimType}) {
            throw ValidationException(ValidationErrors.ServerError, "Missing required ${claimName} claim")
        }
    }

    private func tryGetExtensionGrantValidator(grantType: String) {
        let extensionGrantManager = serviceProvider.getOrThrow<ExtensionGrantManager>()
        return extensionGrantManager.findValidator(grantType)
    }
}

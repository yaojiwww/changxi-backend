/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.validation.default

import soulsoft_identity_server.models.*
import soulsoft_identity_protocols_oidc.*
import soulsoft_identity_server.services.*
import soulsoft_identity_server.validation.*

protected class ResourceValidator <: IResourceValidator {
    public ResourceValidator(let resourceManager: ResourceManager) {
    }

    public func validate(client: Client, grantType: String, scopes: Array<String>): ResourceCollection {
        // Validate each requested scope is allowed for the client
        for (scope in scopes) {
            if (!client.allowedScopes.contains(scope) && scope != OpenIdConnectScopes.OfflineAccess) {
                throw ValidationException(ValidationErrors.InvalidScope, "Scope '${scope}' not allowed for client")
            }
        }

        // Validate grant type specific scope restrictions
        validateGrantTypeScopes(grantType, scopes)

        // Validate offline_access scope
        if (scopes.contains(OpenIdConnectScopes.OfflineAccess)) {
            if (!client.allowOfflineAccess) {
                throw ValidationException(ValidationErrors.InvalidScope,
                    "Client not allowed to request offline_access")
            }
        }

        // Find resources matching the requested scopes
        let resources = resourceManager.findAll(scopes)
        if (resources.isEmpty()) {
            throw ValidationException(ValidationErrors.InvalidScope,
                "No resources found for requested scopes")
        }

        // Verify all requested scopes (except offline_access) are present in resources
        let availableScopes = resources.getScopes()
        for (scope in scopes) {
            if (scope != OpenIdConnectScopes.OfflineAccess && !availableScopes.contains(scope)) {
                throw ValidationException(ValidationErrors.InvalidScope,
                    "Scope '${scope}' not found in configured resources")
            }
        }

        return resources
    }

    private func validateGrantTypeScopes(grantType: String, scopes: Array<String>) {
        if (grantType == GrantTypes.ClientCredentials) {
            // Client credentials cannot request offline_access
            if (scopes.contains(OpenIdConnectScopes.OfflineAccess)) {
                throw ValidationException(ValidationErrors.InvalidScope,
                    "Client credentials cannot request offline_access")
            }
            // Client credentials cannot request openid scope
            if (scopes.contains(OpenIdConnectScopes.OpenId)) {
                throw ValidationException(ValidationErrors.InvalidScope,
                    "Client credentials cannot request openid scope")
            }
        }

        if (grantType == GrantTypes.AuthorizationCode) {
            // Authorization code flow requires openid scope for OIDC
            if (!scopes.contains(OpenIdConnectScopes.OpenId)) {
                throw ValidationException(ValidationErrors.InvalidScope,
                    "Missing required 'openid' scope for authorization code flow")
            }
        }
    }
}

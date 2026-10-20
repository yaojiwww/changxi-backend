/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.services.default

import stdx.encoding.url.*
import soulsoft_identity_claims.*
import soulsoft_identity_server.stores.*
import soulsoft_identity_server.models.*
import soulsoft_identity_protocols_oidc.*
import soulsoft_identity_server.services.*
import soulsoft_identity_server.validation.*

protected class ConsentService <: IConsentService {
    public ConsentService(let clientStore: IClientStore, let consentStore: IConsentStore,
        let resourceValidator: IResourceValidator) {
    }

    public func createConsent(subject: ClaimsPrincipal, client: Client, scopes: Array<String>) {
        let consent = Consent()
        consent.sub = subject.findFirstValue(ClaimTypes.Sub).getOrThrow()
        consent.clientId = client.clientId
        consent.scopes = scopes
        consent.lifetime = client.consentLifetime
        consentStore.store(consent)
    }

    public func getConsentContext(returnUrl: String): ConsentContextResult {
        let url = URL.parse(returnUrl)
        let clientId = url.queryForm.get(OpenIdConnectParameterNames.ClientId).getOrThrow {
            ValidationException(ValidationErrors.InvalidRequest, "Missing required parameter 'client_id' in return URL")
        }
        let client = clientStore.find(clientId).getOrThrow {
            ValidationException(ValidationErrors.InvalidClient, "Client not found")
        }
        let scope = url.queryForm.get(OpenIdConnectParameterNames.Scope)
        let scopes = getRequestScope(client, scope)
        let resources = resourceValidator.validate(client, GrantTypes.AuthorizationCode, scopes)
        return ConsentContextResult(client, resources)
    }

    private func getRequestScope(client: Client, scope: ?String) {
        var scopes = if (let Some(scope) <- scope && !scope.isEmpty()) {
            scope.split(' ')
        } else {
            client.allowedScopes
        }
        if (client.allowOfflineAccess) {
            return scopes.concat(OpenIdConnectScopes.OfflineAccess)
        }

        return scopes
    }
}

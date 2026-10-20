/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.services.default

import soulsoft_web_http.*
import soulsoft_identity_server.models.*
import soulsoft_identity_protocols_oidc.*
import soulsoft_identity_server.services.*
import soulsoft_identity_server.constants.*

protected class PostBodyClientSecretParser <: IClientSecretParser {
    public prop authenticationMethod: String {
        get() {
            ClientAuthenticationTypes.Post
        }
    }

    public func tryParse(context: HttpContext): ?ParsedSecret {
        let clientId = context.request.form.get(OpenIdConnectParameterNames.ClientId)
        if (let Some(clientId) <- context.request.form.get(OpenIdConnectParameterNames.ClientId)) {
            let clientSecret = context.request.form.get(OpenIdConnectParameterNames.ClientSecret)
            return ParsedSecret(clientId, clientSecret, authenticationMethod)
        }
        return None
    }
}

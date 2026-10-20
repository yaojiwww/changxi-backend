/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.authentication

import soulsoft_identity_claims.*
import soulsoft_extensions_logging.*
import soulsoft_web_authentication.*
import soulsoft_extensions_options.*
import soulsoft_identity_server.services.*
import soulsoft_identity_server.validation.*

protected class LocalApiAuthenticationHandler <: AuthenticationHandler<LocalApiAuthenticationOptions> {
    public init(optionsMonitor: IOptionsMonitor<LocalApiAuthenticationOptions>, logFactory: ILoggerFactory) {
        super(optionsMonitor, logFactory)
    }

    public func handleAuthenticate(): AuthenticateResult {
        let tokenParser = this.context.services.getOrThrow<ITokenParser>()
        if (let Some(token) <- tokenParser.tryParse(this.context)) {
            let tokenValidator = this.context.services.getOrThrow<ITokenValidator>()
            try {
                let tokenValidationResult = tokenValidator.validateAccessToken(token)
                let identity = ClaimsIdentity(options.authenticationType)
                identity.addClaims(tokenValidationResult.claims)
                let properties = AuthenticationProperties()
                if (this.options.saveToken) {
                    properties.storeTokens(AuthenticationToken("access_token", token))
                }
                let subject = ClaimsPrincipal(identity)
                let ticket = AuthenticationTicket(subject, LocalApiAuthenticationDefaults.Scheme, properties)
                return AuthenticateResult.success(ticket)
            } catch (ex: Exception) {
                return AuthenticateResult.fail(ex)
            }
        } else {
            return AuthenticateResult.noResult()
        }
    }
}

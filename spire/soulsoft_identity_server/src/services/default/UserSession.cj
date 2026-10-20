/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.services.default

import soulsoft_web_http.*
import soulsoft_identity_claims.*
import soulsoft_web_authentication.*
import soulsoft_identity_server.models.*
import soulsoft_identity_server.options.*
import soulsoft_identity_server.services.*

protected class UserSession <: IUserSession {
    private let _context: HttpContext
    private let _options: IdentityServerOptions
    private let _handleGenerator: IHandleGenerator

    public init(
        options: IdentityServerOptions,
        httpContextAccess: IHttpContextAccessor,
        handleGenerator: IHandleGenerator
    ) {
        _options = options
        _context = httpContextAccess.context.getOrThrow()
        _handleGenerator = handleGenerator
    }

    public func getUser(): ?ClaimsPrincipal {
        let result = _context.authenticate(_options.authentication.authenticationScheme)
        let identity = result.principal.flatMap {f => f.identity}
        if (result.succeeded && let Some(identity) <- identity && identity.isAuthenticated) {
            return result.principal
        }
        return None
    }

    public func signIn(user: IdentityUser, properties: ?AuthenticationProperties): Unit {
        if (user.sid.isNone()) {
            user.sid = _handleGenerator.generate()
        }
        let subject = user.toPrincipal()
        let scheme = _options.authentication.authenticationScheme
        _context.signIn(scheme, subject, properties)
    }

    public func signOut(properties: ?AuthenticationProperties) {
        let scheme = _options.authentication.authenticationScheme
        _context.signOut(scheme, properties)
    }
}

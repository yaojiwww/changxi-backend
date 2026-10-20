// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_web_authentication_cookies

import std.time.*
import soulsoft_web_http.*
import soulsoft_identity_claims.*
import soulsoft_web_authentication.*
import soulsoft_extensions_logging.*
import soulsoft_extensions_options.*

/**
 * @brief 提供基于 Cookie 的身份验证处理器。
 */
public class CookieAuthenticationHandler <: SignInAuthenticationHandler<CookieAuthenticationOptions> {
    private static const HeaderValueNoCache = "no-cache"
    private static const HeaderValueNoCacheNoStore = "no-cache,no-store"
    private static const HeaderValueEpocDate = "Thu, 01 Jan 1970 00:00:00 GMT"
    private static const SessionIdClaim = "soulsoft_web_authentication_cookies-SessionId"

    private var _signInCalled = false
    private var _signOutCalled = false
    private var _shouldRefresh = false
    private var _sessionKey: ?String = None
    private var _refreshIssuedUtc: ?DateTime = None
    private var _refreshExpiresUtc: ?DateTime = None
    private var _readCookie: ?AuthenticateResult = None
    private var _refreshTicket: ?AuthenticationTicket = None

    /**
     * @brief 创建一个 Cookie 身份验证处理器。
     * @param optionsMonitor Cookie 身份验证选项监视器。
     * @param logFactory 日志工厂。
     */
    public init(optionsMonitor: IOptionsMonitor<CookieAuthenticationOptions>, logFactory: ILoggerFactory) {
        super(optionsMonitor, logFactory)
    }

    protected func handleSignIn(user: ClaimsPrincipal, properties: ?AuthenticationProperties): Unit {
        let propertiesCopy = properties ?? AuthenticationProperties()
        _signInCalled = true
        ensureCookieTicket()

        let cookieOptions = buildCookieOptions()
        var signInContext = CookieSigningInContext(context, scheme, options, user, properties, cookieOptions)
        var issuedUtc = DateTime.now()
        if (let Some(issuedUtcValue) <- signInContext.properties.issuedUtc) {
            issuedUtc = issuedUtcValue
        } else {
            signInContext.properties.issuedUtc = issuedUtc
        }

        if (signInContext.properties.expiresUtc.isNone()) {
            signInContext.properties.expiresUtc = issuedUtc + options.expireTimeSpan
        }

        options.events.signingIn(signInContext)

        if (signInContext.properties.isPersistent) {
            var expiresUtc = signInContext.properties.expiresUtc ?? issuedUtc + options.expireTimeSpan
            signInContext.cookieOptions.expires = expiresUtc
        }

        var ticket = AuthenticationTicket(signInContext.principal.getOrThrow(), signInContext.scheme.name,
            signInContext.properties)

        if (let Some(sessionStore) <- options.sessionStore) {
            if (let Some(sessionKey) <- _sessionKey) {
                sessionStore.renew(sessionKey, ticket)
            } else {
                _sessionKey = sessionStore.store(ticket)
            }

            let identity = ClaimsIdentity(scheme.name)
            identity.addClaim(SessionIdClaim, _sessionKey.getOrThrow())
            let principal = ClaimsPrincipal(identity)

            ticket = AuthenticationTicket(principal, scheme.name, None)
        }

        let cookieName = options.cookie.name.getOrThrow()
        let cookieValue = options.ticketDataFormat.getOrThrow().protect(ticket)
        options.cookieManager.appendResponseCookie(context, cookieName, cookieValue, signInContext.cookieOptions)

        var signedInContext = CookieSignedInContext(context, scheme, signInContext.principal.getOrThrow(),
            signInContext.properties, options)
        options.events.signedIn(signedInContext)
        let shouldHonorReturnUrlParameter = options.loginPath.hasValue && context.request.path == options.loginPath
        applyHeaders(true, shouldHonorReturnUrlParameter, signedInContext.properties)
    }

    protected func handleSignOut(properties: ?AuthenticationProperties): Unit {
        let propertiesCopy = properties ?? AuthenticationProperties()

        _signOutCalled = true

        // Process the request cookie to initialize members like _sessionKey.
        ensureCookieTicket()
        var cookieOptions = buildCookieOptions()

        if (let Some(sessionStore) <- options.sessionStore && let Some(sessionKey) <- _sessionKey) {
            sessionStore.remove(sessionKey)
        }

        var signingOutContext = CookieSigningOutContext(context, scheme, options, properties, cookieOptions)

        options.events.signingOut(signingOutContext)

        options.cookieManager.deleteCookie(context, options.cookie.name.getOrThrow(), signingOutContext.cookieOptions)

        // Only honor the ReturnUrl query string parameter on the logout path
        var shouldHonorReturnUrlParameter = options.logoutPath.hasValue && context.request.path == options.logoutPath
        applyHeaders(true, shouldHonorReturnUrlParameter, signingOutContext.properties)
    }

    protected override func initializeHandler() {
        context.response.onStarting(finishResponse)
    }

    protected override func handleAuthenticate(): AuthenticateResult {
        let result = ensureCookieTicket()
        if (!result.succeeded) {
            return result
        }
        let ticket = result.ticket.getOrThrow()
        checkForRefresh(ticket)
        let validateContext = CookieValidatePrincipalContext(this.context, scheme, options, ticket)
        options.events.validatePrincipal(validateContext)

        if (validateContext.principal.isNone()) {
            return AuthenticateResults.NoPrincipal
        }

        if (validateContext.shouldRenew) {
            requestRefresh(ticket, replacedPrincipal: validateContext.principal)
        }
        let newTicket = AuthenticationTicket(validateContext.principal.getOrThrow(), scheme.name,
            validateContext.properties)
        return AuthenticateResult.success(newTicket)
    }

    protected override func handleForbidden(properties: AuthenticationProperties) {
        var returnUrl = properties.redirectUri
        if (returnUrl.isNone() || returnUrl.getOrThrow().isEmpty()) {
            returnUrl = context.request.path.value + context.request.queryString.value
        }
        var accessDeniedUri = options.accessDeniedPath.toString() +
            QueryString.create(options.returnUrlParameter, returnUrl.getOrThrow()).toString()
        var redirectContext = RedirectContext<CookieAuthenticationOptions>(context, scheme, options, properties,
            buildRedirectUri(accessDeniedUri))
        options.events.redirectToAccessDenied(redirectContext)
    }

    protected override func handleChallenge(properties: AuthenticationProperties) {
        var redirectUri = properties.redirectUri
        if (redirectUri.isNone() || redirectUri.getOrThrow().isEmpty()) {
            redirectUri = context.request.path.value + context.request.queryString.value
        }

        var loginUri = options.loginPath.toString() +
            QueryString.create(options.returnUrlParameter, redirectUri.getOrThrow()).toString()
        var redirectContext = RedirectContext<CookieAuthenticationOptions>(context, scheme, options, properties,
            buildRedirectUri(loginUri))
        options.events.redirectToLogin(redirectContext)
    }

    private func checkForRefresh(ticket: AuthenticationTicket) {
        let currentUtc = DateTime.now()
        let issuedUtc = ticket.properties.issuedUtc
        let expiresUtc = ticket.properties.expiresUtc
        let allowRefresh = ticket.properties.allowRefresh ?? true
        if (let Some(issuedUtc) <- issuedUtc && let Some(expiresUtc) <- expiresUtc && options.slidingExpiration &&
            allowRefresh) {
            let timeElapsed = currentUtc - issuedUtc
            let timeRemaining = expiresUtc - currentUtc
            let eventContext = CookieSlidingExpirationContext(context, scheme, options, ticket, timeElapsed,
                timeRemaining)
            eventContext.shouldRenew = timeRemaining < timeElapsed
            options.events.checkSlidingExpiration(eventContext)
            if (eventContext.shouldRenew) {
                requestRefresh(ticket)
            }
        }
    }

    private func requestRefresh(ticket: AuthenticationTicket, replacedPrincipal!: ?ClaimsPrincipal = None) {
        let issuedUtc = ticket.properties.issuedUtc
        let expiresUtc = ticket.properties.expiresUtc
        if (let Some(issuedUtc) <- issuedUtc && let Some(expiresUtc) <- expiresUtc) {
            _shouldRefresh = true
            let currentUtc = DateTime.now()
            _refreshIssuedUtc = currentUtc
            let timeSpan = expiresUtc - issuedUtc
            _refreshExpiresUtc = currentUtc + timeSpan
            _refreshTicket = cloneTicket(ticket, replacedPrincipal)
        }
    }

    private func cloneTicket(ticket: AuthenticationTicket, replacedPrincipal: ?ClaimsPrincipal) {
        var principal = replacedPrincipal ?? ticket.principal
        var newPrincipal = ClaimsPrincipal()
        for (identity in principal.identities) {
            newPrincipal.addIdentity(identity.clone())
        }
        var newProperties = AuthenticationProperties()
        for ((key, value) in ticket.properties.items) {
            newProperties.items[key] = value
        }
        return AuthenticationTicket(newPrincipal, ticket.authenticationScheme, newProperties)
    }

    private func ensureCookieTicket() {
        if (let Some(readCookie) <- _readCookie) {
            return readCookie
        }
        _readCookie = readCookieTicket()
        return _readCookie.getOrThrow()
    }

    private func readCookieTicket() {
        let cookieName = options.cookie.name ?? String.empty
        let cookieValue = options.cookieManager.getRequestCookie(context, cookieName) ?? String.empty
        if (cookieValue.isEmpty()) {
            return AuthenticateResult.noResult()
        }
        let ticketDataFormat = this.options.ticketDataFormat.getOrThrow()
        let ticketOption = ticketDataFormat.unprotect(cookieValue)
        if (ticketOption.isNone()) {
            return AuthenticateResults.FailedUnprotectingTicket
        }
        var ticket = ticketOption.getOrThrow()

        if (let Some(sessionStore) <- options.sessionStore) {
            if (let Some(claim) <- ticket.principal.findFirst {c => c.`type` == SessionIdClaim}) {
                if (let Some(value) <- sessionStore.retrieve(claim.value)) {
                    ticket = value
                    _sessionKey = claim.value
                } else {
                    return AuthenticateResults.MissingIdentityInSession
                }
            } else {
                return AuthenticateResults.MissingSessionId
            }
        }

        let currentUtc = DateTime.now()
        if (let Some(expiresUtc) <- ticket.properties.expiresUtc && expiresUtc < currentUtc) {
            if (let Some(sessionStore) <- options.sessionStore) {
                sessionStore.remove(_sessionKey.getOrThrow())
                _sessionKey = None
            }
            return AuthenticateResults.ExpiredTicket
        }
        return AuthenticateResult.success(ticket)
    }

    private func finishResponse() {
        if (!_shouldRefresh || _signInCalled || _signOutCalled) {
            return
        }
        var ticket = _refreshTicket
        if (_refreshTicket.isSome()) {
            var ticket = _refreshTicket.getOrThrow()
            let properties = ticket.properties
            if (let Some(refreshIssuedUtc) <- _refreshIssuedUtc) {
                properties.issuedUtc = refreshIssuedUtc
            }
            if (let Some(refreshExpiresUtc) <- _refreshExpiresUtc) {
                properties.expiresUtc = refreshExpiresUtc
            }

            if (let Some(sessionStore) <- options.sessionStore && let Some(sessionKey) <- _sessionKey) {
                sessionStore.renew(sessionKey, ticket)
                let identity = ClaimsIdentity(scheme.name)
                identity.addClaim(SessionIdClaim, sessionKey)
                let principal = ClaimsPrincipal(identity)
                ticket = AuthenticationTicket(principal, scheme.name, None)
            }

            let cookieValue = options.ticketDataFormat.getOrThrow().protect(ticket)
            let cookieOptions = buildCookieOptions()
            if (properties.isPersistent == true && let Some(refreshExpiresUtc) <- _refreshExpiresUtc) {
                cookieOptions.expires = refreshExpiresUtc.inUTC()
            }
            let cookieName = options.cookie.name.getOrThrow()
            options.cookieManager.appendResponseCookie(context, cookieName, cookieValue, cookieOptions)
            applyHeaders(false, false, properties)
        }
    }

    private func applyHeaders(shouldRedirect: Bool, shouldHonorReturnUrlParameter: Bool,
        properties: AuthenticationProperties) {
        let responseHeaders = this.context.response.headers
        responseHeaders.cacheControl = [HeaderValueNoCacheNoStore]
        responseHeaders.pragma = [HeaderValueNoCache]
        responseHeaders.expires = [HeaderValueEpocDate]
        if (shouldRedirect && context.response.statusCode == StatusCodes.Ok) {
            var redirectUri = properties.redirectUri
            if (shouldHonorReturnUrlParameter && (redirectUri ?? String.empty).isEmpty()) {
                redirectUri = context.request.query.get(options.returnUrlParameter)
                if ((redirectUri ?? String.empty).isEmpty() || !isHostRelative(redirectUri.getOrThrow())) {
                    redirectUri = None
                }
            }
            if (let Some(redirectUri) <- redirectUri) {
                let redirectContext = RedirectContext<CookieAuthenticationOptions>(context, scheme, options, properties,
                    redirectUri)
                options.events.redirectToReturnUrl(redirectContext)
            }
        }
    }

    private func isHostRelative(path: String) {
        if (path.isEmpty()) {
            return false
        }
        if (path.size == 1) {
            return path[0] == b'/'
        }
        return path[0] == b'/' && path[1] != b'/' && path[1] != b'\\'
    }

    private func buildRedirectUri(targetPath: String) {
        //return "${context.request.scheme}://${context.request.host}${targetPath}"
        return targetPath
    }

    private func buildCookieOptions() {
        var cookieOptions = options.cookie.build(this.context)
        cookieOptions.expires = None
        return cookieOptions
    }
}

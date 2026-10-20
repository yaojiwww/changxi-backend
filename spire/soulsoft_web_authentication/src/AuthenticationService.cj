// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_authentication

import std.reflect.*
import std.collection.*
import soulsoft_web_http.*
import soulsoft_identity_claims.*
import soulsoft_extensions_options.*

class AuthenticationService <: IAuthenticationService {
    private let _options: AuthenticationOptions
    private let _schemes: IAuthenticationSchemeProvider
    private let _handlers: IAuthenticationHandlerProvider

    public init(schemes: IAuthenticationSchemeProvider, handlers: IAuthenticationHandlerProvider,
        options: IOptions<AuthenticationOptions>) {
        _schemes = schemes
        _handlers = handlers
        _options = options.value
    }

    public func authenticate(context: HttpContext, scheme: ?String): AuthenticateResult {
        let authenticateScheme = if (let Some(scheme) <- scheme) {
            scheme
        } else {
            if (let Some(scheme) <- _schemes.getDefaultAuthenticateScheme().flatMap {f => f.name}) {
                scheme
            } else {
                throw UnsupportedException(
                    "No authenticationScheme was specified, and there was no DefaultAuthenticateScheme found. The default schemes can be set using either addAuthentication(defaultScheme: String) or addAuthentication(configureOptions: (AuthenticationOptions)->Unit).")
            }
        }

        let handler = _handlers.getHandler(context, authenticateScheme) ?? throw createMissingHandlerException(
            authenticateScheme)
        return handler.authenticate()
    }

    public func challenge(context: HttpContext, scheme: ?String, properties: ?AuthenticationProperties) {
        let challengeScheme = if (let Some(scheme) <- scheme) {
            scheme
        } else {
            if (let Some(scheme) <- _schemes.getDefaultChallengeScheme().flatMap {f => f.name}) {
                scheme
            } else {
                throw UnsupportedException(
                    "No authenticationScheme was specified, and there was no DefaultChallengeScheme found. The default schemes can be set using either addAuthentication(string defaultScheme) or addAuthentication(configureOptions: (AuthenticationOptions)->Unit).")
            }
        }

        let handler = _handlers.getHandler(context, challengeScheme) ?? throw createMissingHandlerException(
            challengeScheme)
        handler.challenge(properties)
    }

    public func forbid(context: HttpContext, scheme: ?String, properties: ?AuthenticationProperties) {
        let forbidScheme = if (let Some(scheme) <- scheme) {
            scheme
        } else {
            if (let Some(scheme) <- _schemes.getDefaultForbidScheme().flatMap {f => f.name}) {
                scheme
            } else {
                throw UnsupportedException(
                    "No authenticationScheme was specified, and there was no DefaultChallengeScheme found. The default schemes can be set using either addAuthentication(defaultScheme: String) or addAuthentication(configureOptions: (AuthenticationOptions)->Unit).")
            }
        }

        let handler = _handlers.getHandler(context, forbidScheme) ?? throw createMissingHandlerException(forbidScheme)
        handler.forbid(properties)
    }

    public func signIn(context: HttpContext, scheme: ?String, principal: ClaimsPrincipal,
        properties: ?AuthenticationProperties): Unit {
        if (this._options.requireAuthenticatedSignIn) {
            if (let Some(identity) <- principal.identity) {
                if (!identity.isAuthenticated) {
                    throw UnsupportedException(
                        "signIn when principal.Identity.IsAuthenticated is false is not allowed when AuthenticationOptions.requireAuthenticatedSignIn is true.")
                }
            } else {
                throw UnsupportedException(
                    "signIn when principal.Identity == null is not allowed when AuthenticationOptions.requireAuthenticatedSignIn is true.")
            }
        }

        let signInScheme = if (scheme.isNone()) {
            _schemes.getDefaultSignInScheme().flatMap {f => f.name}
        } else {
            scheme
        }

        if (let Some(signInScheme) <- signInScheme) {
            let handler = _handlers.getHandler(context, signInScheme).getOrThrow {
                createMissingSignInHandlerException(signInScheme)
            }
            if (let signInHandler: IAuthenticationSignInHandler <- handler) {
                return signInHandler.signIn(principal, properties)
            } else {
                throw createMismatchedSignInHandlerException(signInScheme, handler)
            }
        } else {
            throw UnsupportedException(
                "No authenticationScheme was specified, and there was no DefaultSignInScheme found. The default schemes can be set using either addAuthentication(defaultScheme: String) or addAuthentication(configureOptions: (AuthenticationOptions)->Unit).")
        }
    }

    public func signOut(context: HttpContext, scheme: ?String, properties: ?AuthenticationProperties): Unit {
        let signOutScheme = if (scheme.isNone()) {
            _schemes.getDefaultSignOutScheme().flatMap {f => f.name}
        } else {
            scheme
        }

        if (let Some(signOutScheme) <- signOutScheme) {
            var handler = _handlers.getHandler(context, signOutScheme).getOrThrow {
                createMissingSignOutHandlerException(signOutScheme)
            }
            if (let signOutHandler: IAuthenticationSignOutHandler <- handler) {
                signOutHandler.signOut(properties)
            } else {
                throw createMismatchedSignOutHandlerException(signOutScheme, handler)
            }
        } else {
            throw UnsupportedException(
                "No authenticationScheme was specified, and there was no DefaultSignOutScheme found. The default schemes can be set using either addAuthentication(defaultScheme: String) or addAuthentication(configureOptions: (AuthenticationOptions)->Unit).");
        }
    }

    private func createMissingHandlerException(scheme: String): Exception {
        let schemes = String.join(_schemes.getAllSchemes() |> map {f => f.name} |> collectArray, delimiter: ', ')
        let footer = " Did you forget to call addAuthentication().Add[SomeAuthHandler](\"${scheme}\",...)?"

        if (schemes.isEmpty()) {
            throw UnsupportedException("No authentication handlers are registered.${footer}")
        }

        return UnsupportedException(
            "No authentication handler is registered for the scheme '${scheme}'. The registered schemes are: ${schemes}.${footer}")
    }

    private func createMissingSignInHandlerException(scheme: String) {
        let schemes = getAllSignInSchemeNames()
        let footer = " Did you forget to call addAuthentication().addCookie(\"${scheme}\",...)?"
        if (schemes.isEmpty()) {
            return UnsupportedException("No sign-in authentication handlers are registered." + footer)
        }
        return UnsupportedException(
            "No sign-in authentication handler is registered for the scheme '${scheme}'. The registered sign-in schemes are: ${schemes}." +
                footer)
    }

    private func createMismatchedSignInHandlerException(scheme: String, handler: IAuthenticationHandler) {
        let schemes = getAllSignInSchemeNames()
        let mismatchError = "The authentication handler registered for scheme '${scheme}' is '${TypeInfo.of(handler).name}' which cannot be used for signIn. "
        if (schemes.isEmpty()) {
            return UnsupportedException(
                mismatchError +
                    "Did you forget to call addAuthentication().addCookie(\"Cookies\") and signIn(\"Cookies\",...)?")
        }
        return UnsupportedException(mismatchError + "The registered sign-in schemes are: ${schemes}.")
    }

    private func createMissingSignOutHandlerException(scheme: String) {
        let schemes = getAllSignOutSchemeNames()

        let footer = " Did you forget to call addAuthentication().addCookie(\"${scheme}\",...)?";

        if (schemes.isEmpty()) {
            return UnsupportedException("No sign-out authentication handlers are registered." + footer);
        }

        return UnsupportedException(
            "No sign-out authentication handler is registered for the scheme '${scheme}'. The registered sign-out schemes are: ${schemes}." +
                footer)
    }

    private func createMismatchedSignOutHandlerException(scheme: String, handler: IAuthenticationHandler) {
        let schemes = getAllSignOutSchemeNames()

        let mismatchError = "The authentication handler registered for scheme '${scheme}' is '${TypeInfo.of(handler).name}' which cannot be used for signOut. "

        if (schemes.isEmpty()) {
            return UnsupportedException(
                mismatchError +
                    "Did you forget to call addAuthentication().addCookie(\"Cookies\") and signOut(\"Cookies\",...)?")
        }

        return UnsupportedException(mismatchError + "The registered sign-out schemes are: ${schemes}.")
    }

    private func getAllSignInSchemeNames() {
        let schemes = _schemes.getAllSchemes() |>
            filter {f => f.handlerType.isSubtypeOf(TypeInfo.of<IAuthenticationSignInHandler>())} |> map {f => f.name} |>
            collectArray
        return String.join(schemes, delimiter: ',')
    }

    private func getAllSignOutSchemeNames() {
        let schemes = _schemes.getAllSchemes() |>
            filter {f => f.handlerType.isSubtypeOf(TypeInfo.of<IAuthenticationSignOutHandler>())} |> map {f => f.name} |>
            collectArray
        return String.join(schemes, delimiter: ',')
    }
}

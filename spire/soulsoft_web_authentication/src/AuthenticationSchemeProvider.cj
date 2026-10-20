// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_authentication

import std.sync.*
import std.reflect.*
import std.collection.*
import soulsoft_extensions_options.*

class AuthenticationSchemeProvider <: IAuthenticationSchemeProvider {
    private let _lock = Mutex()
    private let _options: AuthenticationOptions
    private let _schemes = HashMap<String, AuthenticationScheme>()
    private let _requestHandlers = ArrayList<AuthenticationScheme>()

    private var _schemesCopy: Array<AuthenticationScheme> = []
    private var _requestHandlersCopy: Array<AuthenticationScheme> = []

    public init(options: IOptions<AuthenticationOptions>) {
        _options = options.value
        for (pattern in _options.schemes) {
            addScheme(pattern)
        }
    }

    public func addScheme(scheme: AuthenticationScheme) {
        if (_schemes.contains(scheme.name)) {
            throw UnsupportedException("Scheme already exists: ${scheme.name}")
        }
        synchronized(_lock) {
            if (!tryAddScheme(scheme)) {
                throw UnsupportedException("Scheme already exists: ${scheme.name}")
            }
        }
    }

    public func tryAddScheme(scheme: AuthenticationScheme) {
        if (_schemes.contains(scheme.name)) {
            return false
        }
        synchronized(_lock) {
            if (scheme.handlerType.isSubtypeOf(TypeInfo.of<IAuthenticationRequestHandler>())) {
                _requestHandlers.add(scheme)
                _requestHandlersCopy = _requestHandlers.toArray()
            }
            _schemes[scheme.name] = scheme
            _schemesCopy = _schemes.values().toArray()
            return true
        }
    }

    public func removeScheme(name: String) {
        if (!_schemes.contains(name)) {
            return
        }
        synchronized(_lock) {
            if (!_schemes.contains(name)) {
                return
            }

            _requestHandlers.removeIf {f => f.name == name}
            _requestHandlersCopy = _requestHandlers.toArray()

            _schemes.remove(name)
            _schemesCopy = _schemes.values().toArray()
        }
    }

    public func getScheme(name: String): ?AuthenticationScheme {
        if (_schemes.contains(name)) {
            return _schemes[name]
        }
        return None
    }

    private func getDefaultScheme(): ?AuthenticationScheme {
        if (let Some(name) <- _options.defaultScheme) {
            return getScheme(name)
        }
        return None
    }

    public func getDefaultAuthenticateScheme(): ?AuthenticationScheme {
        if (let Some(name) <- _options.defaultAuthenticateScheme) {
            return getScheme(name)
        }
        return getDefaultScheme()
    }

    public func getDefaultChallengeScheme(): ?AuthenticationScheme {
        if (let Some(name) <- _options.defaultChallengeScheme) {
            return getScheme(name)
        }
        return getDefaultScheme()
    }

    public func getDefaultForbidScheme(): ?AuthenticationScheme {
        if (let Some(name) <- _options.defaultForbidScheme) {
            return getScheme(name)
        }
        return getDefaultScheme()
    }

    public func getDefaultSignInScheme(): ?AuthenticationScheme {
        if (let Some(defaultScheme) <- _options.defaultSignInScheme) {
            return getScheme(defaultScheme)
        }
        return getDefaultScheme()
    }

    public func getDefaultSignOutScheme(): ?AuthenticationScheme {
        if (let Some(defaultScheme) <- _options.defaultSignOutScheme) {
            return getScheme(defaultScheme)
        }
        return getDefaultSignInScheme()
    }

    public func getAllSchemes(): Collection<AuthenticationScheme> {
        return _schemesCopy
    }

    public func getRequestHandlerSchemes(): Collection<AuthenticationScheme> {
        _requestHandlersCopy
    }
}

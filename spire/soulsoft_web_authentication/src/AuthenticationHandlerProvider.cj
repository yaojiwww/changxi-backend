// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_authentication

import std.collection.*
import soulsoft_web_http.*
import soulsoft_extensions_injection.*

class AuthenticationHandlerProvider <: IAuthenticationHandlerProvider {
    private let _schemes: IAuthenticationSchemeProvider
    private let _handlerMap = HashMap<String, IAuthenticationHandler>()

    public AuthenticationHandlerProvider(schemes: IAuthenticationSchemeProvider) {
        _schemes = schemes
    }

    public func getHandler(context: HttpContext, schemeName: String): ?IAuthenticationHandler {
        // Check cache first
        if (_handlerMap.contains(schemeName)) {
            return _handlerMap[schemeName]
        }

        if (let Some(scheme) <- _schemes.getScheme(schemeName)) {
            let handler: Any = if (let Some(handler) <- context.services.get(scheme.handlerType)) {
                handler
            } else {
                ActivatorUtilities.createInstance(context.services, scheme.handlerType)
            }
            if (let handler: IAuthenticationHandler <- handler) {
                handler.initialize(scheme, context)
                // Cache the handler
                _handlerMap[schemeName] = handler
                return handler
            }
        }
        return None
    }
}

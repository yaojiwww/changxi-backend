// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_web_authentication_cookies

import soulsoft_extensions_options.*
import soulsoft_extensions_protection.*

class PostConfigureCookieAuthenticationOptions <: IConfigureAfterOptions<CookieAuthenticationOptions> {
    private let _protectionProvider: IDataProtectionProvider

    public init(protectionProvider: IDataProtectionProvider) {
        _protectionProvider = protectionProvider
    }

    public func configureAfter(name: ?String, options: CookieAuthenticationOptions): Unit {
        if ((options.cookie.name ?? String.empty).isEmpty()) {
            options.cookie.name = CookieAuthenticationDefaults.CookiePrefix + (name ?? String.empty)
        }
        if (options.dataProtector.isNone()) {
            options.dataProtector = _protectionProvider.createProtector("soulsoft_web_authentication_cookies")
        }
        if (options.ticketDataFormat.isNone()) {
            options.ticketDataFormat = TicketDataFormat(options.dataProtector.getOrThrow())
        }
    }
}

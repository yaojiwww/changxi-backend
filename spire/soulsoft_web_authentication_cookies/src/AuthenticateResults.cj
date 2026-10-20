// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_web_authentication_cookies

import soulsoft_web_authentication.*

class AuthenticateResults {
    internal static let FailedUnprotectingTicket = AuthenticateResult.fail("Unprotect ticket failed");
    internal static let MissingSessionId = AuthenticateResult.fail("SessionId missing");
    internal static let MissingIdentityInSession = AuthenticateResult.fail("Identity missing in session store");
    internal static let ExpiredTicket = AuthenticateResult.fail("Ticket expired");
    internal static let NoPrincipal = AuthenticateResult.fail("No principal.");
}
// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_authorization

import std.collection.*
import soulsoft_identity_claims.*

protected class SecurityHelper {
    public static func mergeUserPrincipal(existingPrincipal: ?ClaimsPrincipal, additionalPrincipal: ?ClaimsPrincipal): ClaimsPrincipal {
        if (existingPrincipal.isNone() && let Some(additionalPrincipal) <- additionalPrincipal) {
            return additionalPrincipal
        }

        let newPrincipal = ClaimsPrincipal()
        if (let Some(additionalPrincipal) <- additionalPrincipal) {
            newPrincipal.addIdentities(additionalPrincipal.identities)
        }

        if (let Some(existingPrincipal) <- existingPrincipal) {
            let identities = existingPrincipal.identities |> filter {f => f.isAuthenticated || f.claims.size > 0} |>
                collectArray
            newPrincipal.addIdentities(identities)
        }
        return newPrincipal
    }
}

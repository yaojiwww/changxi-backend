/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.validation.default

import std.collection.*
import soulsoft_identity_claims.*
import soulsoft_identity_server.validation.*

protected class UserInfoRequestValidator <: IUserInfoRequestValidator {
    public UserInfoRequestValidator(let tokenValidator: ITokenValidator) {}

    public func validate(accessToken: String) {
        let tokenResult = tokenValidator.validateAccessToken(accessToken)
        let hasSub = tokenResult.claims |> any {f => f.`type` == ClaimTypes.Sub}
        if (!hasSub) {
            throw ValidationException(ValidationErrors.InvalidClient, "Token contains no sub claim")
        }
        let subject = ClaimsPrincipal(ClaimsIdentity("UserInfo", tokenResult.claims))
        return ValidatedUserInfoRequest(tokenResult.client, subject)
    }
}

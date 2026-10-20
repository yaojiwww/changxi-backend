/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.validation.default

import soulsoft_web_http.*
import soulsoft_identity_claims.*
import soulsoft_identity_server.stores.*
import soulsoft_identity_server.models.*
import soulsoft_identity_server.validation.*

protected class EndSessionRequestValidator <: IEndSessionRequestValidator {
    public EndSessionRequestValidator(let clientStore: IClientStore, let tokenValidator: ITokenValidator) {}

    public func validate(parameters: IValueProvider, subject: ClaimsPrincipal) {
        let idTokenHint = parameters.get("id_token_hint")
        let postLogoutRedirectUri = parameters.get("post_logout_redirect_uri")
        let state = parameters.get("state")

        var client: ?Client = None

        if (let Some(token) <- idTokenHint) {
            let tokenValidationResult = tokenValidator.validateIdentityToken(token)

            // 安全检查：验证 token 中的 subject 是否与当前用户匹配
            validateSubject(tokenValidationResult, subject)

            // 验证 post_logout_redirect_uri
            if (let Some(uri) <- postLogoutRedirectUri) {
                validatePostLogoutRedirectUri(tokenValidationResult.client, uri)
            }

            client = tokenValidationResult.client
        }

        return ValidatedEndSessionRequest(client, postLogoutRedirectUri, state, idTokenHint)
    }

    /// 验证 post_logout_redirect_uri 是否在客户端的允许列表中
    private func validatePostLogoutRedirectUri(client: Client, redirectUri: String) {
        if (!client.postLogoutRedirectUris.contains(redirectUri)) {
            throw ValidationException(
                ValidationErrors.InvalidRequest,
                "post_logout_redirect_uri is not registered for the client"
            )
        }
    }

    /// 验证 ID Token 中的 subject 是否与当前登录用户匹配
    private func validateSubject(tokenResult: IdentityTokenValidationResult, currentSubject: ClaimsPrincipal) {
        let tokenSub = ClaimsIdentity(tokenResult.claims).findFirstValue(ClaimTypes.Sub)
        let currentSub = currentSubject.findFirstValue(ClaimTypes.Sub)

        if (tokenSub != currentSub) {
            throw ValidationException(
                ValidationErrors.InvalidRequest,
                "id_token_hint does not match the current user"
            )
        }
    }
}

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.endpoints.generators.default

import std.time.*
import soulsoft_identity_claims.*
import soulsoft_identity_server.stores.*
import soulsoft_identity_server.models.*
import soulsoft_identity_server.validation.*
import soulsoft_identity_server.endpoints.generators.*

protected class AuthorizeResponseGenerator <: IAuthorizeResponseGenerator {
    public AuthorizeResponseGenerator(let authorizationCodeStore: IAuthorizationCodeStore) {
    }

    public func createResponse(request: ValidatedAuthorizeRequest): AuthorizeResponse {
        let authorizationCode = createAuthorizationCode(request)
        let code = authorizationCodeStore.store(authorizationCode)
        return AuthorizeResponse(code)
    }

    private func createAuthorizationCode(request: ValidatedAuthorizeRequest) {
        let authorizationCode = AuthorizationCode()
        authorizationCode.clientId = request.clientId
        authorizationCode.requestedScopes = request.resources.getScopes()
        authorizationCode.lifetime = request.client.authorizationCodeLifetime
        authorizationCode.subject = request.subject

        // RFC 6749: 存储 redirect_uri 用于后续验证
        authorizationCode.redirectUri = request.redirectUri

        // RFC 7636: 存储 PKCE 参数
        authorizationCode.codeChallenge = request.codeChallenge
        authorizationCode.codeChallengeMethod = request.codeChallengeMethod

        // OpenID Connect: 存储 nonce
        authorizationCode.nonce = request.nonce

        // 会话关联
        authorizationCode.sessionId = request.subject.findFirstValue(ClaimTypes.Sid)

        return authorizationCode
    }
}

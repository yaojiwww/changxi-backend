/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.services.default

import std.time.*
import soulsoft_identity_server.stores.*
import soulsoft_identity_server.models.*
import soulsoft_identity_server.services.*

protected class RefreshTokenService <: IRefreshTokenService {
    public RefreshTokenService(let refreshTokenStore: IRefreshTokenStore) {
    }

    public func updateRefreshToken(request: RefreshTokenUpdateRequest) {
        if (request.client.refreshTokenUsage == RefreshTokenUsage.Once) {
            refreshTokenStore.remove(request.refreshTokenHandle)
            return refreshTokenStore.store(request.refreshToken)
        } else {
            var refreshToken = request.refreshToken
            refreshToken.consumedTime = DateTime.now().inUTC()
            refreshTokenStore.update(request.refreshTokenHandle, refreshToken)
            return request.refreshTokenHandle
        }
    }

    public func createRefreshToken(request: RefreshTokenCreationRequest): String {
        let token = RefreshToken()
        token.subject = request.accessToken.subject
        token.clientId = request.client.clientId
        token.scopes = request.resources.getScopes()

        // 根据刷新令牌过期类型选择合适的生命周期
        token.lifetime = match (request.client.refreshTokenExpiration) {
            case RefreshTokenExpiration.Absolute => request.client.absoluteRefreshTokenLifetime
            case RefreshTokenExpiration.Sliding => request.client.slidingRefreshTokenLifetime
        }

        return refreshTokenStore.store(token)
    }
}

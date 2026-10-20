/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.endpoints.generators.default

import std.collection.*
import soulsoft_identity_claims.*

import soulsoft_identity_server.services.*
import soulsoft_identity_server.validation.*
import soulsoft_identity_server.endpoints.generators.*

protected class UserInfoResponseGenerator <: IUserInfoResponseGenerator {
    public UserInfoResponseGenerator(let profileService: IProfileService, let resourceManager: ResourceManager) {
    }

    public func createResponse(request: ValidatedUserInfoRequest): Collection<Claim> {
        // 提取 scope claim
        let scopes = request.subject.claims |> filter {f => f.`type` == ClaimTypes.Scope} |>
            map {f => f.value} |> collectArray

        // 获取 resources
        let resources = resourceManager.findAll(scopes)

        // 构建 ProfileDataRequest
        let profileRequest = ProfileDataRequest(ProfileDataCaller.UserInfo, request.client,
            request.subject, resources)

        // 根据 access token 的 scopes 获取用户信息
        let profileClaims = profileService.getProfileData(profileRequest)

        // 构建最终的 claims
        let outputClaims = ArrayList<Claim>(profileClaims)
        if (!(outputClaims |> any {f => f.`type` == ClaimTypes.Sub})) {
            let sub = request.subject.findFirstValue(ClaimTypes.Sub).getOrThrow()
            outputClaims.add(Claim(ClaimTypes.Sub, sub))
        }

        return outputClaims
    }
}

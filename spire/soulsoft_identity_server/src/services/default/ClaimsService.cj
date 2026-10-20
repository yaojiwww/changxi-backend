/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.services.default

import std.collection.*
import soulsoft_identity_claims.*
import soulsoft_identity_server.services.*

protected class ClaimsService <: IClaimService {
    public ClaimsService(let profileService: IProfileService) {
    }

    public func getAccessTokenClaims(request: ClaimsRequest): Collection<Claim> {
        let claims = ArrayList<Claim>(request.client.allowedClaims)
        claims.add(all: getStandardSubjectClaims(request.subject))
        for (scope in request.resources.getScopes()) {
            claims.add(Claim(ClaimTypes.Scope, scope))
        }
        let profileDataRequest = ProfileDataRequest(ProfileDataCaller.AccessToken, request.client, request.subject,
            request.resources)
        let additionalClaimTypes = request.getAccessTokenClaimTypes()
        let profileClaims = profileService.getProfileData(profileDataRequest)
        for (claim in profileClaims) {
            if (additionalClaimTypes.contains(claim.`type`)) {
                claims.add(claim)
            }
        }
        return claims
    }

    public func getIdentityTokenClaims(request: ClaimsRequest): Collection<Claim> {
        let claims = ArrayList<Claim>()
        claims.add(all: getStandardSubjectClaims(request.subject))

        let profileDataRequest = ProfileDataRequest(ProfileDataCaller.IdentityToken, request.client, request.subject,
            request.resources)
        let profileClaims = profileService.getProfileData(profileDataRequest)
        let additionalClaimTypes = request.getIdentityTokenClaimTypes()
        for (claim in profileClaims) {
            if (additionalClaimTypes.contains(claim.`type`)) {
                claims.add(claim)
            }
        }

        return claims
    }

    private func getStandardSubjectClaims(subject: ClaimsPrincipal) {
        let claims = ArrayList<Claim>()
        claims.add(Claim(ClaimTypes.Sub, subject.findFirstValue(ClaimTypes.Sub).getOrThrow()))
        claims.add(Claim(ClaimTypes.Idp, subject.findFirstValue(ClaimTypes.Idp).getOrThrow()))
        claims.add(Claim(ClaimTypes.Amr, subject.findFirstValue(ClaimTypes.Amr).getOrThrow()))
        claims.add(Claim(ClaimTypes.AuthTime, subject.findFirstValue(ClaimTypes.AuthTime).getOrThrow()))
        return claims
    }
}

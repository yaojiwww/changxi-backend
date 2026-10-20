/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.stores.default

import std.collection.*
import soulsoft_identity_server.stores.*
import soulsoft_identity_server.models.*

protected class ApiResourceMemoryStore <: IApiResourceStore {
    private let _apiResources: Collection<ApiResource>

    public init(apiResources: Collection<ApiResource>) {
        _apiResources = apiResources
    }

    public func findAll(scopes: Array<String>): Collection<ApiResource> {
        _apiResources |> filter {f => f.enabled && f.discoveryDocument} |> filter {f => f.allowedScopes |> any {a => scopes.contains(a)}} |>
            collectArray
    }

    public func getDiscoveryDocumentClaimTypes(): Collection<String> {
        _apiResources |> filter {f => f.enabled && f.discoveryDocument} |> flatMap {f => f.claimTypes} |> collectArray
    }
}

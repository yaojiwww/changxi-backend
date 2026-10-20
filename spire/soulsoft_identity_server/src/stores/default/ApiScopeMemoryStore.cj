/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.stores.default

import std.collection.*
import soulsoft_identity_server.stores.*
import soulsoft_identity_server.models.*

protected class ApiScopeMemoryStore <: IApiScopeStore {
    private let _apiScopes: Collection<ApiScope>

    public init(apiScopes: Collection<ApiScope>) {
        _apiScopes = apiScopes
    }

    public func findAll(scopes: Array<String>): Collection<ApiScope> {
        _apiScopes |> filter {f => f.enabled && scopes.contains(f.name)} |> collectArray
    }

    public func getDiscoveryDocumentScopes(): Collection<String> {
        _apiScopes |> filter {f => f.enabled && f.discoveryDocument} |> map {f => f.name} |> collectArray
    }

    public func getDiscoveryDocumentClaimTypes(): Collection<String> {
        _apiScopes |> filter {f => f.enabled && f.discoveryDocument} |> flatMap {f => f.claimTypes} |> collectArray
    }
}

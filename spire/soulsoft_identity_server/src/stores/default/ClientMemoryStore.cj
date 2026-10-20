/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.stores.default

import std.collection.*
import soulsoft_identity_server.stores.*
import soulsoft_identity_server.models.*

protected class ClientMemoryStore <: IClientStore {
    private let _clients: Collection<Client>

    public init(clients: Collection<Client>) {
        _clients = clients
    }

    public func find(clientId: String): ?Client {
        _clients |> filter {f => f.clientId == clientId} |> first
    }
}

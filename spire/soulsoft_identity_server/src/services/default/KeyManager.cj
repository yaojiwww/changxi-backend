/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.services.default

import soulsoft_identity_tokens.*
import soulsoft_identity_server.stores.*
import soulsoft_identity_server.services.*

protected class KeyManager  <: IKeyManager {

    private let _store: ISigningCredentialStore

    public init(store: ISigningCredentialStore){
        _store = store
    }

    public func getActiveSigningKeys(): Collection<SigningCredentials> {
        return _store.getAllSigningCredentials()
    }
}

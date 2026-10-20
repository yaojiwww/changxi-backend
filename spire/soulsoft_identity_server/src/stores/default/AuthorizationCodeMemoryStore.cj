/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.stores.default

import soulsoft_extensions_caching.*
import soulsoft_identity_server.models.*
import soulsoft_identity_server.stores.*
import soulsoft_identity_server.services.*

protected class AuthorizationCodeMemoryStore <: MemoryCacheBase<AuthorizationCode> & IAuthorizationCodeStore {
    public AuthorizationCodeMemoryStore(cache: IDistributedCache, let handleGenerator: IHandleGenerator) {
        super(cache)
    }

    public func find(code: String) {
        return super.getItem(code)
    }

    public func store(authorizationCode: AuthorizationCode): String {
        let handle = handleGenerator.generate()
        super.storeItem(handle, authorizationCode, Duration.second * authorizationCode.lifetime)
        return handle
    }

    public func remove(code: String): Unit {
        super.removeItem(code)
    }
}

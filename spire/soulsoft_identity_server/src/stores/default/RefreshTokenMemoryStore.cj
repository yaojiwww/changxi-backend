/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.stores.default

import soulsoft_extensions_caching.*
import soulsoft_identity_server.stores.*
import soulsoft_identity_server.models.*
import soulsoft_identity_server.services.*

protected class RefreshTokenMemoryStore <: MemoryCacheBase<RefreshToken> & IRefreshTokenStore {
    public RefreshTokenMemoryStore(let cache: IDistributedCache, let handleGenerator: IHandleGenerator) {
        super(cache)
    }

    public func find(key: String): ?RefreshToken {
        return super.getItem(key)
    }

    public func store(token: RefreshToken): String {
        let handle = handleGenerator.generate(32)
        super.storeItem(handle, token, Duration.second * token.lifetime)
        return handle
    }

    public func update(key: String, token: RefreshToken) {
        super.storeItem(key, token, Duration.second * token.lifetime)
    }

    public func remove(key: String): Unit {
        cache.remove(key)
    }
}

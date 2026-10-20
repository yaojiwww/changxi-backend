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

protected class ConsentMemoryStore <: MemoryCacheBase<Consent> & IConsentStore {
    public ConsentMemoryStore(cache: IDistributedCache, let handleGenerator: IHandleGenerator) {
        super(cache)
    }

    public func store(consent: Consent): Unit {
        let key = createKey(consent.sub, consent.clientId)
        this.storeItem(key, consent, if (let Some(lifetime) <- consent.lifetime) {
            Duration.second * lifetime
        } else {
            None
        })
    }

    public func find(sub: String, clientId: String): ?Consent {
        let key = createKey(sub, clientId)
        return this.getItem(key)
    }

    public func remove(sub: String, clientId: String): Unit {
        let key = createKey(sub, clientId)
        this.removeItem(key)
    }

    private func createKey(sub: String, clientId: String) {
        return "${clientId}_${sub}"
    }
}

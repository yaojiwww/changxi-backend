// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_injection

import std.reflect.*

/*
用于描述服务存放位置
*/
struct CallSiteResultCache {
    CallSiteResultCache(let key: ServiceCacheKey, let location: CallSiteResultCacheLocation) {
    }

    init(key: ServiceCacheKey, lifetime: ServiceLifetime) {
        this(key, match (lifetime) {
            case ServiceLifetime.Transient => CallSiteResultCacheLocation.Dispose
            case ServiceLifetime.Scoped => CallSiteResultCacheLocation.Scope
            case ServiceLifetime.Singleton => CallSiteResultCacheLocation.Root
        })
    }

    public static func none(serviceType: TypeInfo) {
        let cacheKey = ServiceCacheKey(0, ServiceIdentifier.fromServiceType(serviceType))
        return CallSiteResultCache(cacheKey, CallSiteResultCacheLocation.Other)
    }
}

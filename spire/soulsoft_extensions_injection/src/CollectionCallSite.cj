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
集合类型图纸模板
 */
class CollectionCallSite <: ServiceCallSite {
    private let _itemType: TypeInfo
    private let _serviceType: TypeInfo
    private let _serviceCallSites: Array<ServiceCallSite>

    public init(cache: CallSiteResultCache, serviceKey: ?String, serviceType: TypeInfo, itemType: TypeInfo,
        serviceCallSites: Array<ServiceCallSite>) {
        super(serviceKey, CallSiteKind.Collection, cache)
        _itemType = itemType
        _serviceType = serviceType
        _serviceCallSites = serviceCallSites
    }

    public prop serviceCallSites: Array<ServiceCallSite> {
        get() {
            _serviceCallSites
        }
    }

    public prop itemType: TypeInfo {
        get() {
            _itemType
        }
    }

    public prop serviceType: TypeInfo {
        get() {
            _serviceType
        }
    }

    public prop implementationType: ?TypeInfo {
        get() {
            None
        }
    }
}

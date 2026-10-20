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
工厂图纸模板
 */
class FactoryCallSite <: ServiceCallSite {
    private let _serviceType: TypeInfo
    private let _factory: (IServiceProvider) -> Any

    public init(cache: CallSiteResultCache, serviceKey: ?String, serviceType: TypeInfo,
        factory: (IServiceProvider) -> Any) {
        super(serviceKey, CallSiteKind.Factory, cache)
        _serviceType = serviceType
        _factory = factory
    }

    public prop factory: (IServiceProvider) -> Any {
        get() {
            _factory
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

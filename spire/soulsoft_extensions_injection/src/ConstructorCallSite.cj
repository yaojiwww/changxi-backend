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
构造器图纸模板
 */
class ConstructorCallSite <: ServiceCallSite {
    private let _serviceType: TypeInfo
    private let _constructorInfo: ConstructorInfo
    private let _parameterCallSites: Array<ServiceCallSite>

    public init(cache: CallSiteResultCache, serviceKey: ?String, serviceType: TypeInfo,
        constructorInfo: ConstructorInfo, parameterCallSites: Array<ServiceCallSite>) {
        super(serviceKey, CallSiteKind.Constructor, cache)
        _serviceType = serviceType
        _constructorInfo = constructorInfo
        _parameterCallSites = parameterCallSites
    }

    public prop constructorInfo: ConstructorInfo {
        get() {
            _constructorInfo
        }
    }

    public prop parameterCallSites: Array<ServiceCallSite> {
        get() {
            _parameterCallSites
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

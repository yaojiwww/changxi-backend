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
常量图纸模板
 */
class ConstantCallSite <: ServiceCallSite {
    private let _defaultValue: Any
    private let _serviceType: TypeInfo
    private let _implementationType: TypeInfo

    public init(serviceKey: ?String, serviceType: TypeInfo, defaultValue: Any) {
        super(serviceKey, CallSiteKind.Constant, CallSiteResultCache.none(serviceType))
        _serviceType = serviceType
        _defaultValue = defaultValue
        _implementationType = TypeInfo.of(defaultValue)
        this.value = defaultValue
    }

    public prop serviceType: TypeInfo {
        get() {
            _serviceType
        }
    }

    public prop implementationType: ?TypeInfo {
        get() {
            _implementationType
        }
    }
}

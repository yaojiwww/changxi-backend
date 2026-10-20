// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_injection

import std.reflect.*

struct ServiceIdentifier <: Equatable<ServiceIdentifier> & Hashable {
    private let _serviceKey: ?String
    private let _serviceType: TypeInfo

    public init(serviceType: TypeInfo) {
        this(None, serviceType)
    }

    public init(serviceKey: ?String, serviceType: TypeInfo) {
        _serviceKey = serviceKey
        _serviceType = serviceType
    }

    public prop serviceKey: ?String {
        get() {
            _serviceKey
        }
    }

    public prop serviceType: TypeInfo {
        get() {
            _serviceType
        }
    }

    public static func fromServiceType(serviceType: TypeInfo) {
        ServiceIdentifier(serviceType)
    }

    public static func fromServiceType(serviceKey: String, serviceType: TypeInfo) {
        ServiceIdentifier(serviceKey, serviceType)
    }

    public static func fromDescriptor(serviceDescriptor: ServiceDescriptor) {
        ServiceIdentifier(serviceDescriptor.serviceKey, serviceDescriptor.serviceType)
    }

    @OverflowWrapping
    public func hashCode() {
        if (let Some(serviceKey) <- serviceKey) {
            return (serviceType.hashCode() * 397) ^ serviceKey.hashCode()
        } else {
            return serviceType.hashCode()
        }
    }

    public operator func ==(that: ServiceIdentifier) {
        if (this.serviceKey.isNone() && that.serviceKey.isNone()) {
            return that.serviceType == this.serviceType
        }
        return that.serviceType == this.serviceType && that.serviceKey == this.serviceKey
    }
}

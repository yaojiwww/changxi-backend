// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_injection

import std.sort.*
import std.reflect.*
import std.collection.*

/*
解析链，用于检测是否发生循环依赖
 */
class CallSiteChain {
    private let _callSiteChain: HashMap<ServiceIdentifier, ChainItemInfo>

    init() {
        _callSiteChain = HashMap<ServiceIdentifier, ChainItemInfo>()
    }

    public func checkCircularDependency(identifier: ServiceIdentifier) {
        if (_callSiteChain.contains(identifier)) {
            throw UnsupportedException(createCircularDependencyExceptionMessage(identifier))
        }
    }

    public func add(identifier: ServiceIdentifier, implementationType!: ?TypeInfo = None): Unit {
        _callSiteChain[identifier] = ChainItemInfo(_callSiteChain.size, implementationType)
    }

    public func remove(identifier: ServiceIdentifier): Unit {
        _callSiteChain.remove(identifier)
    }

    private func createCircularDependencyExceptionMessage(identifier: ServiceIdentifier) {
        let builder = StringBuilder()
        builder.append("A circular dependency was detected for the service of type '${identifier.serviceType}'.")
        builder.append("\r\n")

        appendResolutionPath(builder, identifier)

        return builder.toString()
    }

    private func appendResolutionPath(builder: StringBuilder, currentlyResolving: ServiceIdentifier) {
        let ordered = _callSiteChain.toArray()
        sort(ordered, key: {a => a[1].order})
        for ((key, value) in ordered) {
            if (value.implementationType.isNone() || Option<TypeInfo>.Some(key.serviceType) == value.implementationType) {
                builder.append(key.serviceType)
            } else {
                builder.append(key.serviceType)
                builder.append('(')
                builder.append(value.implementationType ?? String.empty)
                builder.append(")")
            }

            builder.append(" -> ")
        }
        builder.append(currentlyResolving.serviceType)
    }
}

private struct ChainItemInfo {
    ChainItemInfo(let order: Int64, let implementationType: ?TypeInfo) {
    }
}

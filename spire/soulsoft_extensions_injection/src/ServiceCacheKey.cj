// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_injection

/*
缓存已解析的服务实例
*/
struct ServiceCacheKey <: Equatable<ServiceCacheKey> & Hashable {
    public let slot: Int64
    public let identifier: ServiceIdentifier

    init(slot: Int64, identifier: ServiceIdentifier) {
        this.slot = slot
        this.identifier = identifier
    }

    public operator func ==(that: ServiceCacheKey) {
        this.identifier == that.identifier && this.slot == that.slot
    }

    @OverflowWrapping
    public func hashCode() {
        (identifier.hashCode() * 397) ^ slot
    }
}

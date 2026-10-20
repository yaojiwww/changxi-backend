// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_mvc.controllers

import std.reflect.*

protected class DefaultControllerFeatureProvider <: ControllerFeatureProvider {
    private let _superType: TypeInfo

    public init(superType: TypeInfo) {
        _superType = superType
    }

    public func isController(typeInfo: TypeInfo): Bool {
        if (let classTypeInfo: ClassTypeInfo <- typeInfo) {
            if (classTypeInfo.isAbstract()) {
                return false
            }
            if (!classTypeInfo.isSubtypeOf(_superType)) {
                return false
            }
            return true
        } else {
            return false
        }
    }
}

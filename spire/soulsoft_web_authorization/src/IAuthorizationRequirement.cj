// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_authorization

import std.reflect.*

/**
 * @brief 定义授权要求接口。
 */
public interface IAuthorizationRequirement <: Hashable & Equatable<IAuthorizationRequirement> & ToString {
    /**
     * @brief 比较两个授权要求是否引用同一对象。
     * @param other 待比较的授权要求。
     * @return 如果两个授权要求引用同一对象则返回 true，否则返回 false。
     */
    operator func ==(other: IAuthorizationRequirement): Bool {
        refEq((this as Object).getOrThrow(), (other as Object).getOrThrow())
    }

    /**
     * @brief 返回当前授权要求的哈希码。
     * @return 当前授权要求的哈希码。
     */
    func hashCode(): Int64 {
        ClassTypeInfo.of(this).hashCode()
    }

    /**
     * @brief 返回当前授权要求的类型限定名。
     * @return 当前授权要求的类型限定名。
     */
    func toString(): String {
        ClassTypeInfo.of(this).qualifiedName
    }
}

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_authorization

import std.collection.*

/**
 * @brief 表示一次授权失败的结果详情。
 */
public class AuthorizationFailure {
    private var _failCalled = false
    private let _failureReasons = ArrayList<AuthorizationFailureReason>()
    private let _failedRequirements = ArrayList<IAuthorizationRequirement>()

    private static let _explicitFailure: AuthorizationFailure

    static init() {
        _explicitFailure = AuthorizationFailure()
        _explicitFailure._failCalled = true
    }

    /**
     * @brief 获取是否显式调用了失败标记。
     * @return 显式调用失败标记时返回 `true`。
     */
    public prop failCalled: Bool {
        get() {
            _failCalled
        }
    }

    /**
     * @brief 获取授权失败原因集合。
     * @return 当前记录的授权失败原因集合。
     */
    public prop failureReasons: Collection<AuthorizationFailureReason> {
        get() {
            _failureReasons
        }
    }

    /**
     * @brief 获取未满足的授权要求集合。
     * @return 当前未满足的授权要求集合。
     */
    public prop failedRequirements: Collection<IAuthorizationRequirement> {
        get() {
            _failedRequirements
        }
    }

    /**
     * @brief 创建一个显式失败结果。
     * @return 显式失败结果。
     */
    public static func explicitFail(): AuthorizationFailure {
        _explicitFailure
    }

    /**
     * @brief 根据失败原因集合创建失败结果。
     * @param reasons 授权失败原因集合。
     * @return 授权失败结果。
     */
    public static func failed(reasons: Collection<AuthorizationFailureReason>): AuthorizationFailure {
        let result = AuthorizationFailure()
        result._failCalled = true
        result._failureReasons.add(all: reasons)
        return result
    }

    /**
     * @brief 根据未满足的授权要求集合创建失败结果。
     * @param failed 未满足的授权要求集合。
     * @return 授权失败结果。
     */
    public static func failed(failed: Collection<IAuthorizationRequirement>): AuthorizationFailure {
        let result = AuthorizationFailure()
        result._failedRequirements.add(all: failed)
        return result
    }
}

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_authorization

import std.collection.*
import soulsoft_identity_claims.*

/**
 * @brief 表示授权处理过程中的上下文。
 */
public class AuthorizationHandlerContext {
    private var _failCalled = false
    private var _succeedCalled = false
    private let _resource: ?Object
    private let _user: ClaimsPrincipal
    private let _requirements: Collection<IAuthorizationRequirement>
    private var _failedReasons: ?ArrayList<AuthorizationFailureReason> = None
    private let _pendingRequirements: HashSet<IAuthorizationRequirement>

    init(requirements: Collection<IAuthorizationRequirement>, user: ClaimsPrincipal, resource: ?Object) {
        _requirements = requirements
        _user = user
        _resource = resource
        _pendingRequirements = HashSet<IAuthorizationRequirement>(requirements)
    }

    /**
     * @brief 获取当前待处理的授权要求集合。
     * @return 当前授权流程中的全部授权要求集合。
     */
    public prop requirements: Collection<IAuthorizationRequirement> {
        get() {
            _requirements
        }
    }

    /**
     * @brief 获取当前待授权的用户主体。
     * @return 当前参与授权判断的用户主体。
     */
    public prop user: ClaimsPrincipal {
        get() {
            _user
        }
    }

    /**
     * @brief 获取当前授权资源。
     * @return 当前授权流程关联的资源；没有资源时返回 `None`。
     */
    public prop resource: ?Object {
        get() {
            _resource
        }
    }

    /**
     * @brief 获取尚未标记为成功的授权要求集合。
     * @return 当前仍待满足的授权要求集合。
     */
    public prop pendingRequirements: Collection<IAuthorizationRequirement> {
        get() {
            _pendingRequirements
        }
    }

    /**
     * @brief 获取当前已记录的失败原因集合。
     * @return 当前已记录的授权失败原因集合。
     */
    public prop failedReasons: Collection<AuthorizationFailureReason> {
        get() {
            _failedReasons ?? ArrayList<AuthorizationFailureReason>()
        }
    }

    /**
     * @brief 获取当前授权流程是否已失败。
     * @return 当前授权流程已失败时返回 `true`。
     */
    public prop hasFailed: Bool {
        get() {
            _failCalled
        }
    }

    /**
     * @brief 获取当前授权流程是否已成功。
     * @return 当前授权流程满足成功条件时返回 `true`。
     */
    public prop hasSucceeded: Bool {
        get() {
            !_failCalled && _succeedCalled && pendingRequirements.size == 0
        }
    }

    /**
     * @brief 将当前授权流程标记为失败。
     */
    public func fail(): Unit {
        _failCalled = true
    }

    /**
     * @brief 使用指定失败原因将当前授权流程标记为失败。
     * @param reason 授权失败原因。
     */
    public func fail(reason: AuthorizationFailureReason): Unit {
        fail()
        if (_failedReasons.isNone()) {
            _failedReasons = ArrayList<AuthorizationFailureReason>()
        }
        _failedReasons.getOrThrow().add(reason)
    }

    /**
     * @brief 将指定授权要求标记为成功。
     * @param requirement 已满足的授权要求。
     */
    public func succeed(requirement: IAuthorizationRequirement): Unit {
        _succeedCalled = true
        _pendingRequirements.remove(requirement)
    }
}

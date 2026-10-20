// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_authorization

/**
 * @brief 表示授权服务的执行结果。
 */
public class AuthorizationResult {
    private var _succeeded = false
    private var _failure: ?AuthorizationFailure = None

    private static let _successResult: AuthorizationResult
    private static let _failedResult: AuthorizationResult

    static init() {
        _successResult = AuthorizationResult()
        _successResult._succeeded = true
        _failedResult = AuthorizationResult()
        _failedResult._failure = AuthorizationFailure.explicitFail()
    }

    /**
     * @brief 获取授权是否成功。
     * @return 授权成功时返回 `true`。
     */
    public prop succeeded: Bool {
        get() {
            _succeeded
        }
    }

    /**
     * @brief 获取授权失败详情。
     * @return 授权失败详情；成功时返回 `None`。
     */
    public prop failure: ?AuthorizationFailure {
        get() {
            _failure
        }
    }

    /**
     * @brief 创建一个成功的授权结果。
     * @return 成功的授权结果。
     */
    public static func success(): AuthorizationResult {
        _successResult
    }

    /**
     * @brief 根据失败详情创建授权结果。
     * @param failure 授权失败详情。
     * @return 失败的授权结果。
     */
    public static func failed(failure: AuthorizationFailure): AuthorizationResult {
        let result = AuthorizationResult()
        result._failure = failure
        return result
    }

    /**
     * @brief 创建一个显式失败的授权结果。
     * @return 失败的授权结果。
     */
    public static func failed(): AuthorizationResult {
        return _failedResult
    }
}

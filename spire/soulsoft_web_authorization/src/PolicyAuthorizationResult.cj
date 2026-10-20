// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_authorization

/**
 * @brief 表示策略授权器针对 HTTP 请求的处理结果。
 */
public class PolicyAuthorizationResult {
    private var _challenged = false
    private var _forbidden = false
    private var _succeeded = false

    private static let _challengedResult = static_init {
        x => x._challenged = true
    }

    private static let _forbiddenResult = static_init {
        x => x._forbidden = true
    }

    private static let _succeededResult = static_init {
        x => x._succeeded = true
    }

    private var _authorizationFailure: ?AuthorizationFailure = None

    /**
     * @brief 获取当前结果是否表示需要发起质询。
     * @return 当前结果需要发起质询时返回 `true`。
     */
    public prop challenged: Bool {
        get() {
            _challenged
        }
    }

    /**
     * @brief 获取当前结果是否表示禁止访问。
     * @return 当前结果表示禁止访问时返回 `true`。
     */
    public prop forbidden: Bool {
        get() {
            _forbidden
        }
    }

    /**
     * @brief 获取当前结果是否表示授权成功。
     * @return 当前结果表示授权成功时返回 `true`。
     */
    public prop succeeded : Bool {
        get() {
            _succeeded
        }
    }

    /**
     * @brief 创建一个禁止访问结果。
     * @return 禁止访问结果。
     */
    public static func forbid(): PolicyAuthorizationResult {
        _forbiddenResult
    }

    /**
     * @brief 创建一个需要质询的结果。
     * @return 需要质询的结果。
     */
    public static func challenge(): PolicyAuthorizationResult {
        _challengedResult
    }

    /**
     * @brief 创建一个授权成功结果。
     * @return 授权成功结果。
     */
    public static func success(): PolicyAuthorizationResult {
        _succeededResult
    }

    /**
     * @brief 根据失败详情创建禁止访问结果。
     * @param authorizationFailure 授权失败详情。
     * @return 禁止访问结果。
     */
    public static func forbid(authorizationFailure: ?AuthorizationFailure): PolicyAuthorizationResult {
        if (let Some(authorizationFailure) <- authorizationFailure) {
            let result = PolicyAuthorizationResult()
            result._forbidden = true
            result._authorizationFailure = authorizationFailure
            return result
        } else {
            return forbid()
        }
    }

    private static func static_init(configure: (PolicyAuthorizationResult) -> Unit) {
        let entry = PolicyAuthorizationResult()
        configure(entry)
        return entry
    }
}

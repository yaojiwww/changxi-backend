// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_routing.matching

import soulsoft_web_http.*

/*
单方法 HTTP 策略跳转表
适用于节点只有一个 HTTP 方法的情况（如纯 GET、纯 POST 路由）。
相比 HttpMethodDictionaryPolicyJumpTable，省去 HttpMethodDestinationsLookup 的
方法枚举查找，仅做一次 equalsIgnoreAsciiCase 比较。
参考：ASP.NET Core HttpMethodSingleEntryPolicyJumpTable
 */
protected class HttpMethodSingleEntryPolicyJumpTable <: PolicyJumpTable {
    private let _exitDestination: Int64
    private let _method: String
    private let _destination: Int64
    private let _supportsCorsPreflight: Bool
    private let _corsPreflightExitDestination: Int64
    private let _corsPreflightDestination: Int64

    public init(
        exitDestination: Int64,
        method: String,
        destination: Int64,
        supportsCorsPreflight: Bool,
        corsPreflightExitDestination: Int64,
        corsPreflightDestination: Int64
    ) {
        _exitDestination = exitDestination
        _method = method
        _destination = destination
        _supportsCorsPreflight = supportsCorsPreflight
        _corsPreflightExitDestination = corsPreflightExitDestination
        _corsPreflightDestination = corsPreflightDestination
    }

    public func getDestination(context: HttpContext): Int64 {
        let httpMethod = context.request.method

        if (_supportsCorsPreflight) {
            if (let Some(accessControlMethod) <- HttpMethodMatcherPolicy.isCorsPreflightRequest(context, httpMethod)) {
                return if (accessControlMethod.equalsIgnoreAsciiCase(_method)) {
                    _corsPreflightDestination
                } else {
                    _corsPreflightExitDestination
                }
            }
        }

        return if (httpMethod.equalsIgnoreAsciiCase(_method)) {
            _destination
        } else {
            _exitDestination
        }
    }

    protected func debuggerToString(): String {
        if (_supportsCorsPreflight) {
            return "{ ${_method}: ${_destination}, cors-${_method}: ${_corsPreflightDestination}, cors-$0: ${_corsPreflightExitDestination}, $0: ${_exitDestination} }"
        }
        return "{ ${_method}: ${_destination}, $0: ${_exitDestination} }"
    }
}

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
支持 CORS 预检的 HTTP 方法跳转表。
  - 若请求是 CORS 预检，用 Access-Control-Request-Method 值查 CORS 表；
  - 否则按正常 HTTP 方法查普通表。
 */
protected class HttpMethodDictionaryPolicyJumpTable <: PolicyJumpTable {
    private let _normalLookup: HttpMethodDestinationsLookup
    private let _corsPreflightLookup: ?HttpMethodDestinationsLookup

    public init(normalLookup: HttpMethodDestinationsLookup, corsPreflightLookup: ?HttpMethodDestinationsLookup) {
        _normalLookup = normalLookup
        _corsPreflightLookup = corsPreflightLookup
    }

    public func getDestination(context: HttpContext): Int64 {
        let httpMethod = context.request.method

        if (let Some(corsLookup) <- _corsPreflightLookup) {
            if (let Some(accessControlMethod) <- HttpMethodMatcherPolicy.isCorsPreflightRequest(context, httpMethod)) {
                return corsLookup.getDestination(accessControlMethod)
            }
        }

        return _normalLookup.getDestination(httpMethod)
    }

    protected func debuggerToString(): String {
        if (_corsPreflightLookup.isSome()) {
            return "{ normal+cors }"
        }
        return "{ normal }"
    }
}

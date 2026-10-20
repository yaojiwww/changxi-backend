// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_authorization

/**
 * @brief 表示基于声明名称和值的授权要求。
 */
public class ClaimsAuthorizationRequirement <: AuthorizationHandler<ClaimsAuthorizationRequirement> & IAuthorizationRequirement {
    private let _claimName: String
    private let _emptyAllowedValues: Bool
    private let _allowedValues: Array<String>

    /**
     * @brief 创建一个声明授权要求。
     * @param claimName 声明名称。
     * @param allowedValues 允许的声明值集合。
     */
    public init(claimName: String, allowedValues: Array<String>) {
        _claimName = claimName
        _allowedValues = allowedValues
        _emptyAllowedValues = allowedValues.size == 0
    }

    /**
     * @brief 获取声明名称。
     * @return 当前要求匹配的声明名称。
     */
    public prop claimName: String {
        get() {
            _claimName
        }
    }

    /**
     * @brief 获取允许的声明值集合。
     * @return 当前要求允许的声明值集合。
     */
    public prop allowedValues: Array<String> {
        get() {
            _allowedValues
        }
    }

    protected func handleRequirement(context: AuthorizationHandlerContext, requirement: ClaimsAuthorizationRequirement): Unit {
        var found = false
        if (requirement._emptyAllowedValues) {
            for (claim in context.user.claims) {
                if (requirement.claimName.equalsIgnoreAsciiCase(claim.`type`)) {
                    found = true
                    break
                }
            }
        } else {
            for (claim in context.user.claims) {
                if (requirement.claimName.equalsIgnoreAsciiCase(claim.`type`) && requirement
                    .allowedValues
                    .contains(claim.value)) {
                    found = true
                    break
                }
            }
        }
        if (found) {
            context.succeed(requirement)
        }
    }

    /**
     * @brief 返回当前授权要求的描述字符串。
     * @return 当前授权要求的描述字符串。
     */
    public func toString(): String {
        let value = if (_emptyAllowedValues) {
            String.empty
        } else {
            " and Claim.Value is one of the following values: (${String.join(_allowedValues, delimiter: "|")})"
        }
        "ClaimsAuthorizationRequirement:Claim.Type=${_claimName}${value}"
    }
}

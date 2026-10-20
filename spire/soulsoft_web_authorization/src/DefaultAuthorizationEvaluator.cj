// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_authorization

/**
 * @brief 提供默认的授权结果求值器。
 */
public class DefaultAuthorizationEvaluator <: IAuthorizationEvaluator {
    /**
     * @brief 根据授权上下文计算授权结果。
     * @param context 授权处理上下文。
     * @return 授权结果。
     */
    public func evaluate(context: AuthorizationHandlerContext): AuthorizationResult {
        if (context.hasSucceeded) {
            return AuthorizationResult.success()
        } else {
            let failure = if (context.hasFailed) {
                AuthorizationFailure.failed(context.failedReasons)
            } else {
                AuthorizationFailure.failed(context.pendingRequirements)
            }
            return AuthorizationResult.failed(failure)
        }
    }
}

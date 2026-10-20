// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_authorization

/**
 * @brief 定义授权结果求值器接口。
 */
public interface IAuthorizationEvaluator {
    /**
     * @brief 根据授权处理上下文计算授权结果。
     * @param context 授权处理上下文。
     * @return 授权结果。
     */
    func evaluate(context: AuthorizationHandlerContext): AuthorizationResult
}

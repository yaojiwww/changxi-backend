// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_authorization

/**
 * @brief 定义授权处理器接口。
 */
public interface IAuthorizationHandler {
    /**
     * @brief 处理当前授权上下文。
     * @param context 当前授权处理上下文。
     */
    func handle(context: AuthorizationHandlerContext): Unit
}

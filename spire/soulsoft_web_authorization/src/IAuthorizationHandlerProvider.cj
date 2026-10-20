// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_authorization

/**
 * @brief 定义授权处理器提供器接口。
 */
public interface IAuthorizationHandlerProvider {
    /**
     * @brief 获取适用于当前上下文的授权处理器集合。
     * @param context 当前授权处理上下文。
     * @return 授权处理器集合。
     */
    func getHandlers(context: AuthorizationHandlerContext): Collection<IAuthorizationHandler>
}

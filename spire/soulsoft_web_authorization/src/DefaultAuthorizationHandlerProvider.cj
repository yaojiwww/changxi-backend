// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_authorization

/**
 * @brief 提供默认的授权处理器提供器。
 */
public class DefaultAuthorizationHandlerProvider <: IAuthorizationHandlerProvider {
    private let _handlers: Collection<IAuthorizationHandler>

    init(handlers: Collection<IAuthorizationHandler>) {
        _handlers = handlers
    }

    /**
     * @brief 获取可用于当前上下文的授权处理器集合。
     * @param _ 当前授权处理上下文。
     * @return 授权处理器集合。
     */
    public func getHandlers(_: AuthorizationHandlerContext): Collection<IAuthorizationHandler> {
        _handlers
    }
}

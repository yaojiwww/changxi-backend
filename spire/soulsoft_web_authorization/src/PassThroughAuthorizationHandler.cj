// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_authorization

import std.collection.*
import soulsoft_extensions_options.*

/**
 * @brief 提供透传式授权处理器，用于执行同时实现了处理器接口的授权要求。
 */
public class PassThroughAuthorizationHandler <: IAuthorizationHandler {
    private let _options: AuthorizationOptions

    /**
     * @brief 创建一个透传式授权处理器。
     * @param options 授权选项。
     */
    public init(options: IOptions<AuthorizationOptions>) {
        _options = options.value
    }

    /**
     * @brief 执行上下文中同时实现了处理器接口的授权要求。
     * @param context 当前授权处理上下文。
     */
    public func handle(context: AuthorizationHandlerContext): Unit {
        let handlers = context.requirements |> filterMap {f => f as IAuthorizationHandler}
        for (pattern in handlers) {
            pattern.handle(context)
            if (!_options.invokeHandlersAfterFailure && context.hasFailed) {
                break
            }
        }
    }
}

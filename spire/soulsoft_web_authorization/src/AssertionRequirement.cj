// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_authorization

/**
 * @brief 表示基于断言委托的授权要求。
 */
public class AssertionRequirement <: IAuthorizationHandler & IAuthorizationRequirement {
    private let _handler: (AuthorizationHandlerContext) -> Bool

    /**
     * @brief 创建一个断言授权要求。
     * @param handler 用于判断授权是否成功的断言委托。
     */
    public init(handler: (AuthorizationHandlerContext) -> Bool) {
        _handler = handler
    }

    /**
     * @brief 获取授权断言委托。
     * @return 用于执行断言判断的授权委托。
     */
    public prop handler: (AuthorizationHandlerContext) -> Bool {
        get() {
            _handler
        }
    }

    /**
     * @brief 根据断言结果处理授权要求。
     * @param context 当前授权处理上下文。
     */
    public func handle(context: AuthorizationHandlerContext): Unit {
        if (_handler(context)) {
            context.succeed(this)
        }
    }

    /**
     * @brief 返回当前授权要求的描述字符串。
     * @return 当前授权要求的描述字符串。
     */
    public func toString(): String {
        "AssertionRequirement"
    }
}

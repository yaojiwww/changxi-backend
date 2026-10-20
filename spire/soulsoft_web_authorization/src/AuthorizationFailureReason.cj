// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_authorization

/**
 * @brief 表示授权处理器生成的一条失败原因。
 */
public class AuthorizationFailureReason {
    private let _handler: IAuthorizationHandler
    private let _message: String

    /**
     * @brief 创建一个授权失败原因。
     * @param handler 生成该失败原因的处理器。
     * @param message 失败说明消息。
     */
    public init(handler: IAuthorizationHandler, message: String) {
        _handler = handler
        _message = message
    }

    /**
     * @brief 获取生成失败原因的处理器。
     * @return 生成该失败原因的授权处理器。
     */
    public prop handler: IAuthorizationHandler {
        get() {
            _handler
        }
    }

    /**
     * @brief 获取失败说明消息。
     * @return 当前失败原因的说明消息。
     */
    public prop message: String {
        get() {
            _message
        }
    }
}

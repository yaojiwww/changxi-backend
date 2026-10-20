// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_web_authentication

/**
 * @brief 表示身份验证失败异常。
 */
public class AuthenticationFailureException <: Exception {
    /**
     * @brief 创建一个身份验证失败异常。
     * @param message 异常消息。
     */
    public init(message: String) {
        super(message)
    }

    /**
     * @brief 返回异常类型名称。
     * @return 异常类型名称。
     */
    public func getClassName(): String {
        "AuthenticationFailureException"
    }
}

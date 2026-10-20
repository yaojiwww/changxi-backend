// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_tokens

/**
 * @brief 表示安全令牌验证失败时抛出的异常。
 */
public class SecurityTokenValidationException <: Exception {
    /**
     * @brief 使用错误消息创建安全令牌验证异常。
     * @param message 异常消息。
     */
    public init(message: String) {
        super(message)
    }
}

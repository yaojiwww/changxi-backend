// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_tokens

/**
 * @brief 定义安全令牌验证器接口。
 */
public interface ISecurityTokenValidator {
    /**
     * @brief 检查当前验证器是否可以读取指定令牌。
     * @param token 待检查的令牌字符串。
     * @return 当前实现可处理该令牌时返回 `true`。
     */
    func canReadToken(token: String): Bool {
        return false
    }
    /**
     * @brief 验证令牌并返回验证结果。
     * @param token 待验证的令牌字符串。
     * @param parameters 令牌验证参数。
     * @return 令牌验证结果。
     */
    func validateToken(token: String, parameters: TokenValidationParameters): TokenValidationResult
}

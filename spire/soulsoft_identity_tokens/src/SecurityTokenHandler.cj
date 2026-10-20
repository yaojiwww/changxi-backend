// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_identity_tokens

/**
 * @brief 定义安全令牌处理器抽象基类。
 */
public abstract class SecurityTokenHandler <: ISecurityTokenValidator {
    /**
     * @brief 根据描述信息创建安全令牌。
     * @param tokenDescriptor 令牌描述信息。
     * @return 创建出的安全令牌。
     */
    public func createToken(tokenDescriptor: SecurityTokenDescriptor): SecurityToken
    /**
     * @brief 将安全令牌写出为字符串。
     * @param securityToken 要序列化的安全令牌。
     * @return 序列化后的令牌字符串。
     */
    public func writeToken(securityToken: SecurityToken): String
    /**
     * @brief 验证令牌并返回验证结果。
     * @param token 待验证的令牌字符串。
     * @param validationParameters 令牌验证参数。
     * @return 令牌验证结果。
     */
    public func validateToken(token: String, validationParameters: TokenValidationParameters): TokenValidationResult
}

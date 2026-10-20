// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_tokens

import std.time.*

/**
 * @brief 表示自定义安全令牌读取委托。
 * @param token 待读取的令牌字符串。
 * @param validationParameters 令牌验证参数。
 * @return 解析得到的安全令牌实例。
 */
public type TokenReader = (token: String, validationParameters: TokenValidationParameters) -> SecurityToken

/**
 * @brief 表示令牌类型验证委托。
 * @param type 令牌头中的类型标识。
 * @param securityToken 当前安全令牌。
 * @param validationParameters 令牌验证参数。
 * @return 类型校验通过时返回 `true`。
 */
public type TypeValidator = (`type`: String, securityToken: SecurityToken, validationParameters: TokenValidationParameters) -> Bool

/**
 * @brief 表示自定义签名验证委托。
 * @param token 待验证的令牌字符串。
 * @param validationParameters 令牌验证参数。
 * @return 验签成功后返回解析出的安全令牌实例。
 */
public type SignatureValidator = (token: String, validationParameters: TokenValidationParameters) -> SecurityToken

/**
 * @brief 表示签名算法验证委托。
 * @param algorithm 待验证的算法标识。
 * @param securityKey 用于验证的安全密钥。
 * @param securityToken 当前安全令牌。
 * @param validationParameters 令牌验证参数。
 * @return 算法校验通过时返回 `true`。
 */
public type AlgorithmValidator = (algorithm: String, securityKey: SecurityKey, securityToken: SecurityToken,
    validationParameters: TokenValidationParameters) -> Bool

/**
 * @brief 表示受众验证委托。
 * @param audiences 待验证的受众集合。
 * @param securityToken 当前安全令牌。
 * @param validationParameters 令牌验证参数。
 * @return 受众校验通过时返回 `true`。
 */
public type AudienceValidator = (audiences: Collection<String>, securityToken: SecurityToken, validationParameters: TokenValidationParameters) -> Bool

/**
 * @brief 表示签名密钥解析委托。
 * @param securityToken 当前安全令牌。
 * @param validationParameters 令牌验证参数。
 * @return 可用于验证当前令牌的签名密钥集合。
 */
public type IssuerSigningKeyResolver = (securityToken: SecurityToken, validationParameters: TokenValidationParameters) -> Collection<SecurityKey>

/**
 * @brief 表示签名密钥验证委托。
 * @param securityKey 待验证的签名密钥。
 * @param securityToken 当前安全令牌。
 * @param validationParameters 令牌验证参数。
 * @return 签名密钥校验通过时返回 `true`。
 */
public type IssuerSigningKeyValidator = (securityKey: SecurityKey, securityToken: SecurityToken, validationParameters: TokenValidationParameters) -> Bool

/**
 * @brief 表示颁发者验证委托。
 * @param issuer 待验证的颁发者标识。
 * @param securityToken 当前安全令牌。
 * @param validationParameters 令牌验证参数。
 * @return 颁发者校验通过时返回 `true`。
 */
public type IssuerValidator = (issuer: String, securityToken: SecurityToken, validationParameters: TokenValidationParameters) -> Bool

/**
 * @brief 表示生命周期验证委托。
 * @param expires 令牌过期时间。
 * @param notBefore 令牌生效时间。
 * @param securityToken 当前安全令牌。
 * @param validationParameters 令牌验证参数。
 * @return 生命周期校验通过时返回 `true`。
 */
public type LifetimeValidator = (expires: ?DateTime, notBefore: ?DateTime, securityToken: SecurityToken,
    validationParameters: TokenValidationParameters) -> Bool

/**
 * @brief 表示令牌重放验证委托。
 * @param expirationTime 令牌过期时间。
 * @param securityToken 待验证的令牌字符串。
 * @param validationParameters 令牌验证参数。
 * @return 未检测到重放时返回 `true`。
 */
public type TokenReplayValidator = (expirationTime: ?DateTime, securityToken: String, validationParameters: TokenValidationParameters) -> Bool

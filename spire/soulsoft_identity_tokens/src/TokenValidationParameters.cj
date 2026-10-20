// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_tokens

/**
 * @brief 表示令牌验证时使用的参数集合。
 */
public class TokenValidationParameters {
    /**
     * @brief 获取或设置是否验证令牌颁发者。
     */
    public var validateIssuer = true

    /**
     * @brief 获取或设置是否要求令牌必须包含受众。
     */
    public var requireAudience = true

    /**
     * @brief 获取或设置是否验证令牌生命周期。
     */
    public var validateLifetime = true

    /**
     * @brief 获取或设置是否验证令牌受众。
     */
    public var validateAudience = true

    /**
     * @brief 获取或设置是否验证令牌重放。
     */
    public var validateTokenReplay = false

    /**
     * @brief 获取或设置是否要求令牌必须包含过期时间。
     */
    public var requireExpirationTime = true

    /**
     * @brief 获取或设置是否验证颁发者签名密钥。
     */
    public var validateIssuerSigningKey = true

    /**
     * @brief 获取或设置允许的令牌类型集合。
     */
    public var validTypes = Array<String>()

    /**
     * @brief 获取或设置验证时间声明时允许的时钟偏差。
     */
    public var clockSkew = Duration.Zero

    /**
     * @brief 获取或设置允许的颁发者集合。
     */
    public var validIssuers = Array<String>()

    /**
     * @brief 获取或设置允许的受众集合。
     */
    public var validAudiences = Array<String>()

    /**
     * @brief 获取或设置自定义令牌读取委托。
     */
    public var tokenReader: ?TokenReader = None

    /**
     * @brief 获取或设置自定义类型验证委托。
     */
    public var typeValidator: ?TypeValidator = None

    /**
     * @brief 获取或设置自定义颁发者验证委托。
     */
    public var issuerValidator: ?IssuerValidator = None

    /**
     * @brief 获取或设置令牌重放缓存实现。
     */
    public var tokenReplayCache: ?ITokenReplayCache = None

    /**
     * @brief 获取或设置自定义生命周期验证委托。
     */
    public var lifetimeValidator: ?LifetimeValidator = None

    /**
     * @brief 获取或设置自定义受众验证委托。
     */
    public var audienceValidator: ?AudienceValidator = None

    /**
     * @brief 获取或设置自定义签名验证委托。
     */
    public var signatureValidator: ?SignatureValidator = None

    /**
     * @brief 获取或设置自定义重放验证委托。
     */
    public var tokenReplayValidator: ?TokenReplayValidator = None

    /**
     * @brief 获取或设置颁发者签名密钥解析委托。
     */
    public var issuerSigningKeyResolver: ?IssuerSigningKeyResolver = None

    /**
     * @brief 获取或设置颁发者签名密钥验证委托。
     */
    public var issuerSigningKeyValidator: ?IssuerSigningKeyValidator = None

    /**
     * @brief 获取或设置可用于验证的签名密钥集合。
     */
    public var issuerSigningKeys = Array<SecurityKey>()

    /**
     * @brief 获取或设置创建身份对象时使用的认证类型。
     */
    public var authenticationType: String = "AuthenticationTypes.Federation"

    /**
     * @brief 创建默认的令牌验证参数。
     */
    public init() {
    }

    /**
     * @brief 通过复制现有参数创建新的令牌验证参数。
     * @param that 要复制的参数对象。
     */
    public init(that: TokenValidationParameters) {
        validateIssuer = that.validateIssuer
        requireAudience = that.requireAudience
        validateLifetime = that.validateLifetime
        validateAudience = that.validateAudience
        validateTokenReplay = that.validateTokenReplay
        requireExpirationTime = that.requireExpirationTime
        validateIssuerSigningKey = that.validateIssuerSigningKey
        validTypes = that.validTypes.clone()
        clockSkew = that.clockSkew
        validIssuers = that.validIssuers.clone()
        validAudiences = that.validAudiences.clone()
        tokenReader = that.tokenReader
        typeValidator = that.typeValidator
        issuerValidator = that.issuerValidator
        tokenReplayCache = that.tokenReplayCache
        lifetimeValidator = that.lifetimeValidator
        audienceValidator = that.audienceValidator
        signatureValidator = that.signatureValidator
        tokenReplayValidator = that.tokenReplayValidator
        issuerSigningKeyResolver = that.issuerSigningKeyResolver
        issuerSigningKeyValidator = that.issuerSigningKeyValidator
        issuerSigningKeys = that.issuerSigningKeys.clone()
        authenticationType = that.authenticationType.clone()
    }

    /**
     * @brief 复制当前令牌验证参数。
     * @return 当前参数对象的副本。
     */
    public func clone(): TokenValidationParameters {
        return TokenValidationParameters(this)
    }
}

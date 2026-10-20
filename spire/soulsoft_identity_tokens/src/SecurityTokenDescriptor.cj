// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_tokens

import std.time.*
import std.collection.*
import soulsoft_identity_claims.*

/**
 * @brief 表示创建安全令牌时使用的描述信息。
 */
public class SecurityTokenDescriptor {
    /**
     * @brief 获取或设置令牌过期时间。
     */
    public var expires: ?DateTime = None
    /**
     * @brief 获取或设置令牌生效时间。
     */
    public var notBefore: ?DateTime = None
    /**
     * @brief 获取或设置令牌签发时间。
     */
    public var issuedAt: ?DateTime = None
    /**
     * @brief 获取或设置令牌颁发者。
     */
    public var issuer: ?String = None
    /**
     * @brief 获取或设置默认受众。
     */
    public var audience: ?String = None
    /**
     * @brief 获取或设置令牌声明集合。
     */
    public var claims: Collection<Claim> = []
    /**
     * @brief 获取或设置附加受众列表。
     */
    public var audiences = ArrayList<String>()
    /**
     * @brief 获取用于签发令牌的签名凭据。
     */
    public let signingCredentials: SigningCredentials

    /**
     * @brief 使用签名凭据创建令牌描述对象。
     * @param signingCredentials 用于签发令牌的签名凭据。
     */
    public init(signingCredentials: SigningCredentials) {
        this.signingCredentials = signingCredentials
    }
}

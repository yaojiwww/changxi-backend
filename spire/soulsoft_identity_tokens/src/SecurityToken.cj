// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_identity_tokens

/**
 * @brief 表示安全令牌的抽象基类。
 */
public abstract class SecurityToken {
    /**
     * @brief 获取令牌标识。
     * @return 当前令牌的唯一标识；未设置时返回 `None`。
     */
    public prop id: ?String
    /**
     * @brief 获取令牌颁发者。
     * @return 当前令牌的颁发者；未设置时返回 `None`。
     */
    public prop issuer: ?String
    /**
     * @brief 获取令牌关联的签名密钥。
     * @return 用于签名或验证该令牌的密钥；未设置时返回 `None`。
     */
    public prop signingKey: ?SecurityKey
}

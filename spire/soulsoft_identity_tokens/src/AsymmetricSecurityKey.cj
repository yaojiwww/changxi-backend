// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_tokens

/**
 * @brief 表示非对称安全密钥的抽象基类。
 * @description 该类型作为 RSA、ECDSA 和 X.509 密钥的公共父类型，用于标识依赖公私钥对的密钥实现。
 */
public abstract class AsymmetricSecurityKey <: SecurityKey {
    
}

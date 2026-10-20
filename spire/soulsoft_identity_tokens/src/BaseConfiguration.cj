// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_identity_tokens

/**
 * @brief 表示令牌服务基础配置的抽象基类。
 */
public abstract class BaseConfiguration {
    /**
     * @brief 获取颁发者标识。
     * @return 返回颁发者标识。
     */
    public prop issuer: String
    /**
     * @brief 获取令牌签发端点地址。
     * @return 返回令牌签发端点地址。
     */
    public prop tokenEndpoint: String
    /**
     * @brief 获取令牌激活状态查询端点地址。
     * @return 返回令牌激活状态查询端点地址。
     */
    public prop activeTokenEndpoint: String
    /**
     * @brief 获取签名密钥集合。
     * @return 返回签名密钥集合。
     */
    public prop signingKeys: Collection<SecurityKey>
    /**
     * @brief 获取令牌解密密钥集合。
     * @return 返回令牌解密密钥集合。
     */
    public prop tokenDecryptionKeys: Collection<SecurityKey>
}

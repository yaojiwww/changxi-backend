// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_protocols_oidc

/**
 * @brief 定义常用 OpenID Connect 授权类型常量。
 */
public class OpenIdConnectGrantTypes {
    /**
     * @brief 表示授权码授权类型。
     */
    public static const AuthorizationCode = "authorization_code"

    /**
     * @brief 表示刷新令牌授权类型。
     */
    public static const RefreshToken = "refresh_token"

    /**
     * @brief 表示密码授权类型。
     */
    public static const Password = "password"

    /**
     * @brief 表示客户端凭证授权类型。
     */
    public static const ClientCredentials = "client_credentials"
}

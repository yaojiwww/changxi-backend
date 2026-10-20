/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.models

/**
 * @brief 定义 OAuth 2.0 与 OpenID Connect 授权类型常量。
 */
public class GrantTypes {
    // ========== Core OAuth 2.0 Grant Types ==========

    /**
     * @brief 表示授权码授权类型。
     */
    public static const AuthorizationCode = "authorization_code"

    /**
     * @brief 表示客户端凭证授权类型。
     */
    public static const ClientCredentials = "client_credentials"

    /**
     * @brief 表示刷新令牌授权类型。
     */
    public static const RefreshToken = "refresh_token"

    // ========== OpenID Connect Specific ==========

    /**
     * @brief 表示密码授权类型。
     */
    public static const Password = "password"
}

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.models

/**
 * @brief 定义令牌类型常量。
 */
public class TokenTypes {
    /**
     * @brief 表示身份令牌类型。
     */
    public static const IdentityToken = "id_token"
    /**
     * @brief 表示访问令牌类型。
     */
    public static const AccessToken = "access_token"
    /**
     * @brief 表示刷新令牌类型。
     */
    public static const RefreshToken = "refresh_token"
}

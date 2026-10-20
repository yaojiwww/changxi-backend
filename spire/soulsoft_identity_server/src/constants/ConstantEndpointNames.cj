/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.constants

/**
 * @brief 定义 Identity Server 端点名称常量。
 */
public class ConstantEndpointNames {
    /**
     * @brief 表示授权端点名称。
     */
    public static const Authorize = "Authorize"
    /**
     * @brief 表示令牌端点名称。
     */
    public static const Token = "Token"
    /**
     * @brief 表示发现端点名称。
     */
    public static const Discovery = "Discovery"
    /**
     * @brief 表示 JWK 集端点名称。
     */
    public static const DiscoveryJwks = "Jwks"
    /**
     * @brief 表示用户信息端点名称。
     */
    public static const UserInfo = "Userinfo"
    /**
     * @brief 表示结束会话端点名称。
     */
    public static const EndSession = "EndSession"
    /**
     * @brief 表示撤销端点名称。
     */
    public static const Revocation = "Revocation"
    /**
     * @brief 表示自省端点名称。
     */
    public static const Introspection = "Introspection"
}

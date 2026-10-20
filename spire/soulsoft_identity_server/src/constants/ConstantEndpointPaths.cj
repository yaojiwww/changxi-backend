/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.constants

/**
 * @brief 定义 Identity Server 端点路径常量。
 */
public class ConstantEndpointPaths {
    /**
     * @brief 表示授权端点路径。
     */
    public static const AuthorizePath = "connect/authorize"
    /**
     * @brief 表示发现端点路径。
     */
    public static const DiscoveryPath = ".well-known/openid-configuration"
    /**
     * @brief 表示 JWK 集端点路径。
     */
    public static const DiscoveryJwksPath = DiscoveryPath + "/jwks"
    /**
     * @brief 表示令牌端点路径。
     */
    public static const TokenPath = "connect/token"
    /**
     * @brief 表示用户信息端点路径。
     */
    public static const UserInfoPath = "connect/userinfo"
    /**
     * @brief 表示撤销端点路径。
     */
    public static const RevocationPath = "connect/revocation"
    /**
     * @brief 表示自省端点路径。
     */
    public static const IntrospectionPath = "connect/introspect"
    /**
     * @brief 表示结束会话端点路径。
     */
    public static const EndSessionPath = "connect/endsession"
    /**
     * @brief 表示结束会话回调端点路径。
     */
    public static const EndSessionCallbackPath = "connect/endsession-callback"
}

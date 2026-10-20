/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.options

import soulsoft_identity_server.constants.*

/**
 * @brief 表示身份服务器端点开关配置。
 */
public class EndpointsOptions {
    /**
     * @brief 指定端点统一前缀。
     */
    public var prefix = ""
    /**
     * @brief 指示是否启用 JWT Request URI 支持。
     */
    public var enableJwtRequestUri = true
    /**
     * @brief 指示是否启用令牌端点。
     */
    public var enableTokenEndpoint  = true
    /**
     * @brief 指示是否启用用户信息端点。
     */
    public var enableUserInfoEndpoint  = true
    /**
     * @brief 指示是否启用授权端点。
     */
    public var enableAuthorizeEndpoint = true
    /**
     * @brief 指示是否启用发现端点。
     */
    public var enableDiscoveryEndpoint  = true
    /**
     * @brief 指示是否启用结束会话端点。
     */
    public var enableEndSessionEndpoint  = true
    /**
     * @brief 指示是否启用会话检查端点。
     */
    public var enableCheckSessionEndpoint  = true
    /**
     * @brief 指示是否启用令牌撤销端点。
     */
    public var enableTokenRevocationEndpoint  = true
    /**
     * @brief 指示是否启用自省端点。
     */
    public var enableIntrospectionEndpoint  = true
    /**
     * @brief 指示是否启用设备授权端点。
     */
    public var enableDeviceAuthorizationEndpoint  = true
    /**
     * @brief 指示是否启用后端认证端点。
     */
    public var enableBackchannelAuthenticationEndpoint  = true
    /**
     * @brief 指示是否启用推送授权端点。
     */
    public var enablePushedAuthorizationEndpoint  = true

    /**
     * @brief 检查指定端点名称是否已启用。
     * @param name 端点名称。
     * @return 如果端点已启用则返回 `true`。
     */
    public func isEnable(name: String): Bool {
        if (name == ConstantEndpointNames.Token) {
            return enableTokenEndpoint
        }
        if (name == ConstantEndpointNames.UserInfo) {
            return enableUserInfoEndpoint
        }
        if (name == ConstantEndpointNames.Authorize) {
            return enableAuthorizeEndpoint
        }
        if (name == ConstantEndpointNames.Discovery) {
            return enableDiscoveryEndpoint
        }
        if (name == ConstantEndpointNames.DiscoveryJwks) {
            return enableJwtRequestUri
        }
        if (name == ConstantEndpointNames.Introspection) {
            return enableIntrospectionEndpoint
        }
        return true
    }
}

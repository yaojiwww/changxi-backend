/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.options

/**
 * @brief 表示身份服务器核心配置选项。
 */
public class IdentityServerOptions {
    /**
     * @brief 指定对外发布的签发者名称。
     */
    public var issuer = ""
    /**
     * @brief 指定签发者 URI。
     */
    public var issuerUri = ""
    /**
     * @brief 指定默认 CORS 策略名称。
     */
    public let corsPolicyName = "soulsoft_identity_server"
    /**
     * @brief 保存端点相关配置。
     */
    public let endpoints = EndpointsOptions()
    /**
     * @brief 保存发现文档相关配置。
     */
    public let dsicovery = DiscoveryOptions()
    /**
     * @brief 保存交互页面相关配置。
     */
    public let interaction = InteractionOptions()
    /**
     * @brief 保存认证相关配置。
     */
    public let authentication = AuthenticationOptions()
}

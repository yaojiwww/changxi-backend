// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_authentication_jwtbearer

import std.collection.*
import soulsoft_net_http.*
import soulsoft_identity_tokens.*
import soulsoft_identity_tokens_jwt.*
import soulsoft_web_authentication.*
import soulsoft_identity_protocols.*
import soulsoft_identity_protocols_oidc.*

/**
 * @brief 表示 JWT Bearer 身份验证方案的配置选项。
 */
public class JwtBearerOptions <: AuthenticationSchemeOptions {
    /**
     * @brief 指示是否在身份验证属性中保存访问令牌。
     */
    public var saveToken = true
    /**
     * @brief 获取或修改 OpenID Connect 颁发机构地址。
     */
    public var authority = String.empty
    /**
     * @brief 获取或修改元数据终结点地址。
     */
    public var metadataAddress = String.empty
    /**
     * @brief 指示获取元数据时是否必须使用 HTTPS。
     */
    public var requireHttpsMetadata = true
    /**
     * @brief 指示质询响应中是否包含详细错误信息。
     */
    public var includeErrorDetails = true
    /**
     * @brief 获取 JWT Bearer 事件处理器集合。
     */
    public let events = JwtBearerEvents()
    /**
     * @brief 获取或修改用于后端通信的 HTTP 客户端。
     */
    public var backchannel: ?HttpClient = None
    /**
     * @brief 获取或修改后端 HTTP 请求的超时时间。
     */
    public var backchannelTimeout = Duration.minute * 1
    /**
     * @brief 获取或修改后端通信使用的 HTTP 消息处理器。
     */
    public var backchannelHttpHandler: ?HttpMessageHandler = None
    /**
     * @brief 获取或修改质询响应使用的认证方案名称。
     */
    public var challenge = JwtBearerDefaults.Scheme
    /**
     * @brief 获取或修改固定使用的 OpenID Connect 配置。
     */
    public var configuration: ?OpenIdConnectConfiguration = None
    /**
     * @brief 获取或修改配置刷新的最小间隔。
     */
    public var refreshInterval: Duration
    /**
     * @brief 获取或修改自动刷新配置的间隔。
     */
    public var automaticRefreshInterval: Duration
    /**
     * @brief 指示在签名密钥缺失时是否触发配置刷新。
     */
    public var refreshOnIssuerKeyNotFound = true
    /**
     * @brief 获取或修改 OpenID Connect 配置管理器。
     */
    public var configurationManager: ?IConfigurationManager<OpenIdConnectConfiguration> = None
    /**
     * @brief 获取或修改令牌验证参数。
     */
    public var tokenValidationParameters = TokenValidationParameters()
    /**
     * @brief 获取或修改可用的安全令牌验证器列表。
     */
    public var securityTokenValidators: List<ISecurityTokenValidator>

    /**
     * @brief 创建一组默认的 JWT Bearer 身份验证选项。
     */
    public init() {
        securityTokenValidators = ArrayList<ISecurityTokenValidator>([JwtSecurityTokenHandler()])
        refreshInterval = ConfigurationManager<OpenIdConnectConfiguration>.DefaultRefreshInterval
        automaticRefreshInterval = ConfigurationManager<OpenIdConnectConfiguration>.DefaultAutomaticRefreshInterval
    }
}

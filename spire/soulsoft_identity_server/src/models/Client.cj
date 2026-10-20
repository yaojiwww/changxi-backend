/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.models

import soulsoft_identity_claims.*

/**
 * @brief 表示身份服务中的客户端配置。
 */
public class Client {
    /**
     * @brief 保存客户端标识。
     */
    public var clientId = String.empty
    /**
     * @brief 保存客户端显示名称。
     */
    public var clientName = String.empty // P0: 客户端显示名称
    /**
     * @brief 保存客户端描述信息。
     */
    public var description = String.empty // 客户端描述
    /**
     * @brief 保存客户端站点或帮助页地址。
     */
    public var clientUri = String.empty // 客户端 URI（官网、帮助页面等）
    /**
     * @brief 保存客户端协议类型。
     */
    public var protocolType = "oidc" // P0: 协议类型（默认 oidc）
    /**
     * @brief 标识当前客户端是否启用。
     */
    public var enabled: Bool = true
    /**
     * @brief 标识当前客户端是否要求使用密钥。
     */
    public var requireSecret = true
    /**
     * @brief 标识当前客户端是否需要用户同意。
     */
    public var requireConsent = false
    /**
     * @brief 保存用户同意记录的有效时长。
     */
    public var consentLifetime: ?Int64 = None
    /**
     * @brief 标识当前客户端是否允许离线访问。
     */
    public var allowOfflineAccess = false
    /**
     * @brief 保存客户端可携带的声明列表。
     */
    public var allowedClaims: Array<Claim> = []
    /**
     * @brief 保存客户端允许申请的作用域列表。
     */
    public var allowedScopes: Array<String> = []
    /**
     * @brief 保存客户端可用的密钥列表。
     */
    public var clientSecrets: Array<Secret> = [] // 客户端密钥列表
    /**
     * @brief 保存客户端允许使用的授权类型列表。
     */
    public var allowedGrantTypes: Array<String> = []
    /**
     * @brief 保存客户端允许的回调地址列表。
     */
    public var allowedRedirectUris: Array<String> = []
    /**
     * @brief 保存注销后允许跳转的地址列表。
     */
    public var postLogoutRedirectUris: Array<String> = [] // P0: 注销后重定向 URI 列表
    /**
     * @brief 保存访问令牌生命周期。
     */
    public var accessTokenLifetime = 3600 // 访问令牌生命周期（默认 1 小时）
    /**
     * @brief 保存身份令牌生命周期。
     */
    public var identityTokenLifetime = 300 // P0: ID Token 生命周期（默认 5 分钟）
    /**
     * @brief 保存授权码生命周期。
     */
    public var authorizationCodeLifetime = 300 // 授权码生命周期（默认 5 分钟）
    /**
     * @brief 保存兼容字段中的刷新令牌生命周期。
     */
    public var refreshTokenLifetime = 3600 * 24 * 15 // 已废弃：使用 slidingRefreshTokenLifetime
    /**
     * @brief 保存绝对刷新令牌生命周期。
     */
    public var absoluteRefreshTokenLifetime = 2592000 // P0: 绝对刷新令牌生命周期（默认 30 天）
    /**
     * @brief 保存滑动刷新令牌生命周期。
     */
    public var slidingRefreshTokenLifetime = 1296000 // P0: 滑动刷新令牌生命周期（默认 15 天）
    /**
     * @brief 保存刷新令牌使用策略。
     */
    public var refreshTokenUsage = RefreshTokenUsage.ReUse
    /**
     * @brief 保存刷新令牌过期策略。
     */
    public var refreshTokenExpiration = RefreshTokenExpiration.Absolute
    /**
     * @brief 标识当前客户端是否强制要求 PKCE。
     */
    public var requirePkce = false // 是否强制要求 PKCE
    /**
     * @brief 标识当前客户端是否允许明文 PKCE 挑战方法。
     */
    public var allowPlainTextPkce = true // 是否允许 plain 方法（默认允许，但建议只允许 S256）
    /**
     * @brief 创建空的客户端配置。
     */
    public init() {
    }

    /**
     * @brief 使用客户端标识和密钥创建客户端配置。
     * @param clientId 客户端标识。
     * @param clientSecrets 客户端密钥列表。
     */
    public init(clientId: String, clientSecrets: Array<Secret>) {
        this.clientId = clientId
        this.clientSecrets = clientSecrets
    }
}

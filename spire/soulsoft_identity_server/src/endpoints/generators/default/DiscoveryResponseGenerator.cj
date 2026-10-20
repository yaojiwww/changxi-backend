/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.endpoints.generators.default

import std.collection.*
import stdx.encoding.json.*
import soulsoft_identity_tokens.*
import soulsoft_extensions_injection.*
import soulsoft_identity_protocols_oidc.*
import soulsoft_identity_server.models.*
import soulsoft_identity_server.hosting.*
import soulsoft_identity_server.options.*
import soulsoft_identity_server.services.*
import soulsoft_identity_server.constants.*
import soulsoft_identity_server.validation.*
import soulsoft_identity_server.endpoints.generators.*

/**
 * Discovery 端点响应生成器的默认实现
 * 负责生成 OpenID Connect Discovery 文档和 JWKS 文档的 JSON 响应
 *
 * 实现标准：
 * - RFC 8414: OAuth 2.0 Authorization Server Metadata
 * - RFC 7517: JSON Web Key (JWK)
 * - OpenID Connect Discovery 1.0
 */

protected class DiscoveryResponseGenerator <: IDiscoveryResponseGenerator {
    public DiscoveryResponseGenerator(
        let serverUrls: IServerUrls,
        let keyManager: IKeyManager,
        let endpoints: EndpointFactory,
        let options: IdentityServerOptions,
        let resourceManager: ResourceManager,
        let callSite: IServiceProviderIsService,
        let extensionGrantManager: ExtensionGrantManager,
        let secretParserFactory: ClientSecretParserManager
    ) {
    }

    /**
     * 创建 OpenID Connect Discovery 文档响应
     * 包含授权服务器的元数据信息，如端点 URL、支持的授权类型等
     *
     * @return Discovery 文档的 JSON 对象
     */

    public func createDiscoveryResponse() {
        return createDiscoveryDocument()
    }

    /**
     * 创建 JWKS (JSON Web Key Set) 文档响应
     * 包含用于验证签名的公钥集合
     *
     * @return JWKS 文档的 JSON 对象
     */

    public func createJwksResponse() {
        return createJwksDocument()
    }

    /**
     * 创建 OpenID Connect Discovery 配置文档
     * 包含授权服务器的所有元数据
     *
     * @return OpenID Connect 配置对象
     */

    private func createDiscoveryDocument(): OpenIdConnectConfiguration {
        let configuration = OpenIdConnectConfiguration()
        configuration.issuer = options.issuer

        // 配置端点 URLs
        if (options.dsicovery.showEndpoints) {
            configureEndpoints(configuration)
        }

        configuration.httpLogoutSupported = true
        configuration.logoutSessionSupported = true

        // 配置支持的授权类型
        configureGrantTypes(configuration)

        // 配置支持的 scopes
        configuration.scopesSupported.add(all: resourceManager.getDiscoveryDocumentScopes())

        // 配置支持的 claims
        configuration.claimsSupported.add(all: resourceManager.getDiscoveryDocumentClaimTypes())

        // 配置 token 端点认证方法
        configuration.tokenEndpointAuthMethodsSupported.add(all: secretParserFactory.getauthenticationMethods())

        return configuration
    }

    /**
     * 配置 Discovery 文档中的端点 URLs
     *
     * @param configuration OpenID Connect 配置对象
     */

    private func configureEndpoints(configuration: OpenIdConnectConfiguration) {
        for (pattern in endpoints) {
            let endpointUri = "${serverUrls.url}${pattern.path}"
            if (pattern.name == ConstantEndpointNames.Token && options.endpoints.enableTokenEndpoint) {
                configuration.tokenEndpoint = endpointUri
            } else if (pattern.name == ConstantEndpointNames.Authorize && options.endpoints.enableAuthorizeEndpoint) {
                configuration.authorizationEndpoint = endpointUri
            } else if (pattern.name == ConstantEndpointNames.DiscoveryJwks && options.endpoints.enableJwtRequestUri) {
                configuration.jwksUri = endpointUri
            } else if (pattern.name == ConstantEndpointNames.UserInfo && options.endpoints.enableUserInfoEndpoint) {
                configuration.userInfoEndpoint = endpointUri
            } else if (pattern.name == ConstantEndpointNames.EndSession && options.endpoints.enableEndSessionEndpoint) {
                configuration.endSessionEndpoint = endpointUri
            }
        }
    }

    /**
     * 配置支持的授权类型（Grant Types）
     *
     * @param configuration OpenID Connect 配置对象
     */

    private func configureGrantTypes(configuration: OpenIdConnectConfiguration) {
        // 检查是否支持密码授权模式
        if (callSite.isService<IResourceOwnerPasswordValidator>()) {
            configuration.grantTypesSupported.add(GrantTypes.Password)
        }

        // 添加标准授权类型
        configuration.grantTypesSupported.add(GrantTypes.RefreshToken)
        configuration.grantTypesSupported.add(GrantTypes.ClientCredentials)
        configuration.grantTypesSupported.add(GrantTypes.AuthorizationCode)

        // 添加扩展授权类型
        configuration.grantTypesSupported.add(all: extensionGrantManager.getGrantTypes())
    }

    /**
     * 创建 JSON Web Key Set 文档
     * 包含用于验证令牌签名的公钥集合
     *
     * @return JSON Web Key Set 对象
     */

    private func createJwksDocument(): JsonWebKeySet {
        let jwks = JsonWebKeySet()

        if (options.dsicovery.showKeySet) {
            let signingCredentials = keyManager.getActiveSigningKeys()
            for (credential in signingCredentials) {
                let jsonWebKey = JsonWebKeyConverter.convertFromSigningCredentials(credential)
                // 屏蔽私钥字段，JWKS 端点仅暴露公钥参数
                jsonWebKey.d = None // RSA/EC 私钥
                jsonWebKey.p = None // RSA 质数 p
                jsonWebKey.q = None // RSA 质数 q
                jsonWebKey.dp = None // RSA CRT 指数 dP
                jsonWebKey.dq = None // RSA CRT 指数 dQ
                jsonWebKey.qi = None // RSA CRT 系数 qInv
                jwks.keys.add(jsonWebKey)
            }
        }

        return jwks
    }
}

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server

import std.reflect.*
import soulsoft_identity_tokens.*
import soulsoft_extensions_caching.*
import soulsoft_extensions_options.*
import soulsoft_extensions_injection.*
import soulsoft_identity_server.stores.*
import soulsoft_identity_server.models.*
import soulsoft_identity_server.options.*
import soulsoft_identity_server.hosting.*
import soulsoft_identity_server.services.*
import soulsoft_identity_server.constants.*
import soulsoft_identity_server.endpoints.*
import soulsoft_identity_server.validation.*
import soulsoft_identity_server.stores.default.*
import soulsoft_identity_server.services.default.*
import soulsoft_identity_server.validation.default.*
import soulsoft_identity_server.endpoints.generators.*
import soulsoft_identity_server.endpoints.generators.default.*

/**
 * @brief 提供 Identity Server 服务注册构建能力。
 */
public class IdentityServerBuilder {
    /**
     * @brief 保存当前构建器关联的服务集合。
     */
    public let services: ServiceCollection

    /**
     * @brief 创建一个 Identity Server 构建器。
     * @param services 当前构建器关联的服务集合。
     */
    protected init(services: ServiceCollection) {
        this.services = services
    }
}

// endpoints
extend IdentityServerBuilder {
    /**
     * @brief 注册一个 Identity Server 端点处理器。
     * @param name 端点名称。
     * @param path 端点路径。
     * @return 返回当前构建器。
     */
    public func addEndpoint<TEndpointHandler>(name: String, path: String): IdentityServerBuilder where TEndpointHandler <: IEndpointHandler {
        services.addSingleton<EndpointDescriptor> {
            sp =>
                let options = sp.getOrThrow<IdentityServerOptions>()
                let path = "${options.endpoints.prefix}/${path}"
                return EndpointDescriptor(name, path, TypeInfo.of<TEndpointHandler>())
        }
        return this
    }

    /**
     * @brief 注册默认 Identity Server 端点。
     * @return 返回当前构建器。
     */
    public func addDefaultEndpoints(): IdentityServerBuilder {
        addEndpoint<TokenEndpoint>(ConstantEndpointNames.Token, ConstantEndpointPaths.TokenPath)
        addEndpoint<UserInfoEndpoint>(ConstantEndpointNames.UserInfo, ConstantEndpointPaths.UserInfoPath)
        addEndpoint<AuthorizeEndpoint>(ConstantEndpointNames.Authorize, ConstantEndpointPaths.AuthorizePath)
        addEndpoint<DiscoveryEndpoint>(ConstantEndpointNames.Discovery, ConstantEndpointPaths.DiscoveryPath)
        addEndpoint<DiscoveryJwksEndpoint>(ConstantEndpointNames.DiscoveryJwks, ConstantEndpointPaths.DiscoveryJwksPath)
        addEndpoint<EndSessionEndpoint>(ConstantEndpointNames.EndSession, ConstantEndpointPaths.EndSessionPath)
        return this
    }
}

// RequiredServices
extend IdentityServerBuilder {
    /**
     * @brief 注册 Identity Server 必需服务。
     * @return 返回当前构建器。
     */
    public func addRequiredServices(): IdentityServerBuilder {
        services.addOptions<ExtensionGrantManagerOptions>()
        services.addScoped<ResourceManager, ResourceManager>()
        services.tryAddScoped<IUserSession, UserSession>()
        services.tryAddSingleton<IEndpointRouter, EndpointRouter>()
        services.tryAddSingleton<EndpointFactory, EndpointFactory>()
        services.tryAddSingleton<ExtensionGrantManager, ExtensionGrantManager>()
        services.tryAddScoped<ClientSecretParserManager, ClientSecretParserManager>()
        services.addTransient<IClientSecretParser, PostBodyClientSecretParser>()
        services.addTransient<IClientSecretParser, BasicClientSecretParser>()
        return this
    }
}

// PluggableServices
extend IdentityServerBuilder {
    /**
     * @brief 注册可替换的 Identity Server 默认服务。
     * @return 返回当前构建器。
     */
    public func addPluggableServices(): IdentityServerBuilder {
        services.tryAddTransient<IServerUrls, ServerUrls>()
        services.tryAddTransient<IKeyManager, KeyManager>()
        services.tryAddTransient<IClaimService, ClaimsService>()
        services.tryAddTransient<IHandleGenerator, HandleGenerator>()
        services.tryAddTransient<ITokenParser, TokenParser>()
        services.tryAddTransient<IConsentService, ConsentService>()
        services.tryAddTransient<ITokenService, TokenService>()
        services.tryAddTransient<IRefreshTokenService, RefreshTokenService>()
        services.tryAddTransient<IClientSecretValidator, ClientSecretValidator>()
        services.tryAddTransient<IAuthorizationCodeService, AuthorizationCodeService>()
        return this
    }
}

extend IdentityServerBuilder {
    /**
     * @brief 注册响应生成器服务。
     * @return 返回当前构建器。
     */
    public func addResponseGenerators(): IdentityServerBuilder {
        services.tryAddTransient<IAuthorizeResponseGenerator, AuthorizeResponseGenerator>()
        services.tryAddTransient<ITokenResponseGenerator, TokenResponseGenerator>()
        services.tryAddTransient<IDiscoveryResponseGenerator, DiscoveryResponseGenerator>()
        services.tryAddTransient<IUserInfoResponseGenerator, UserInfoResponseGenerator>()
        return this
    }
}

// Validators
extend IdentityServerBuilder {
    /**
     * @brief 注册默认验证器服务。
     * @return 返回当前构建器。
     */
    public func addValidators(): IdentityServerBuilder {
        services.tryAddTransient<ITokenValidator, TokenValidator>()
        services.tryAddTransient<IResourceValidator, ResourceValidator>()
        services.tryAddTransient<IClientSecretValidator, ClientSecretValidator>()
        services.tryAddTransient<ITokenRequestValidator, TokenRequestValidator>()
        services.tryAddTransient<IUserInfoRequestValidator, UserInfoRequestValidator>()
        services.tryAddTransient<IAuthorizeRequestValidator, AuthorizeRequestValidator>()
        services.tryAddTransient<IEndSessionRequestValidator, EndSessionRequestValidator>()

        return this
    }
}

// ISigningCredentialStore
extend IdentityServerBuilder {
    /**
     * @brief 使用内存中的签名凭据集合注册签名凭据存储。
     * @param credential 签名凭据集合。
     * @return 返回当前构建器。
     */
    public func addInMemorySigningCredentials(credential: Collection<SigningCredentials>): IdentityServerBuilder {
        addSigningCredentialStore(SigningCredentialMemoryStore(credential))
        return this
    }

    /**
     * @brief 注册签名凭据存储实现类型。
     * @return 返回当前构建器。
     */
    public func addSigningCredentialStore<TSigningCredentialStore>(): IdentityServerBuilder where TSigningCredentialStore <: Object {
        services.tryAddScoped<ISigningCredentialStore, TSigningCredentialStore>()
        return this
    }

    private func addSigningCredentialStore(store: ISigningCredentialStore) {
        services.addSingleton<ISigningCredentialStore>(store)
        return this
    }
}

// IClientStore
extend IdentityServerBuilder {
    /**
     * @brief 使用内存中的客户端集合注册客户端存储。
     * @param clients 客户端集合。
     * @return 返回当前构建器。
     */
    public func addInMemoryClients(clients: Collection<Client>): IdentityServerBuilder {
        addClientStore(ClientMemoryStore(clients))
        return this
    }

    /**
     * @brief 注册客户端存储实现类型。
     * @return 返回当前构建器。
     */
    public func addClientStore<TClientStore>(): IdentityServerBuilder where TClientStore <: Object {
        services.tryAddScoped<IClientStore, TClientStore>()
        return this
    }

    private func addClientStore(store: IClientStore) {
        services.addSingleton<IClientStore>(store)
        return this
    }
}

// IApiScopeStore
extend IdentityServerBuilder {
    /**
     * @brief 使用内存中的 API 作用域集合注册作用域存储。
     * @param apiScopes API 作用域集合。
     * @return 返回当前构建器。
     */
    public func addInMemoryApiScopes(apiScopes: Collection<ApiScope>): IdentityServerBuilder {
        addApiScopeStore(ApiScopeMemoryStore(apiScopes))
        return this
    }

    /**
     * @brief 注册 API 作用域存储实现类型。
     * @return 返回当前构建器。
     */
    public func addApiScopeStore<TApiScopeStore>(): IdentityServerBuilder where TApiScopeStore <: Object {
        services.tryAddScoped<IApiScopeStore, TApiScopeStore>()
        return this
    }

    private func addApiScopeStore(store: IApiScopeStore) {
        services.addSingleton<IApiScopeStore>(store)
        return this
    }
}

// IApiResourceStore
extend IdentityServerBuilder {
    /**
     * @brief 使用内存中的 API 资源集合注册资源存储。
     * @param apiResources API 资源集合。
     * @return 返回当前构建器。
     */
    public func addInMemoryApiResources(apiResources: Collection<ApiResource>): IdentityServerBuilder {
        addApiResourceStore(ApiResourceMemoryStore(apiResources))
        return this
    }

    /**
     * @brief 注册 API 资源存储实现类型。
     * @return 返回当前构建器。
     */
    public func addApiResourceStore<TApiResourceStore>(): IdentityServerBuilder where TApiResourceStore <: Object {
        services.tryAddScoped<IApiResourceStore, TApiResourceStore>()
        return this
    }

    private func addApiResourceStore(store: IApiResourceStore) {
        services.addSingleton<IApiResourceStore>(store)
        return this
    }
}

// IIdentityResourceStore
extend IdentityServerBuilder {
    /**
     * @brief 使用内存中的身份资源集合注册身份资源存储。
     * @param identityResources 身份资源集合。
     * @return 返回当前构建器。
     */
    public func addInMemoryIdentityResources(identityResources: Collection<IdentityResource>): IdentityServerBuilder {
        addIdentityResourceStore(IdentityResourceMemoryStore(identityResources))
        return this
    }

    /**
     * @brief 注册身份资源存储实现类型。
     * @return 返回当前构建器。
     */
    public func addIdentityResourceStore<TIdentityResourceStore>(): IdentityServerBuilder where TIdentityResourceStore <: Object {
        services.tryAddScoped<IIdentityResourceStore, TIdentityResourceStore>()
        return this
    }

    private func addIdentityResourceStore(store: IIdentityResourceStore) {
        services.addSingleton<IIdentityResourceStore>(store)
        return this
    }
}

// IConsentStore
extend IdentityServerBuilder {
    /**
     * @brief 注册基于内存的同意存储。
     * @return 返回当前构建器。
     */
    public func addInMemoryConsentStore(): IdentityServerBuilder {
        services.addDistributedMemoryCache()
        services.tryAddScoped<IConsentStore, ConsentMemoryStore>()
        return this
    }

    /**
     * @brief 注册同意存储实现类型。
     * @return 返回当前构建器。
     */
    public func addConsentStore<TConsentStore>(): IdentityServerBuilder where TConsentStore <: Object {
        services.tryAddScoped<IConsentStore, TConsentStore>()
        return this
    }
}

// IRefreshTokenStore
extend IdentityServerBuilder {
    /**
     * @brief 注册基于内存的刷新令牌存储。
     * @return 返回当前构建器。
     */
    public func addInMemoryRefreshTokenStore(): IdentityServerBuilder {
        services.addDistributedMemoryCache()
        services.tryAddScoped<IRefreshTokenStore, RefreshTokenMemoryStore>()
        return this
    }

    /**
     * @brief 注册刷新令牌存储实现类型。
     * @return 返回当前构建器。
     */
    public func addRefreshTokenStore<TRefreshTokenStore>(): IdentityServerBuilder where TRefreshTokenStore <: Object {
        services.tryAddScoped<IRefreshTokenStore, TRefreshTokenStore>()
        return this
    }
}

// IAuthorizationCodeStore
extend IdentityServerBuilder {
    /**
     * @brief 注册基于内存的授权码存储。
     * @return 返回当前构建器。
     */
    public func addInMemoryAuthorizationCodeStore(): IdentityServerBuilder {
        services.addDistributedMemoryCache()
        services.tryAddScoped<IAuthorizationCodeStore, AuthorizationCodeMemoryStore>()
        return this
    }

    /**
     * @brief 注册授权码存储实现类型。
     * @return 返回当前构建器。
     */
    public func addAuthorizationCodeStore<TAuthorizationCodeStore>(): IdentityServerBuilder where TAuthorizationCodeStore <: Object {
        services.tryAddScoped<IAuthorizationCodeStore, TAuthorizationCodeStore>()
        return this
    }
}

// IExtensionGrantValidator
extend IdentityServerBuilder {
    /**
     * @brief 注册扩展授权验证器。
     * @param grantType 扩展授权类型名称。
     * @return 返回当前构建器。
     */
    public func addExtensionGrantValidator<TExtensionGrantValidator>(grantType: String): IdentityServerBuilder where TExtensionGrantValidator <: Object {
        this.services.addTransient<IExtensionGrantValidator, TExtensionGrantValidator>()
        this.services.configure<ExtensionGrantManagerOptions> {
            configureOptions => configureOptions.grantTypes.add(grantType, TypeInfo.of<TExtensionGrantValidator>())
        }
        return this
    }
}

// IResourceOwnerPasswordValidator
extend IdentityServerBuilder {
    /**
     * @brief 注册密码授权验证器。
     * @return 返回当前构建器。
     */
    public func addPasswordGrantValidator<TValidator>(): IdentityServerBuilder where TValidator <: Object {
        this.services.tryAddTransient<IResourceOwnerPasswordValidator, TValidator>()
        return this
    }
}

// IProfileService
extend IdentityServerBuilder {
    /**
     * @brief 注册用户资料服务实现。
     * @return 返回当前构建器。
     */
    public func addProfileService<TProfileService>(): IdentityServerBuilder where TProfileService <: Object {
        this.services.addTransient<IProfileService, TProfileService>()
        return this
    }
}

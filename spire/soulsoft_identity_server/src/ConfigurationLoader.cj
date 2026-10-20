/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server

import std.collection.*
import soulsoft_identity_claims.*
import soulsoft_identity_server.models.*
import soulsoft_extensions_configuration.*

/**
 * IdentityServer 统一配置加载器
 * 从 IConfiguration 解析并返回所有类型的资源（Client、IdentityResource、ApiScope、ApiResource）
 */

class ConfigurationLoader {

    // ==================== 公共加载方法 ====================

    /**
     * 从配置中加载客户端列表
     * @param configuration 配置实例（可以是完整配置或 section）
     * @return 客户端集合
     */
    public static func loadClients(configuration: IConfiguration): Collection<Client> {
        let clients = ArrayList<Client>()

        for (clientSection in configuration.getChildren()) {
            let client = Client()

            // 基础信息
            if (let Some(value) <- clientSection.getValue<String>("clientId")) {
                client.clientId = value
            }
            if (let Some(value) <- clientSection.getValue<String>("clientName")) {
                client.clientName = value
            }
            if (let Some(value) <- clientSection.getValue<String>("description")) {
                client.description = value
            }
            if (let Some(value) <- clientSection.getValue<String>("clientUri")) {
                client.clientUri = value
            }
            if (let Some(value) <- clientSection.getValue<String>("protocolType")) {
                client.protocolType = value
            }
            if (let Some(value) <- clientSection.getValue<Bool>("enabled")) {
                client.enabled = value
            }
            if (let Some(value) <- clientSection.getValue<Bool>("requireSecret")) {
                client.requireSecret = value
            }
            if (let Some(value) <- clientSection.getValue<Bool>("requireConsent")) {
                client.requireConsent = value
            }
            if (let Some(value) <- clientSection.getValue<Int64>("consentLifetime")) {
                client.consentLifetime = value
            }
            if (let Some(value) <- clientSection.getValue<Bool>("allowOfflineAccess")) {
                client.allowOfflineAccess = value
            }

            // 数组字段
            client.allowedScopes = loadStringArray(clientSection, "allowedScopes")
            client.allowedRedirectUris = loadStringArray(clientSection, "allowedRedirectUris")
            client.postLogoutRedirectUris = loadStringArray(clientSection, "postLogoutRedirectUris")
            client.allowedGrantTypes = loadStringArray(clientSection, "allowedGrantTypes")

            // Token 生命周期配置
            if (let Some(value) <- clientSection.getValue<Int64>("identityTokenLifetime")) {
                client.identityTokenLifetime = value
            }
            if (let Some(value) <- clientSection.getValue<Int64>("accessTokenLifetime")) {
                client.accessTokenLifetime = value
            }
            if (let Some(value) <- clientSection.getValue<Int64>("authorizationCodeLifetime")) {
                client.authorizationCodeLifetime = value
            }
            if (let Some(value) <- clientSection.getValue<Int64>("absoluteRefreshTokenLifetime")) {
                client.absoluteRefreshTokenLifetime = value
            }
            if (let Some(value) <- clientSection.getValue<Int64>("slidingRefreshTokenLifetime")) {
                client.slidingRefreshTokenLifetime = value
            }

            // 刷新令牌配置（枚举）
            if (let Some(value) <- clientSection.getValue<String>("refreshTokenExpiration")) {
                client.refreshTokenExpiration = match (value) {
                    case "Absolute" => RefreshTokenExpiration.Absolute
                    case "Sliding" => RefreshTokenExpiration.Sliding
                    case _ => RefreshTokenExpiration.Absolute
                }
            }
            if (let Some(value) <- clientSection.getValue<String>("refreshTokenUsage")) {
                client.refreshTokenUsage = match (value) {
                    case "Once" => RefreshTokenUsage.Once
                    case "ReUse" => RefreshTokenUsage.ReUse
                    case _ => RefreshTokenUsage.ReUse
                }
            }

            // PKCE 配置
            if (let Some(value) <- clientSection.getValue<Bool>("requirePkce")) {
                client.requirePkce = value
            }
            if (let Some(value) <- clientSection.getValue<Bool>("allowPlainTextPkce")) {
                client.allowPlainTextPkce = value
            }

            // 复杂对象
            client.allowedClaims = loadClaims(clientSection.getSection("allowedClaims"))
            client.clientSecrets = loadSecrets(clientSection.getSection("clientSecrets"))

            clients.add(client)
        }

        return clients
    }

    /**
     * 从配置中加载 IdentityResource 列表
     * @param configuration 配置实例（可以是完整配置或 section）
     * @return IdentityResource 集合
     */
    public static func loadIdentityResources(configuration: IConfiguration): Collection<IdentityResource> {
        let resources = ArrayList<IdentityResource>()

        for (resourceSection in configuration.getChildren()) {
            let name = resourceSection.getValue<String>("name") ?? String.empty
            if (name.isEmpty()) {
                continue
            }

            let resource = IdentityResource(name, None)

            // 加载 ResourceBase 公共字段
            loadResourceBaseFields(resource, resourceSection)

            // claimTypes 数组
            resource.claimTypes = loadStringArray(resourceSection, "claimTypes")

            // required 字段
            if (let Some(value) <- resourceSection.getValue<Bool>("required")) {
                resource.required = value
            }

            resources.add(resource)
        }

        return resources
    }

    /**
     * 从配置中加载 ApiScope 列表
     * @param configuration 配置实例（可以是完整配置或 section）
     * @return ApiScope 集合
     */
    public static func loadApiScopes(configuration: IConfiguration): Collection<ApiScope> {
        let scopes = ArrayList<ApiScope>()

        for (scopeSection in configuration.getChildren()) {
            let name = scopeSection.getValue<String>("name") ?? String.empty
            if (name.isEmpty()) {
                continue
            }

            let scope = ApiScope(name, None)

            // 加载 ResourceBase 公共字段
            loadResourceBaseFields(scope, scopeSection)

            // claimTypes 数组
            scope.claimTypes = loadStringArray(scopeSection, "claimTypes")

            // required 字段
            if (let Some(value) <- scopeSection.getValue<Bool>("required")) {
                scope.required = value
            }

            scopes.add(scope)
        }

        return scopes
    }

    /**
     * 从配置中加载 ApiResource 列表
     * @param configuration 配置实例（可以是完整配置或 section）
     * @return ApiResource 集合
     */
    public static func loadApiResources(configuration: IConfiguration): Collection<ApiResource> {
        let resources = ArrayList<ApiResource>()

        for (resourceSection in configuration.getChildren()) {
            let name = resourceSection.getValue<String>("name") ?? String.empty
            if (name.isEmpty()) {
                continue
            }

            // allowedScopes 数组
            let allowedScopes = loadStringArray(resourceSection, "allowedScopes")

            let resource = ApiResource(name, allowedScopes)

            // 加载 ResourceBase 公共字段
            loadResourceBaseFields(resource, resourceSection)

            // claimTypes 数组
            resource.claimTypes = loadStringArray(resourceSection, "claimTypes")

            // apiSecrets
            resource.apiSecrets = loadSecrets(resourceSection.getSection("secrets"))

            resources.add(resource)
        }

        return resources
    }

    // ==================== 私有辅助方法 ====================

    /**
     * 加载 ResourceBase 的公共字段
     * @param resource ResourceBase 实例
     * @param section 配置节
     */
    private static func loadResourceBaseFields(resource: ResourceBase, section: IConfiguration) {
        if (let Some(value) <- section.getValue<Bool>("enabled")) {
            resource.enabled = value
        }
        if (let Some(value) <- section.getValue<String>("description")) {
            resource.description = Some(value)
        }
        if (let Some(value) <- section.getValue<String>("displayName")) {
            resource.displayName = Some(value)
        }
        if (let Some(value) <- section.getValue<Bool>("discoveryDocument")) {
            resource.discoveryDocument = value
        }

        // properties Map
        resource.properties = loadProperties(section.getSection("properties"))
    }

    /**
     * 从配置中加载字符串数组
     * @param section 父配置节
     * @param key 数组配置键名
     * @return 字符串数组
     */
    private static func loadStringArray(section: IConfiguration, key: String): Array<String> {
        return section.getSection(key).getChildren() |> filterMap {f => f.value} |> collectArray
    }

    /**
     * 从配置中加载 Claims
     * @param claimsSection Claims 配置节
     * @return Claims 数组
     */
    private static func loadClaims(claimsSection: IConfiguration): Array<Claim> {
        let claims = ArrayList<Claim>()
        for (claimSection in claimsSection.getChildren()) {
            let claimType = claimSection.getValue<String>("type") ?? String.empty
            let claimValue = claimSection.getValue<String>("value") ?? String.empty
            if (!claimType.isEmpty() && !claimValue.isEmpty()) {
                claims.add(Claim(claimType, claimValue))
            }
        }
        return claims.toArray()
    }

    /**
     * 从配置中加载 Secrets（支持哈希处理）
     * @param secretsSection Secrets 配置节
     * @return Secrets 数组
     */
    private static func loadSecrets(secretsSection: IConfiguration): Array<Secret> {
        let secrets = ArrayList<Secret>()
        for (secretSection in secretsSection.getChildren()) {
            let secretValue = secretSection.getValue<String>("value") ?? String.empty
            let secretType = secretSection.getValue<String>("type") ?? "plain"

            if (!secretValue.isEmpty()) {
                // 根据 type 处理密钥
                let processedValue = match (secretType) {
                    case "sha256" => secretValue.sha256()
                    case "sha384" => secretValue.sha384()
                    case "sha512" => secretValue.sha512()
                    case _ => secretValue // plain
                }
                secrets.add(Secret(processedValue))
            }
        }
        return secrets.toArray()
    }

    /**
     * 从配置中加载 Properties 映射
     * @param propertiesSection Properties 配置节
     * @return Properties Map
     */
    private static func loadProperties(propertiesSection: IConfiguration) {
        let properties = HashMap<String, String>()
        for (propertySection in propertiesSection.getChildren()) {
            let key = propertySection.getValue<String>("key") ?? String.empty
            let value = propertySection.getValue<String>("value") ?? String.empty
            if (!key.isEmpty()) {
                properties.add(key, value)
            }
        }
        return properties
    }
}

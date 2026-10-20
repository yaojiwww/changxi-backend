/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server

import soulsoft_extensions_configuration.*

/**
 * @brief 提供从配置中加载 Identity Server 资源的构建器扩展。
 */
extend IdentityServerBuilder {
    /**
     * @brief 从配置中添加内存客户端存储。
     * @param configuration 配置实例，通常为构建器配置对象或其子节。
     * @return 返回当前 IdentityServerBuilder 实例。
     */
    public func addInMemoryClients(configuration: IConfiguration): IdentityServerBuilder {
        let clients = ConfigurationLoader.loadClients(configuration)
        this.addInMemoryClients(clients)
        return this
    }

    /**
     * @brief 从配置中添加内存身份资源存储。
     * @param configuration 配置实例，通常为构建器配置对象或其子节。
     * @return 返回当前 IdentityServerBuilder 实例。
     */
    public func addInMemoryIdentityResources(configuration: IConfiguration): IdentityServerBuilder {
        let resources = ConfigurationLoader.loadIdentityResources(configuration)
        this.addInMemoryIdentityResources(resources)
        return this
    }

    /**
     * @brief 从配置中添加内存 API 作用域存储。
     * @param configuration 配置实例，通常为构建器配置对象或其子节。
     * @return 返回当前 IdentityServerBuilder 实例。
     */
    public func addInMemoryApiScopes(configuration: IConfiguration): IdentityServerBuilder {
        let scopes = ConfigurationLoader.loadApiScopes(configuration)
        this.addInMemoryApiScopes(scopes)
        return this
    }

    /**
     * @brief 从配置中添加内存 API 资源存储。
     * @param configuration 配置实例，通常为构建器配置对象或其子节。
     * @return 返回当前 IdentityServerBuilder 实例。
     */
    public func addInMemoryApiResources(configuration: IConfiguration): IdentityServerBuilder {
        let resources = ConfigurationLoader.loadApiResources(configuration)
        this.addInMemoryApiResources(resources)
        return this
    }
}

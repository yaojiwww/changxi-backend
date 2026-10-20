// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_hosting

import std.collection.*
import soulsoft_web_routing.*
import stdx.net.http.ServerBuilder

/**
 * @brief 提供构建 WebHost 实例的能力。
 */
public class WebHostBuilder {
    private let _logging: LoggingBuilder
    private let _services: ServiceCollection
    private let _environment: IWebHostEnvironment
    private let _properties = HashMap<String, Any>()
    private let _configuration: ConfigurationManager
    private let _serverConfigurators = ArrayList<(ServerBuilder) -> Unit>()

    init(logging: LoggingBuilder, services: ServiceCollection, environment: IHostEnvironment,
        configuration: ConfigurationManager) {
        _logging = logging
        _services = services
        _environment = createWebHostEnvironment(environment, configuration)
        _configuration = configuration
    }

    /**
     * @brief 构建并返回 WebHost 实例。
     * @return 返回构建完成的 WebHost。
     */
    public func build(): WebHost {
        let lifetime = ApplicationLifetime()
        _services.tryAddSingleton<IServer, DefaultServer> {
            sp => DefaultServer(sp, _serverConfigurators.toArray())
        }
        _services.addSingleton<IHostEnvironment>(_environment)
        _services.addSingleton<IWebHostEnvironment>(_environment)
        _services.addSingleton<IConfiguration>(_configuration.build())
        _services.tryAddSingleton<IHostLifetime, ConsoleLifetime>()
        _services.addSingleton<IHostApplicationLifetime>(lifetime)
        _services.addSingleton<HostedServiceExecutor> {
            sp => return HostedServiceExecutor(sp.getAll<IHostedService>())
        }
        let services = createServiceProvider()
        let loggerFactory = services.getOrThrow<ILoggerFactory>()
        let host = WebHost(services, lifetime, loggerFactory)
        host.properties.add(RoutingConstants.GlobalEndpointRouteBuilderKey, host)
        return host
    }

    private func createServiceProvider() {
        return if (!_environment.isProduction()) {
            _services.build {
                configureOptions =>
                    configureOptions.validateScopes = true
                    configureOptions.validateOnBuild = true
            }
        } else {
            _services.build()
        }
    }

    private static func createWebHostEnvironment(environment: IHostEnvironment, configuration: IConfiguration) {
        return WebHostEnvironment(configuration["webRootPath"] ?? "wwwroot", environment)
    }

    /**
     * @brief 注册底层 HTTP 服务器的配置回调。
     * @param configure 用于配置底层服务器构建器的回调。
     * @return 返回当前构建器。
     */
    public func configureServer(configure: (ServerBuilder) -> Unit): This {
        _serverConfigurators.add(configure)
        return this
    }

    /**
     * @brief 返回当前构建器使用的日志构建器。
     * @return 当前日志构建器。
     */
    public prop logging: LoggingBuilder {
        get() {
            _logging
        }
    }
    /**
     * @brief 返回当前构建器维护的服务集合。
     * @return 当前服务集合。
     */
    public prop services: ServiceCollection {
        get() {
            _services
        }
    }

    /**
     * @brief 返回当前构建器维护的属性集合。
     * @return 当前属性集合。
     */
    public prop properties: HashMap<String, Any> {
        get() {
            _properties
        }
    }

    /**
     * @brief 返回当前构建器使用的 Web 主机环境。
     * @return 当前 Web 主机环境。
     */
    public prop environment: IWebHostEnvironment {
        get() {
            _environment
        }
    }

    /**
     * @brief 返回当前构建器维护的配置管理器。
     * @return 当前配置管理器。
     */
    public prop configuration: ConfigurationManager {
        get() {
            _configuration
        }
    }
}

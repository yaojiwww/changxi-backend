// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_hosting

import std.collection.*

/**
 * @brief 提供主机实例的构建能力。
 */
public class HostBuilder <: IHostBuilder {
    private let _logging: LoggingBuilder
    private let _services: ServiceCollection
    private let _environment: IHostEnvironment
    private let _properties = HashMap<String, Any>()
    private let _configuration: ConfigurationManager

    init(logging: LoggingBuilder, services: ServiceCollection, environment: IHostEnvironment,
        configuration: ConfigurationManager) {
        _logging = logging
        _services = services
        _environment = environment
        _configuration = configuration
    }

    /**
     * @brief 构建主机实例。
     * @return 返回构建得到的主机对象。
     */
    public func build(): IHost {
        let lifetime = ApplicationLifetime()
        _services.addSingleton<IHostEnvironment>(_environment)
        _services.tryAddSingleton<IHostLifetime, ConsoleLifetime>()
        _services.addSingleton<IConfiguration>(_configuration.build())
        _services.addSingleton<IHostApplicationLifetime>(lifetime)
        _services.addSingleton<HostedServiceExecutor> {
            sp => return HostedServiceExecutor(sp.getAll<IHostedService>())
        }
        let services = createServiceProvider()
        let loggerFactory = services.getOrThrow<ILoggerFactory>()
        return Host(services, lifetime, loggerFactory)
    }

    /**
     * @brief 返回日志构建器。
     * @return 返回日志构建器。
     */
    public prop logging: LoggingBuilder {
        get() {
            _logging
        }
    }

    /**
     * @brief 返回服务集合。
     * @return 返回服务集合。
     */
    public prop services: ServiceCollection {
        get() {
            _services
        }
    }

    /**
     * @brief 返回主机环境信息。
     * @return 返回主机环境信息。
     */
    public prop environment: IHostEnvironment {
        get() {
            _environment
        }
    }

    /**
     * @brief 返回构建过程共享的属性集合。
     * @return 返回构建过程共享的属性集合。
     */
    public prop properties: HashMap<String, Any> {
        get() {
            _properties
        }
    }

    /**
     * @brief 返回主机配置管理器。
     * @return 返回主机配置管理器。
     */
    public prop configuration: ConfigurationManager {
        get() {
            _configuration
        }
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
}

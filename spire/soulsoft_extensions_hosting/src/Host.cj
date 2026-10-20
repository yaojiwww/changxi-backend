// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_hosting

import std.env.*
import std.sync.*
import soulsoft_extensions_options.*
import soulsoft_extensions_logging_console.*
import soulsoft_extensions_logging_configuration.*

/**
 * @brief 提供主机运行时实现。
 */
public class Host <: IHost & Resource {
    private let _logger: ILogger
    private let _services: IServiceProvider
    private let _isClosed = AtomicBool(false)
    private let _environment: IHostEnvironment
    private let _configuration: IConfiguration
    private let _applicationLifetime: ApplicationLifetime
    private let _hostedServiceExecutor: HostedServiceExecutor

    init(services: IServiceProvider, applicationLifetime: ApplicationLifetime, loggerFactory: ILoggerFactory) {
        _services = services
        _applicationLifetime = applicationLifetime
        _environment = services.getOrThrow<IHostEnvironment>()
        _configuration = services.getOrThrow<IConfiguration>()
        _hostedServiceExecutor = _services.getOrThrow<HostedServiceExecutor>()
        _logger = loggerFactory.createLogger("soulsoft.hosting.lifetime")
    }

    /**
     * @brief 返回主机使用的日志记录器。
     * @return 返回主机使用的日志记录器。
     */
    public prop logger: ILogger {
        get() {
            _logger
        }
    }

    /**
     * @brief 返回主机的应用生命周期控制器。
     * @return 返回主机的应用生命周期控制器。
     */
    public prop lifetime: IHostApplicationLifetime {
        get() {
            _applicationLifetime
        }
    }

    /**
     * @brief 返回主机的服务提供程序。
     * @return 返回主机的服务提供程序。
     */
    public prop services: IServiceProvider {
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
     * @brief 返回主机配置对象。
     * @return 返回主机配置对象。
     */
    public prop configuration: IConfiguration {
        get() {
            _configuration
        }
    }

    /**
     * @brief 启动主机并等待其关闭。
     */
    public func run(): Unit {
        try {
            start()
            waitForShutdown()
        } finally {
            close()
        }
    }

    /**
     * @brief 启动主机。
     */
    public func start(): Unit {
        logging()
        runStartupValidator()
        _services.getOrThrow<IHostLifetime>().waitForStart()
        _hostedServiceExecutor.start()
        _applicationLifetime.notifyStarted()
    }

    /**
     * @brief 等待主机关闭并执行停止流程。
     */
    public func waitForShutdown(): Unit {
        _applicationLifetime.waitForShutdown()
        stop()
    }

    /**
     * @brief 停止主机。
     */
    public func stop(): Unit {
        _logger.info(EventId(14), "Application is shutting down...")
        _hostedServiceExecutor.stop()
        _applicationLifetime.notifyStopped()
        _services.getOrThrow<IHostLifetime>().stop()
    }

    /**
     * @brief 检查主机是否已关闭。
     * @return 如果主机已关闭则返回 true，否则返回 false。
     */
    public func isClosed(): Bool {
        return _isClosed.load()
    }

    /**
     * @brief 关闭主机及其底层资源。
     */
    public func close(): Unit {
        if (_isClosed.compareAndSwap(false, true)) {
            if (let resource: Resource <- _services) {
                try {
                    resource.close()
                } catch (_: Exception) {
                }
            }
        }
    }

    /**
     * @brief 创建主机构建器并加载默认环境、配置与日志设置。
     * @param args 命令行参数数组。
     * @return 返回主机构建器。
     */
    public static func createBuilder(args: Array<String>): HostBuilder {
        let services = ServiceCollection()
        let environment = configureEnvironment(args)
        let configuration = configureConfiguration(args, environment)
        let logging = configureLogging(services, configuration)
        return HostBuilder(logging, services, environment, configuration)
    }

    private func runStartupValidator() {
        let callSiteFactory = _services.getOrThrow<IServiceProviderIsService>()
        if (callSiteFactory.isService<IStartupValidator>()) {
            try (scope = _services.createScope()) {
                let validator = scope.services.getOrThrow<IStartupValidator>()
                validator.validate()
            }
        }
    }

    private static func configureEnvironment(args: Array<String>): IHostEnvironment {
        let configuration = ConfigurationManager()
        configuration.addEnvVars("cangjie_")
        configuration.addCmdArgs(args)
        let environmentName = configuration["environment"] ?? Environments.Production
        let contentRootPath = configuration["contentRootPath"] ?? getWorkingDirectory().toString()
        let applicationName = configuration["applicationName"] ?? String.empty
        return HostEnvironment(environmentName, contentRootPath, applicationName)
    }

    private static func configureConfiguration(args: Array<String>, environment: IHostEnvironment): ConfigurationManager {
        let configuration = ConfigurationManager()
        configuration.addJsonFile("./appsettings.json", optional: true)
        configuration.addJsonFile("./appsettings.${environment.environmentName}.json", optional: true)
        configuration.addEnvVars("cangjie_")
        configuration.addCmdArgs(args)
        return configuration
    }

    private static func configureLogging(services: ServiceCollection, configuration: IConfiguration): LoggingBuilder {
        // 日志必须在构建之前注册，因为要考虑到用户清除默认的日志提供程序
        services.addLogging {
            builder =>
                builder.addConsole()
                builder.addConfiguration(configuration.getSection("logging"))
        }
        return LoggingBuilder(services)
    }

    private func logging(): Unit {
        _logger.info("Hosting environment: ${_environment.environmentName}")
        _logger.info("Content root path: ${_environment.contentRootPath}")
        _logger.info("Application started. Press Ctrl+C to shut down.")
    }
}

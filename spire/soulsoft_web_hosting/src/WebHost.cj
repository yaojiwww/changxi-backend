// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_hosting

import std.env.*
import std.collection.*
import soulsoft_web_routing.*
import soulsoft_extensions_options.*
import soulsoft_extensions_logging_console.*
import soulsoft_extensions_logging_configuration.*

/**
 * @brief 表示一个可启动和关闭的 Web 主机实例。
 */
public class WebHost <: EndpointRouteBuilder & Resource {
    // 生命周期状态
    private var _isClosed = false
    private let _applicationLifetime: ApplicationLifetime

    // 基础设施
    private let _logger: ILogger
    private let _server: IServer
    private let _services: IServiceProvider
    private let _configuration: IConfiguration
    private let _environment: IWebHostEnvironment

    // 托管服务
    private let _hostedServices: Collection<IHostedService>
    private let _hostedServiceExecutor: HostedServiceExecutor

    // 中间件管道（由 EndpointRouteBuilder 填充）
    private let _middlewares = ArrayList<(RequestDelegate) -> RequestDelegate>()

    init(services: IServiceProvider, applicationLifetime: ApplicationLifetime, loggerFactory: ILoggerFactory) {
        super(services)
        _services = services
        _applicationLifetime = applicationLifetime
        _environment = _services.getOrThrow<IWebHostEnvironment>()
        _configuration = _services.getOrThrow<IConfiguration>()
        _hostedServices = _services.getAll<IHostedService>()
        _server = _services.getOrThrow<IServer>()
        _hostedServiceExecutor = _services.getOrThrow<HostedServiceExecutor>()
        _logger = loggerFactory.createLogger("soulsoft.hosting.lifetime")
        // 存放routing构建器实例
        this.properties[RoutingConstants.GlobalEndpointRouteBuilderKey] = this
    }

    /**
     * @brief 返回当前主机使用的日志记录器。
     * @return 当前日志记录器。
     */
    public prop logger: ILogger {
        get() {
            _logger
        }
    }

    /**
     * @brief 返回当前主机的应用生命周期控制器。
     * @return 当前应用生命周期控制器。
     */
    public prop lifetime: IHostApplicationLifetime {
        get() {
            _applicationLifetime
        }
    }

    /**
     * @brief 返回当前主机的环境信息。
     * @return 当前环境信息。
     */
    public prop environment: IHostEnvironment {
        get() {
            _environment
        }
    }

    /**
     * @brief 返回当前主机的配置对象。
     * @return 当前配置对象。
     */
    public prop configuration: IConfiguration {
        get() {
            _configuration
        }
    }

    /**
     * @brief 运行主机并阻塞直到应用关闭。
     */
    public func run(): Unit {
        run(String.empty)
    }

    /**
     * @brief 以指定地址运行主机并阻塞直到应用关闭。
     * @param urls 要写入配置的监听地址。
     */
    public func run(urls: String): Unit {
        try {
            if (urls.size > 0) {
                _configuration["urls"] = urls
            }
            start()
            waitForShutdown()
        } finally {
            close()
        }
    }

    /**
     * @brief 启动托管服务和 HTTP 服务器。
     */
    public func start(): Unit {
        validateOptionsOnStarted()
        _services.getOrThrow<IHostLifetime>().waitForStart()
        _hostedServiceExecutor.start()
        _applicationLifetime.notifyStarted()
        let app = configureApplication()
        spawn {
            _server.start(app)
        }
    }

    /**
     * @brief 阻塞等待关闭信号并执行关闭流程。
     */
    public func waitForShutdown(): Unit {
        _applicationLifetime.waitForShutdown()
        stop()
    }

    /**
     * @brief 有序停止主机并通知生命周期结束。
     */
    public func stop(): Unit {
        _logger.info(EventId(14), "Application is shutting down...")
        _server.stop()
        _hostedServiceExecutor.stop()
        _applicationLifetime.notifyStopped()
        _services.getOrThrow<IHostLifetime>().stop()
    }

    /**
     * @brief 释放主机持有的资源。
     */
    public func close(): Unit {
        if (_isClosed) {
            return
        }
        if (let resource: Resource <- _services) {
            try {
                resource.close()
            } catch (_: Exception) {
            }
        }
        _isClosed = true
    }

    /**
     * @brief 检查当前主机是否已关闭。
     * @return 如果主机已关闭则返回 true，否则返回 false。
     */
    public func isClosed(): Bool {
        return _isClosed
    }

    /**
     * 构建请求处理管道，若已注册路由端点则自动挂载路由中间件
     */
    private func configureApplication(): RequestDelegate {
        if (this.dataSources.size > 0) {
            this.useRouting()
            this.useEndpoints {_ =>}
        }
        return this.build()
    }

    /**
     * 校验启动选项：执行 IStartupValidator（若已注册），并确保路径配置合法
     */
    private func validateOptionsOnStarted(): Unit {
        let callSiteFactory = _services.getOrThrow<IServiceProviderIsService>()
        if (callSiteFactory.isService<IStartupValidator>()) {
            try (scope = _services.createScope()) {
                let validator = scope.services.getOrThrow<IStartupValidator>()
                validator.validate()
            }
        }
        ensurePathDoesNotEndInSlash(_environment.webRootPath)
        ensurePathDoesNotEndInSlash(_environment.contentRootPath)
    }

    /**
     * @brief 创建一个预置默认环境、配置和日志的主机构建器。
     * @param args 启动时使用的命令行参数。
     * @return 返回创建完成的主机构建器。
     */
    public static func createBuilder(args: Array<String>): WebHostBuilder {
        let services = ServiceCollection()
        let environment = configureEnvironment(args)
        let configuration = configureConfiguration(args, environment)
        let logging = configureLogging(services, configuration)
        return WebHostBuilder(logging, services, environment, configuration)
    }

    /**
     * 从环境变量和命令行参数中读取运行环境配置
     */
    private static func configureEnvironment(args: Array<String>): IHostEnvironment {
        let configuration = ConfigurationManager()
        configuration.addEnvVars("cangjie_")
        configuration.addCmdArgs(args)
        let environmentName = configuration["environment"] ?? Environments.Production
        let contentRootPath = configuration["contentRootPath"] ?? getWorkingDirectory().toString()
        let applicationName = configuration["applicationName"] ?? String.empty
        return HostEnvironment(environmentName, contentRootPath, applicationName)
    }

    /**
     * 构建应用配置：依次叠加环境变量、命令行参数和 appsettings 文件
     */
    private static func configureConfiguration(args: Array<String>, environment: IHostEnvironment): ConfigurationManager {
        let configuration = ConfigurationManager()
        configuration.addJsonFile("./appsettings.json", optional: true)
        configuration.addJsonFile("./appsettings.${environment.environmentName}.json", optional: true)
        configuration.addEnvVars("cangjie_")
        configuration.addCmdArgs(args)
        return configuration
    }

    /**
     * 构建日志配置：注册控制台输出并从配置文件读取日志级别
     */
    private static func configureLogging(services: ServiceCollection, configuration: IConfiguration): LoggingBuilder {
        // 日志必须在构建之前注册，因为要考虑到用户清除默认的日志提供程序
        services.addLogging {
            builder =>
                builder.addConsole()
                builder.addConfiguration(configuration.getSection("logging"))
        }
        return LoggingBuilder(services)
    }
}

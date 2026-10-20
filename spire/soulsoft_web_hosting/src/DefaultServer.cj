// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_hosting

import std.env.*
import std.sync.*
import std.convert.*
import stdx.encoding.url.*
import stdx.log.LogLevel as StdLogLevel
import stdx.net.http.HttpContext as HttpContextBase
import stdx.net.http.{FuncHandler, Server, ServerBuilder, HttpRequestDistributor, HttpRequestHandler}

class DefaultServer <: Resource & IServer {
    private let _logger: ILogger
    private var _server: ?Server = None
    private let _services: IServiceProvider
    private var _isClosed = false
    private var _isStarted = AtomicBool(false)
    private let _serverConfigurators: Array<(ServerBuilder) -> Unit>

    /**
     * @brief 创建一个 HTTP 服务器实例。
     * @param services 服务提供器。
     * @param serverConfigurators 底层服务器构建器配置回调集合。
     */
    public init(services: IServiceProvider, serverConfigurators: Array<(ServerBuilder) -> Unit>) {
        _logger = services.getOrThrow<ILoggerFactory>().createLogger("soulsoft.hosting.lifetime")
        _services = services
        _serverConfigurators = serverConfigurators
    }

    /**
     * @brief 关闭底层服务器资源。
     */
    public func close(): Unit {
        if (_isClosed) {
            return
        }
        _server?.close()
        _isClosed = true
    }

    /**
     * @brief 检查当前服务器是否已关闭。
     * @return 如果服务器已关闭则返回 true，否则返回 false。
     */
    public func isClosed(): Bool {
        return _isClosed
    }

    /**
     * @brief 停止当前服务器。
     */
    public func stop(): Unit {
        close()
    }

    /**
     * @brief 使用指定请求管道启动服务器。
     * @param pipeline 用于处理请求的委托管道。
     */
    public func start(pipeline: RequestDelegate): Unit {
        if (!_isStarted.compareAndSwap(false, true)) {
            return
        }
        let url = resolveHostUrl()
        _server = createServer(pipeline, url)
        _server.getOrThrow().serve()
    }

    private func createServer(pipeline: RequestDelegate, address: String): Server {
        let url = URL.parse(address)
        let port = UInt16.tryParse(url.port) ?? UInt16(80)
        let builder = ServerBuilder()
        for (configure in _serverConfigurators) {
            configure(builder)
        }
        builder.addr(url.hostName)
        builder.port(port)
        builder.afterBind {
            logServerStarted(address)
        }
        builder.distributor(createRequestDistributor(pipeline))
        let server = builder.build()
        server.logger.level = StdLogLevel.ERROR
        return server
    }

    private func createRequestDistributor(pipeline: RequestDelegate) {
        let serviceInspector = _services.getOrThrow<IServiceProviderIsService>()
        let isContextAccessorRegistered = serviceInspector.isService<IHttpContextAccessor>()
        let handler = FuncHandler {
            context => try (requestScope = _services.createScope()) {
                let defaultContext = DefaultHttpContext(context, requestScope.services)
                try {
                    // 如果注册了IHttpContextAccessor
                    if (isContextAccessorRegistered) {
                        setupContextAccessor(defaultContext)
                    }
                    pipeline(defaultContext)
                    defaultContext.defaultResponse.flushResponse()
                } catch (ex: Exception) {
                    // 若响应尚未开始（headers 未发送），返回 500；否则已无法修改响应头，仅记录日志
                    if (!defaultContext.response.hasStarted) {
                        defaultContext.response.statusCode = StatusCodes.InternalServerError
                        defaultContext.defaultResponse.resetHeadersForErrorResponse()
                        defaultContext.response.write("Internal Server Error")
                    }
                    _logger.error(ex, ex.message)
                }
                // 响应发送完毕（无论成功或失败），触发 OnCompleted 回调（资源清理等）
                try {
                    defaultContext.defaultResponse.completeResponse()
                } catch (ex: Exception) {
                    _logger.error(ex, ex.message)
                }
            }
        }
        return DefaultHttpRequestDistributor(handler)
    }

    private func setupContextAccessor(context: DefaultHttpContext): Unit {
        if (let Some(contextAccessor) <- context.services.get<IHttpContextAccessor>()) {
            if (let accessor: HttpContextAccessor <- contextAccessor) {
                accessor.setup(context)
            }
        }
    }

    private func resolveHostUrl(): String {
        let configuration = _services.getOrThrow<IConfiguration>()
        if (let Some(urls) <- configuration.getValue<String>("urls")) {
            return urls
        }
        let host = if (isRunningInContainer()) {
            "0.0.0.0"
        } else {
            "127.0.0.1"
        }
        let port = configuration.getValue<String>("HTTP_PORTS") ?? "5000"
        return "http://${host}:${port}"
    }

    private func logServerStarted(address: String): Unit {
        let environment = _services.getOrThrow<IWebHostEnvironment>()
        _logger.info(EventId(14), "Now listening on: ${address}")
        _logger.info("Hosting environment: ${environment.environmentName}")
        _logger.info("Content root path: ${environment.contentRootPath}")
        _logger.info("Application started. Press Ctrl+C to shut down.")
    }

    private func isRunningInContainer(): Bool {
        if (let Some(value) <- getVariable("CANGJIE_RUNNING_IN_CONTAINER")) {
            return value.equalsIgnoreAsciiCase("true")
        }
        return false
    }
}

private class DefaultHttpRequestDistributor <: HttpRequestDistributor {
    private let _handler: FuncHandler

    init(handler: FuncHandler) {
        _handler = handler
    }

    /**
     * @brief 注册指定路径的请求处理器。
     * @param _ 要注册的路径模式。
     * @param _ 要注册的请求处理器。
     */
    public func register(_: String, _: HttpRequestHandler): Unit {
    }

    /**
     * @brief 注册指定路径的上下文处理函数。
     * @param _ 要注册的路径模式。
     * @param _ 要注册的上下文处理函数。
     */
    public func register(_: String, _: (HttpContextBase) -> Unit): Unit {
    }

    /**
     * @brief 返回用于处理请求的分发结果。
     * @param _ 当前请求使用的路径模式。
     * @return 当前分发器持有的请求处理器。
     */
    public func distribute(_: String): HttpRequestHandler {
        return _handler
    }
}

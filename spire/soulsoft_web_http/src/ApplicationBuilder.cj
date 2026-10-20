// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_http

import std.collection.*
import soulsoft_extensions_injection.*

/**
 * @brief 提供构建 HTTP 中间件管道的能力。
 */
public open class ApplicationBuilder {
    private let _services: IServiceProvider
    private let _properties: HashMap<String, Any>
    private let _middlewares = ArrayList<(RequestDelegate) -> RequestDelegate>()

    /**
     * @brief 使用指定服务提供器创建应用构建器。
     * @param services 应用构建器使用的服务提供器。
     */
    public init(services: IServiceProvider) {
        _services = services
        _properties = HashMap<String, Any>()
    }

    /**
     * @brief 基于现有应用构建器创建新的应用构建器。
     * @param builder 要复制配置的应用构建器。
     */
    public init(builder: ApplicationBuilder) {
        _services = builder.services
        _properties = HashMap<String, Any>(builder.properties)
    }

    /**
     * @brief 返回当前构建器使用的服务提供器。
     * @return 当前服务提供器。
     */
    public prop services: IServiceProvider {
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
     * @brief 追加一个请求委托转换中间件。
     * @param middleware 用于包装下一个委托的中间件工厂。
     * @return 返回当前应用构建器。
     */
    public func use(middleware: (RequestDelegate) -> RequestDelegate): This {
        _middlewares.add(middleware)
        return this
    }

    /**
     * @brief 追加一个基于上下文和下一个委托的中间件。
     * @param middleware 用于处理上下文并调用下一个委托的中间件。
     * @return 返回当前应用构建器。
     */
    public func use(middleware: (HttpContext, RequestDelegate) -> Unit): This {
        use {
            next => {
                context => middleware(context, next)
            }
        }
        return this
    }

    /**
     * @brief 追加一个中间件实例。
     * @param middleware 要追加的中间件实例。
     * @return 返回当前应用构建器。
     */
    public func use(middleware: IMiddleware): This {
        use {
            context, next => middleware.invoke(context, next)
        }
    }

    /**
     * @brief 创建并追加一个中间件类型实例。
     * @param args 创建中间件实例时使用的附加参数。
     * @return 返回当前应用构建器。
     */
    public func use<TMiddleware>(args: Array<Any>): This where TMiddleware <: IMiddleware {
        use(ActivatorUtilities.createInstance<TMiddleware>(services, args))
    }

    /**
     * @brief 创建一个复制当前配置的新应用构建器。
     * @return 返回新的应用构建器。
     */
    public func new(): ApplicationBuilder {
        return ApplicationBuilder(this)
    }

    /**
     * @brief 构建并返回请求处理管道。
     * @return 构建完成的请求处理委托。
     */
    public func build(): RequestDelegate {
        var app: RequestDelegate = {
            context => context.response.statusCode = StatusCodes.NotFound
        }
        var index = _middlewares.size - 1
        while (index >= 0) {
            let middleware = _middlewares[index]
            app = middleware(app)
            index--
        }
        return app
    }
}

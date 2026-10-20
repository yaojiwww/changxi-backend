// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_extensions_http

import std.reflect.*
import std.collection.*
import soulsoft_net_http.*
import soulsoft_extensions_options.*
import soulsoft_extensions_injection.*

/**
 * @brief 提供命名 HTTP 客户端的配置构建能力。
 */
public class HttpClientBuilder {
    private let _name: String
    private let _services: ServiceCollection

    init(name: String, services: ServiceCollection) {
        _name = name
        _services = services
    }

    /**
     * @brief 返回当前 HTTP 客户端名称。
     * @return 返回当前 HTTP 客户端名称。
     */
    public prop name: String {
        get() {
            _name
        }
    }

    /**
     * @brief 返回用于注册 HTTP 客户端的服务集合。
     * @return 返回用于注册 HTTP 客户端的服务集合。
     */
    public prop services: ServiceCollection {
        get() {
            _services
        }
    }
}

extend HttpClientBuilder {
    /**
     * @brief 设置处理器生命周期。
     * @param handlerLifetime 处理器生命周期。
     * @return 返回当前 HTTP 客户端构建器，便于继续链式配置。
     * @throws IllegalArgumentException 当处理器生命周期小于最小值且不为零时抛出。
     */
    public func setHandlerLifetime(handlerLifetime: Duration): HttpClientBuilder {
        if (handlerLifetime != Duration.Zero && handlerLifetime < HttpClientFactoryOptions.MinimumHandlerLifetime) {
            throw IllegalArgumentException(
                "The handler lifetime must be at least ${HttpClientFactoryOptions.MinimumHandlerLifetime.toSeconds()} second.")
        }

        services.configure<HttpClientFactoryOptions>(name) {
            options => options.handlerLifetime = handlerLifetime
        }
        return this
    }

    /**
     * @brief 配置 HTTP 客户端实例。
     * @param configureClient 用于配置 HTTP 客户端的回调。
     * @return 返回当前 HTTP 客户端构建器，便于继续链式配置。
     */
    public func configureHttpClient(configureClient: (HttpClient) -> Unit): HttpClientBuilder {
        services.configure<HttpClientFactoryOptions>(name) {
            options => options.httpClientActions.add(configureClient)
        }
        return this
    }

    /**
     * @brief 配置 HTTP 客户端实例并访问服务提供程序。
     * @param configureClient 用于配置 HTTP 客户端的回调。
     * @return 返回当前 HTTP 客户端构建器，便于继续链式配置。
     */
    public func configureHttpClient(configureClient: (HttpClient, IServiceProvider) -> Unit): HttpClientBuilder {
        services.configure<HttpClientFactoryOptions>(name) {
            options, sp => options.httpClientActions.add({client => configureClient(client, sp)})
        }
        return this
    }

    /**
     * @brief 添加通过无参工厂创建的附加消息处理器。
     * @param configureHandler 用于创建附加消息处理器的回调。
     * @return 返回当前 HTTP 客户端构建器，便于继续链式配置。
     */
    public func addHttpMessageHandler(configureHandler: () -> DelegatingHandler): HttpClientBuilder {
        services.configure<HttpClientFactoryOptions>(name) {
            options => options.httpMessageHandlerBuilderActions.add({
                b => b.additionalHandlers.add(configureHandler())
            })
        }
        return this
    }

    /**
     * @brief 添加通过服务提供程序创建的附加消息处理器。
     * @param configureHandler 用于创建附加消息处理器的回调。
     * @return 返回当前 HTTP 客户端构建器，便于继续链式配置。
     */
    public func addHttpMessageHandler(configureHandler: (IServiceProvider) -> DelegatingHandler): HttpClientBuilder {
        services.configure<HttpClientFactoryOptions>(name) {
            options => options.httpMessageHandlerBuilderActions.add({
                b => b.additionalHandlers.add(configureHandler(b.services))
            })
        }
        return this
    }

    /**
     * @brief 添加一个从依赖注入容器解析的附加消息处理器类型。
     * @return 返回当前 HTTP 客户端构建器，便于继续链式配置。
     */
    public func addHttpMessageHandler<THandler>(): HttpClientBuilder where THandler <: DelegatingHandler {
        services.configure<HttpClientFactoryOptions>(name) {
            options => options.httpMessageHandlerBuilderActions.add({
                b => b.additionalHandlers.add(b.services.getOrThrow<THandler>())
            })
        }
        return this
    }

    /**
     * @brief 配置消息处理器构建器。
     * @param configureBuilder 用于配置消息处理器构建器的回调。
     * @return 返回当前 HTTP 客户端构建器，便于继续链式配置。
     */
    public func configureHttpMessageHandlerBuilder(configureBuilder: (HttpMessageHandlerBuilder) -> Unit): HttpClientBuilder {
        services.configure<HttpClientFactoryOptions>(name) {
            options => options.httpMessageHandlerBuilderActions.add(configureBuilder)
        }
        return this
    }

    /**
     * @brief 配置主 HTTP 消息处理器。
     * @param configureHandler 用于创建主 HTTP 消息处理器的回调。
     * @return 返回当前 HTTP 客户端构建器，便于继续链式配置。
     */
    public func configurePrimaryHttpMessageHandler(configureHandler: () -> HttpMessageHandler): HttpClientBuilder {
        services.configure<HttpClientFactoryOptions>(name) {
            options => options.httpMessageHandlerBuilderActions.add({
                b => b.primaryHandler = configureHandler()
            })
        }
        return this
    }

    /**
     * @brief 使用服务提供程序配置主 HTTP 消息处理器。
     * @param configureHandler 用于创建主 HTTP 消息处理器的回调。
     * @return 返回当前 HTTP 客户端构建器，便于继续链式配置。
     */
    public func configurePrimaryHttpMessageHandler(configureHandler: (IServiceProvider) -> HttpMessageHandler): HttpClientBuilder {
        services.configure<HttpClientFactoryOptions>(name) {
            options => options.httpMessageHandlerBuilderActions.add({
                b => b.primaryHandler = configureHandler(b.services)
            })
        }
        return this
    }

    /**
     * @brief 配置从依赖注入容器解析的主 HTTP 消息处理器类型。
     * @return 返回当前 HTTP 客户端构建器，便于继续链式配置。
     */
    public func configurePrimaryHttpMessageHandler<THandler>(): HttpClientBuilder where THandler <: HttpMessageHandler {
        services.configure<HttpClientFactoryOptions>(name) {
            options => options.httpMessageHandlerBuilderActions.add({
                b => b.primaryHandler = b.services.getOrThrow<THandler>()
            })
        }
        return this
    }

    /**
     * @brief 注册一个使用默认构造规则的类型化 HTTP 客户端。
     * @return 返回当前 HTTP 客户端构建器，便于继续链式配置。
     */
    public func addTypedClient<TClient, TImplementation>(): HttpClientBuilder where TImplementation <: Object {
        addTypedClientCore<TClient, TImplementation>(false)
        return this
    }

    internal func addTypedClientCore<TClient, TImplementation>(validateSingleType: Bool) where TImplementation <: Object {
        reserveClient(TypeInfo.of<TClient>(), name, validateSingleType)

        services.addTransient<TClient, TImplementation> {
            sp =>
                let clientFactory = sp.getOrThrow<IHttpClientFactory>()
                let client = clientFactory.createClient(name)
                ActivatorUtilities.createInstance<TImplementation>(sp, client)
        }
        return this
    }

    /**
     * @brief 注册一个通过工厂创建的类型化 HTTP 客户端。
     * @param factory 基于 HTTP 客户端创建实现实例的工厂。
     * @return 返回当前 HTTP 客户端构建器，便于继续链式配置。
     */
    public func addTypedClient<TClient, TImplementation>(factory: (HttpClient) -> TImplementation): HttpClientBuilder where TImplementation <: Object {
        reserveClient(TypeInfo.of<TClient>(), name, false)
        services.addTransient<TClient, TImplementation> {
            sp =>
                let httpClientFactory = sp.getOrThrow<IHttpClientFactory>()
                let httpClient = httpClientFactory.createClient(name)
                return factory(httpClient)
        }
        return this
    }

    /**
     * @brief 注册一个通过工厂和服务提供程序创建的类型化 HTTP 客户端。
     * @param factory 基于 HTTP 客户端和服务提供程序创建实现实例的工厂。
     * @return 返回当前 HTTP 客户端构建器，便于继续链式配置。
     */
    public func addTypedClient<TClient, TImplementation>(factory: (HttpClient, IServiceProvider) -> TImplementation): HttpClientBuilder where TImplementation <: Object {
        reserveClient(TypeInfo.of<TClient>(), name, false)
        services.addTransient<TClient, TImplementation> {
            sp =>
                let httpClientFactory = sp.getOrThrow<IHttpClientFactory>()
                let httpClient = httpClientFactory.createClient(name)
                return factory(httpClient, sp)
        }
        return this
    }

    private func reserveClient(typeInfo: TypeInfo, name: String, validateSingleType: Bool) {
        let registry = getHttpClientMappingRegistry()
        // 验证和注册命名 HttpClient 客户端，防止命名冲突和类型混淆。
        if (let Some(otherType) <- registry.namedClientRegistrations.get(name) && validateSingleType && typeInfo !=
            otherType) {
            let message = "The HttpClient factory already has a registered client with the name '${name}', bound to the type '${otherType.qualifiedName}'. Client names are computed based on the type name without considering the namespace ('${otherType.name}'). Use an overload of AddHttpClient that accepts a string and provide a unique name to resolve the conflict."
            throw UnsupportedException(message)
        }

        if (validateSingleType) {
            registry.namedClientRegistrations[name] = typeInfo
        }
    }

    private func getHttpClientMappingRegistry() {
        let descriptor = services |> filter {f => f.serviceType == TypeInfo.of<HttpClientMappingRegistry>()} |> first
        return descriptor
            .flatMap {f => f.implementationInstance.flatMap {f => f as HttpClientMappingRegistry}}
            .getOrThrow()
    }
}

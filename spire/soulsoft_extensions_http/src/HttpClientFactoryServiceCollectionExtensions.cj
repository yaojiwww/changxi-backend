// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_http

import std.reflect.*
import soulsoft_net_http.*
import soulsoft_extensions_options.*
import soulsoft_extensions_injection.*

/**
 * @brief 提供 HTTP 客户端工厂服务注册扩展。
 */
public interface HttpClientFactoryServiceCollectionExtensions {
    /**
     * @brief 注册 HTTP 客户端工厂核心服务。
     * @return 返回当前服务集合，便于继续链式配置。
     */
    func addHttpClientCore(): ServiceCollection

    /**
     * @brief 按名称注册 HTTP 客户端。
     * @param name 客户端名称。
     * @return 返回 HTTP 客户端构建器。
     */
    func addHttpClient(name: String): HttpClientBuilder

    /**
     * @brief 按名称注册 HTTP 客户端并配置客户端实例。
     * @param name 客户端名称。
     * @param configureClient 用于配置 HTTP 客户端的回调。
     * @return 返回 HTTP 客户端构建器。
     */
    func addHttpClient(name: String, configureClient: (HttpClient) -> Unit): HttpClientBuilder

    /**
     * @brief 按名称注册 HTTP 客户端并访问服务提供程序。
     * @param name 客户端名称。
     * @param configureClient 用于配置 HTTP 客户端的回调。
     * @return 返回 HTTP 客户端构建器。
     */
    func addHttpClient(name: String, configureClient: (HttpClient, IServiceProvider) -> Unit): HttpClientBuilder

    /**
     * @brief 配置默认 HTTP 客户端构建规则。
     * @param configure 用于配置默认 HTTP 客户端构建器的回调。
     * @return 返回当前服务集合，便于继续链式配置。
     */
    func configureHttpClientDefaults(configure: (HttpClientBuilder) -> Unit): ServiceCollection

    /**
     * @brief 注册一个类型化 HTTP 客户端。
     * @return 返回 HTTP 客户端构建器。
     */
    func addHttpClient<TClient, TImplementation>(): HttpClientBuilder where TImplementation <: Object

    /**
     * @brief 注册一个类型化 HTTP 客户端并配置客户端实例。
     * @param configureClient 用于配置 HTTP 客户端的回调。
     * @return 返回 HTTP 客户端构建器。
     */
    func addHttpClient<TClient, TImplementation>(configureClient: (HttpClient) -> Unit): HttpClientBuilder where TImplementation <: Object

    /**
     * @brief 注册一个类型化 HTTP 客户端并访问服务提供程序。
     * @param configureClient 用于配置 HTTP 客户端的回调。
     * @return 返回 HTTP 客户端构建器。
     */
    func addHttpClient<TClient, TImplementation>(configureClient: (HttpClient, IServiceProvider) -> Unit): HttpClientBuilder where TImplementation <: Object

    /**
     * @brief 注册一个通过工厂创建的类型化 HTTP 客户端。
     * @param factory 基于 HTTP 客户端创建实现实例的工厂。
     * @return 返回 HTTP 客户端构建器。
     */
    func addHttpClient<TClient, TImplementation>(factory: (HttpClient) -> TImplementation): HttpClientBuilder where TImplementation <: Object

    /**
     * @brief 注册一个通过工厂和服务提供程序创建的类型化 HTTP 客户端。
     * @param factory 基于 HTTP 客户端和服务提供程序创建实现实例的工厂。
     * @return 返回 HTTP 客户端构建器。
     */
    func addHttpClient<TClient, TImplementation>(factory: (HttpClient, IServiceProvider) -> TImplementation): HttpClientBuilder where TImplementation <: Object
}

extend ServiceCollection <: HttpClientFactoryServiceCollectionExtensions {
    /**
     * @brief 注册 HTTP 客户端工厂核心服务。
     * @return 返回当前服务集合，便于继续链式配置。
     */
    public func addHttpClientCore(): ServiceCollection {
        this.addOptions<HttpClientFactoryOptions>()
        this.tryAddSingleton(HttpClientMappingRegistry())
        this.tryAddSingleton<IHttpClientFactory> {
            sp =>
                let scopeFactory = sp.getOrThrow<IServiceScopeFactory>()
                let optionsMonitor = sp.getOrThrow<IOptionsMonitor<HttpClientFactoryOptions>>()
                let filters = sp.getAll<IHttpMessageHandlerBuilderFilter>().toArray()
                DefaultHttpClientFactory(scopeFactory, optionsMonitor, filters)
        }
        this.tryAddTransient<HttpMessageHandlerBuilder, DefaultHttpMessageHandlerBuilder>()
        this.tryAddSingleton<HttpClient, HttpClient> {
            sp => sp.getOrThrow<IHttpClientFactory>().createClient(String.empty)
        }
        return this
    }

    /**
     * @brief 注册一个类型化 HTTP 客户端。
     * @return 返回 HTTP 客户端构建器。
     */
    public func addHttpClient<TClient, TImplementation>(): HttpClientBuilder where TImplementation <: Object {
        addHttpClientCore()
        let name = TypeInfo.of<TClient>().qualifiedName
        return HttpClientBuilder(name, this).addTypedClientCore<TClient, TImplementation>(true)
    }

    /**
     * @brief 注册一个类型化 HTTP 客户端并配置客户端实例。
     * @param configureClient 用于配置 HTTP 客户端的回调。
     * @return 返回 HTTP 客户端构建器。
     */
    public func addHttpClient<TClient, TImplementation>(configureClient: (HttpClient) -> Unit): HttpClientBuilder where TImplementation <: Object {
        addHttpClientCore()
        let name = TypeInfo.of<TClient>().qualifiedName
        return HttpClientBuilder(name, this)
            .configureHttpClient(configureClient)
            .addTypedClientCore<TClient, TImplementation>(true)
    }

    /**
     * @brief 注册一个类型化 HTTP 客户端并访问服务提供程序。
     * @param configureClient 用于配置 HTTP 客户端的回调。
     * @return 返回 HTTP 客户端构建器。
     */
    public func addHttpClient<TClient, TImplementation>(configureClient: (HttpClient, IServiceProvider) -> Unit): HttpClientBuilder where TImplementation <: Object {
        addHttpClientCore()
        let name = TypeInfo.of<TClient>().qualifiedName
        return HttpClientBuilder(name, this)
            .configureHttpClient(configureClient)
            .addTypedClientCore<TClient, TImplementation>(true)
    }

    /**
     * @brief 注册一个通过工厂创建的类型化 HTTP 客户端。
     * @param factory 基于 HTTP 客户端创建实现实例的工厂。
     * @return 返回 HTTP 客户端构建器。
     */
    public func addHttpClient<TClient, TImplementation>(factory: (HttpClient) -> TImplementation): HttpClientBuilder where TImplementation <: Object {
        addHttpClientCore()
        let name = TypeInfo.of<TClient>().qualifiedName
        return HttpClientBuilder(name, this).addTypedClient<TClient, TImplementation>(factory)
    }

    /**
     * @brief 注册一个通过工厂和服务提供程序创建的类型化 HTTP 客户端。
     * @param factory 基于 HTTP 客户端和服务提供程序创建实现实例的工厂。
     * @return 返回 HTTP 客户端构建器。
     */
    public func addHttpClient<TClient, TImplementation>(factory: (HttpClient, IServiceProvider) -> TImplementation): HttpClientBuilder where TImplementation <: Object {
        addHttpClientCore()
        let name = TypeInfo.of<TClient>().qualifiedName
        return HttpClientBuilder(name, this).addTypedClient<TClient, TImplementation>(factory)
    }

    /**
     * @brief 按名称注册 HTTP 客户端。
     * @param name 客户端名称。
     * @return 返回 HTTP 客户端构建器。
     */
    public func addHttpClient(name: String): HttpClientBuilder {
        addHttpClientCore()
        return HttpClientBuilder(name, this)
    }

    /**
     * @brief 按名称注册 HTTP 客户端并配置客户端实例。
     * @param name 客户端名称。
     * @param configureClient 用于配置 HTTP 客户端的回调。
     * @return 返回 HTTP 客户端构建器。
     */
    public func addHttpClient(name: String, configureClient: (HttpClient) -> Unit): HttpClientBuilder {
        addHttpClientCore()
        return HttpClientBuilder(name, this).configureHttpClient(configureClient)
    }

    /**
     * @brief 按名称注册 HTTP 客户端并访问服务提供程序。
     * @param name 客户端名称。
     * @param configureClient 用于配置 HTTP 客户端的回调。
     * @return 返回 HTTP 客户端构建器。
     */
    public func addHttpClient(name: String, configureClient: (HttpClient, IServiceProvider) -> Unit): HttpClientBuilder {
        addHttpClientCore()
        return HttpClientBuilder(name, this).configureHttpClient(configureClient)
    }

    /**
     * @brief 配置默认 HTTP 客户端构建规则。
     * @param configure 用于配置默认 HTTP 客户端构建器的回调。
     * @return 返回当前服务集合，便于继续链式配置。
     */
    public func configureHttpClientDefaults(configure: (HttpClientBuilder) -> Unit): ServiceCollection {
        addHttpClientCore()
        configure(HttpClientBuilder(Options.defaultName, this))
        return this
    }
}

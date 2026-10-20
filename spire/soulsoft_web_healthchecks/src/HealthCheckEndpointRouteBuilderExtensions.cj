// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_healthchecks

import soulsoft_web_routing.*
import soulsoft_extensions_options.*

/**
 * @brief 提供将健康检查终结点映射到路由构建器的扩展约定。
 */
public interface HealthCheckEndpointRouteBuilderExtensions {
    /**
     * @brief 使用默认选项映射健康检查终结点。
     * @param pattern 要映射的路由模式。
     * @return 返回当前终结点约定构建器。
     */
    func mapHealthChecks(pattern: String): EndpointConventionBuilder {
        mapHealthChecks(pattern, HealthCheckOptions())
    }
    /**
     * @brief 使用自定义选项回调映射健康检查终结点。
     * @param pattern 要映射的路由模式。
     * @param configureOptions 用于配置健康检查选项的回调。
     * @return 返回当前终结点约定构建器。
     */
    func mapHealthChecks(pattern: String, configureOptions: (HealthCheckOptions) -> Unit): EndpointConventionBuilder {
        let options = HealthCheckOptions()
        configureOptions(options)
        mapHealthChecks(pattern, options)
    }
    /**
     * @brief 使用指定选项映射健康检查终结点。
     * @param pattern 要映射的路由模式。
     * @param options 要使用的健康检查选项。
     * @return 返回当前终结点约定构建器。
     */
    func mapHealthChecks(pattern: String, options: HealthCheckOptions): EndpointConventionBuilder
}

extend EndpointRouteBuilder <: HealthCheckEndpointRouteBuilderExtensions {
    /**
     * @brief 使用指定选项映射健康检查终结点。
     * @param pattern 要映射的路由模式。
     * @param options 要使用的健康检查选项。
     * @return 返回当前终结点约定构建器。
     * @throws Exception 当所需的健康检查服务未注册时抛出。
     */
    public func mapHealthChecks(pattern: String, options: HealthCheckOptions): EndpointConventionBuilder {
        if (let Some(checkService) <- services.get<IHealthCheckService>()) {
            let pipeline = this
                .createApplicationBuilder()
                .use(HealthCheckMiddleware(pattern, checkService, Options.create<HealthCheckOptions>(options)))
                .build()
            return this.map(pattern, pipeline)
        } else {
            throw Exception(
                "Unable to find the required services. Please add all the required services by calling 'ServiceCollection.addHealthChecks' inside the call to 'configureServices(...)' in the application startup code.")
        }
    }
}

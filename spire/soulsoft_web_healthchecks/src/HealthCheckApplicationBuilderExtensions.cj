// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_healthchecks

import soulsoft_extensions_options.*

/**
 * @brief 提供将健康检查中间件接入应用管道的扩展约定。
 */
public interface HealthCheckApplicationBuilderExtensions {
    /**
     * @brief 使用默认选项在指定路径启用健康检查。
     * @param path 健康检查请求路径。
     */
    func useHealthChecks(path: String): Unit {
        useHealthChecks(path, HealthCheckOptions())
    }
    /**
     * @brief 使用自定义选项回调在指定路径启用健康检查。
     * @param path 健康检查请求路径。
     * @param configureOptions 用于配置健康检查选项的回调。
     */
    func useHealthChecks(path: String, configureOptions: (HealthCheckOptions) -> Unit): Unit {
        let options = HealthCheckOptions()
        configureOptions(options)
        useHealthChecks(path, options)
    }
    /**
     * @brief 使用指定选项在指定路径启用健康检查。
     * @param path 健康检查请求路径。
     * @param options 要使用的健康检查选项。
     */
    func useHealthChecks(path: String, options: HealthCheckOptions): Unit
}

extend ApplicationBuilder <: HealthCheckApplicationBuilderExtensions {
    /**
     * @brief 使用指定选项在指定路径启用健康检查。
     * @param path 健康检查请求路径。
     * @param options 要使用的健康检查选项。
     * @throws UnsupportedException 当所需的健康检查服务未注册时抛出。
     */
    public func useHealthChecks(path: String, options: HealthCheckOptions): Unit {
        if (let Some(checkService) <- services.get<IHealthCheckService>()) {
            let middleware = HealthCheckMiddleware(path, checkService, Options.create<HealthCheckOptions>(options))
            let normalizedPath = path.trimEnd([r'/'])
            // 使用 mapWhen 而非 map，避免 /health 和 /health/detailed 等路径重叠时的顺序敏感问题
            let predicate: (HttpContext) -> Bool = {
                c =>
                // 路径过滤：空路径接受所有请求；否则精确匹配（允许尾部斜杠）
                path.isEmpty() || c.request.path.value.trimEnd([r'/']) == normalizedPath
            }
            this.mapWhen(predicate) {app => app.use(middleware)}
        } else {
            throw UnsupportedException(
                "Unable to find the required services. Please add all the required services by calling 'ServiceCollection.addHealthChecks' inside the call to 'configureServices(...)' in the application startup code.")
        }
    }
}

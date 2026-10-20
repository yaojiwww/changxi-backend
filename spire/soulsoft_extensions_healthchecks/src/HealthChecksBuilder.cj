// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_healthchecks

import soulsoft_extensions_options.*
import soulsoft_extensions_injection.*

/**
 * @brief 提供健康检查服务的注册构建能力。
 */
public class HealthChecksBuilder {
    private let _services: ServiceCollection

    init(services: ServiceCollection) {
        _services = services
    }

    /**
     * @brief 返回用于注册健康检查及其依赖的服务集合。
     * @return 返回当前构建器持有的服务集合，便于继续补充相关服务注册。
     */
    public prop services: ServiceCollection {
        get() {
            _services
        }
    }

    /**
     * @brief 添加一个健康检查注册信息。
     * @param registration 要添加的健康检查注册信息。
     * @return 返回当前健康检查构建器，便于继续链式配置。
     */
    public func addCheck(registration: HealthCheckRegistration): HealthChecksBuilder {
        _services.configure<HealthCheckServiceOptions> {
            options => options.registrations.add(registration)
        }
        return this
    }

    /**
     * @brief 添加一个使用默认配置的委托健康检查。
     * @param name 健康检查名称。
     * @param check 执行健康检查并返回结果的回调。
     * @return 返回当前健康检查构建器，便于继续链式配置。
     */
    public func addCheck(name: String, check: () -> HealthCheckResult): HealthChecksBuilder {
        return addCheck(name, Duration.Zero, Array<String>(), check)
    }

    /**
     * @brief 添加一个带标签的委托健康检查。
     * @param name 健康检查名称。
     * @param tags 健康检查关联的标签集合。
     * @param check 执行健康检查并返回结果的回调。
     * @return 返回当前健康检查构建器，便于继续链式配置。
     */
    public func addCheck(name: String, tags: Array<String>, check: () -> HealthCheckResult): HealthChecksBuilder {
        return addCheck(name, Duration.Zero, tags, check)
    }

    /**
     * @brief 添加一个自定义超时与标签的委托健康检查。
     * @param name 健康检查名称。
     * @param timeout 健康检查执行超时时长。
     * @param tags 健康检查关联的标签集合。
     * @param check 执行健康检查并返回结果的回调。
     * @return 返回当前健康检查构建器，便于继续链式配置。
     */
    public func addCheck(name: String, timeout: Duration, tags: Array<String>, check: () -> HealthCheckResult): HealthChecksBuilder {
        return addCheck(HealthCheckRegistration(name, timeout, tags, {
            _ => DelegateHealthCheck(check)
        }))
    }

    /**
     * @brief 添加一个使用默认配置的类型化健康检查。
     * @param name 健康检查名称。
     * @return 返回当前健康检查构建器，便于继续链式配置。
     */
    public func addCheck<T>(name: String): HealthChecksBuilder where T <: IHealthCheck {
        return addCheck(HealthCheckRegistration(name, Duration.Zero, Array<String>(), {
            sp => ActivatorUtilities.createInstance<T>(sp)
        }))
    }

    /**
     * @brief 添加一个带标签的类型化健康检查。
     * @param name 健康检查名称。
     * @param tags 健康检查关联的标签集合。
     * @return 返回当前健康检查构建器，便于继续链式配置。
     */
    public func addCheck<T>(name: String, tags: Array<String>): HealthChecksBuilder where T <: IHealthCheck {
        return addCheck(HealthCheckRegistration(name, Duration.Zero, tags, {
            sp => ActivatorUtilities.createInstance<T>(sp)
        }))
    }

    /**
     * @brief 添加一个自定义超时与标签的类型化健康检查。
     * @param name 健康检查名称。
     * @param timeout 健康检查执行超时时长。
     * @param tags 健康检查关联的标签集合。
     * @return 返回当前健康检查构建器，便于继续链式配置。
     */
    public func addCheck<T>(name: String, timeout: Duration, tags: Array<String>): HealthChecksBuilder where T <: IHealthCheck {
        return addCheck(HealthCheckRegistration(name, timeout, tags, {
            sp => ActivatorUtilities.createInstance<T>(sp)
        }))
    }
}

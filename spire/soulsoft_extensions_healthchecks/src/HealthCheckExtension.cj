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
 * @brief 提供健康检查服务注册扩展。
 */
public interface HealthCheckExtension {
    /**
     * @brief 注册健康检查服务。
     * @return 返回健康检查构建器，便于继续配置健康检查项。
     */
    func addHealthChecks(): HealthChecksBuilder
}

extend ServiceCollection <: HealthCheckExtension {
    /**
     * @brief 注册健康检查服务。
     * @return 返回健康检查构建器，便于继续配置健康检查项。
     */
    public func addHealthChecks(): HealthChecksBuilder {
        this.addOptions<HealthCheckServiceOptions>()
        this.tryAddSingleton<IHealthCheckService, HealthCheckService> {sp => HealthCheckService(sp)}
        return HealthChecksBuilder(this)
    }
}

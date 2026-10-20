// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_healthchecks

/**
 * @brief 提供基于委托的健康检查实现。
 */
public class DelegateHealthCheck <: IHealthCheck {
    private let _check: () -> HealthCheckResult

    /**
     * @brief 创建基于委托的健康检查实例。
     * @param check 执行健康检查并返回结果的回调。
     */
    public init(check: () -> HealthCheckResult) {
        _check = check
    }

    /**
     * @brief 执行委托定义的健康检查逻辑。
     * @param _ 当前健康检查上下文。
     * @return 返回健康检查结果。
     */
    public func check(_: HealthCheckContext): HealthCheckResult {
        return _check()
    }
}

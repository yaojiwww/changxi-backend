// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_healthchecks

/**
 * @brief 定义单个健康检查的公共接口。
 */
public interface IHealthCheck {
    /**
     * @brief 执行当前健康检查。
     * @param context 当前健康检查的执行上下文。
     * @return 返回健康检查结果。
     */
    func check(context: HealthCheckContext): HealthCheckResult
}

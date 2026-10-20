// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_healthchecks

/**
 * @brief 定义健康检查服务的公共接口。
 */
public interface IHealthCheckService {
    /**
     * @brief 执行全部已注册的健康检查。
     * @return 返回聚合后的健康检查报告。
     */
    func checkHealth(): HealthReport {
        checkHealth {_ => true}
    }

    /**
     * @brief 按条件执行已注册的健康检查。
     * @param predicate 用于筛选健康检查注册信息的条件。
     * @return 返回聚合后的健康检查报告。
     */
    func checkHealth(predicate: (HealthCheckRegistration) -> Bool): HealthReport
}

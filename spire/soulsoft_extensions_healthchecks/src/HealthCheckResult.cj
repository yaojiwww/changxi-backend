// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_healthchecks

import std.collection.*

/**
 * @brief 表示单个健康检查的执行结果。
 */
public class HealthCheckResult {
    private let _status: HealthStatus
    private let _description: ?String
    private let _exception: ?Exception
    private let _data: ReadOnlyMap<String, Object>

    /**
     * @brief 创建健康检查结果。
     * @param status 健康检查状态。
     * @param description 健康检查结果描述。
     * @param exception 健康检查过程中捕获的异常。
     * @param data 健康检查附带的数据集合。
     */
    public init(status: HealthStatus, description: ?String, exception: ?Exception, data: HashMap<String, Object>) {
        _data = data
        _status = status
        _exception = exception
        _description = description
    }

    /**
     * @brief 返回当前健康检查状态。
     * @return 返回当前健康检查状态。
     */
    public prop status: HealthStatus {
        get() {
            _status
        }
    }

    /**
     * @brief 返回健康检查附带的数据集合。
     * @return 返回健康检查附带的数据集合。
     */
    public prop data: ReadOnlyMap<String, Object> {
        get() {
            _data
        }
    }

    /**
     * @brief 返回健康检查过程中捕获的异常。
     * @return 返回健康检查过程中捕获的异常；如果未捕获异常则返回 None。
     */
    public prop exception: ?Exception {
        get() {
            _exception
        }
    }

    /**
     * @brief 返回健康检查结果描述。
     * @return 返回健康检查结果描述；如果没有描述则返回 None。
     */
    public prop description: ?String {
        get() {
            _description
        }
    }

    /**
     * @brief 创建一个健康状态的检查结果。
     * @param description 健康检查结果描述。
     * @return 返回健康状态的检查结果。
     */
    public static func healthy(description!: ?String = None): HealthCheckResult {
        HealthCheckResult(HealthStatus.Healthy, description, None, HashMap<String, Object>())
    }

    /**
     * @brief 创建一个带附加数据的健康状态检查结果。
     * @param description 健康检查结果描述。
     * @param data 健康检查附带的数据集合。
     * @return 返回健康状态的检查结果。
     */
    public static func healthy(description!: ?String = None, data!: HashMap<String, Object>): HealthCheckResult {
        HealthCheckResult(HealthStatus.Healthy, description, None, data)
    }

    /**
     * @brief 创建一个降级状态的检查结果。
     * @param description 健康检查结果描述。
     * @param exception 健康检查过程中捕获的异常。
     * @param data 健康检查附带的数据集合。
     * @return 返回降级状态的检查结果。
     */
    public static func degraded(description!: ?String = None, exception!: ?Exception = None,
        data!: HashMap<String, Object>): HealthCheckResult {
        HealthCheckResult(HealthStatus.Degraded, description, exception, data)
    }

    /**
     * @brief 创建一个降级状态的检查结果。
     * @param description 健康检查结果描述。
     * @param exception 健康检查过程中捕获的异常。
     * @return 返回降级状态的检查结果。
     */
    public static func degraded(description!: ?String = None, exception!: ?Exception = None): HealthCheckResult {
        HealthCheckResult(HealthStatus.Degraded, description, exception, HashMap<String, Object>())
    }

    /**
     * @brief 创建一个不健康状态的检查结果。
     * @param description 健康检查结果描述。
     * @param exception 健康检查过程中捕获的异常。
     * @param data 健康检查附带的数据集合。
     * @return 返回不健康状态的检查结果。
     */
    public static func unhealthy(description!: ?String = None, exception!: ?Exception = None,
        data!: HashMap<String, Object>): HealthCheckResult {
        HealthCheckResult(HealthStatus.Unhealthy, description, exception, data)
    }

    /**
     * @brief 创建一个不健康状态的检查结果。
     * @param description 健康检查结果描述。
     * @param exception 健康检查过程中捕获的异常。
     * @return 返回不健康状态的检查结果。
     */
    public static func unhealthy(description!: ?String = None, exception!: ?Exception = None): HealthCheckResult {
        HealthCheckResult(HealthStatus.Unhealthy, description, exception, HashMap<String, Object>())
    }
}

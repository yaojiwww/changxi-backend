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
 * @brief 表示聚合后的健康检查报告。
 */
public class HealthReport {
    private let _status: HealthStatus
    private let _totalDuration: Duration
    private let _entries: ReadOnlyMap<String, HealthReportEntry>

    /**
     * @brief 创建健康检查报告。
     * @param status 聚合后的健康状态。
     * @param totalDuration 全部健康检查的总耗时。
     * @param entries 各健康检查名称对应的报告条目集合。
     */
    public init(status: HealthStatus, totalDuration: Duration, entries: ReadOnlyMap<String, HealthReportEntry>) {
        _status = status
        _totalDuration = totalDuration
        _entries = entries
    }

    /**
     * @brief 根据健康检查条目集合创建健康检查报告。
     * @param entries 各健康检查名称对应的报告条目集合。
     */
    public init(entries: ReadOnlyMap<String, HealthReportEntry>) {
        this(calculateAggregateStatus(entries.values()), calculateTotalDuration(entries.values()), entries)
    }

    /**
     * @brief 返回聚合后的健康状态。
     * @return 返回聚合后的健康状态。
     */
    public prop status: HealthStatus {
        get() {
            _status
        }
    }

    /**
     * @brief 返回全部健康检查的总耗时。
     * @return 返回全部健康检查的总耗时。
     */
    public prop totalDuration: Duration {
        get() {
            _totalDuration
        }
    }

    /**
     * @brief 返回各健康检查名称对应的报告条目集合。
     * @return 返回各健康检查名称对应的报告条目集合。
     */
    public prop entries: ReadOnlyMap<String, HealthReportEntry> {
        get() {
            _entries
        }
    }

    private static func calculateTotalDuration(entries: Iterable<HealthReportEntry>) {
        var totalMilliseconds = 0
        for (entry in entries) {
            totalMilliseconds += entry.duration.toMilliseconds()
        }
        Duration.millisecond * totalMilliseconds
    }

    private static func calculateAggregateStatus(entries: Iterable<HealthReportEntry>) {
        var currentValue = statusToNumber(HealthStatus.Healthy)
        for (entry in entries) {
            let value = statusToNumber(entry.status)
            if (currentValue > value) {
                currentValue = value
                if (currentValue == statusToNumber(HealthStatus.Unhealthy)) {
                    return HealthStatus.Unhealthy
                }
            }
        }
        return numberToStatus(currentValue)
    }

    private static func statusToNumber(status: HealthStatus) {
        return match (status) {
            case HealthStatus.Unhealthy => 0
            case HealthStatus.Degraded => 1
            case HealthStatus.Healthy => 2
        }
    }

    private static func numberToStatus(number: Int64) {
        let status = if (number == 0) {
            HealthStatus.Unhealthy
        } else if (number == 1) {
            HealthStatus.Degraded
        } else {
            HealthStatus.Healthy
        }
        return status
    }
}

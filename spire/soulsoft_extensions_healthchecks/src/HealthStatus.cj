// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_healthchecks

/**
 * @brief 表示健康检查的状态级别。
 */
public enum HealthStatus <: ToString & Hashable & Equatable<HealthStatus> {
    /**
     * @brief 表示健康检查处于不健康状态。
     */
    Unhealthy
    /**
     * @brief 表示健康检查处于降级状态。
     */
    | Degraded
    /**
     * @brief 表示健康检查处于健康状态。
     */
    | Healthy
    /**
     * @brief 返回当前健康状态的字符串表示。
     * @return 返回健康状态名称。
     */
    public func toString(): String {
        match (this) {
            case Unhealthy => "Unhealthy"
            case Degraded => "Degraded"
            case Healthy => "Healthy"
        }
    }

    /**
     * @brief 返回当前健康状态的哈希码。
     * @return 返回对应的哈希码值。
     */
    public func hashCode(): Int64 {
        match (this) {
            case Unhealthy => 0
            case Degraded => 1
            case Healthy => 2
        }
    }

    /**
     * @brief 检查两个健康状态是否相等。
     * @param that 要比较的健康状态。
     * @return 如果两个健康状态相等则返回 true，否则返回 false。
     */
    public operator func ==(that: HealthStatus): Bool {
        match ((this, that)) {
            case (Unhealthy, Unhealthy) => true
            case (Degraded, Degraded) => true
            case (Healthy, Healthy) => true
            case _ => false
        }
    }
}

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_injection

/**
 * @brief 表示服务注册使用的生命周期。
 */
public enum ServiceLifetime <: ToString & Equatable<ServiceLifetime> {
    /**
     * @brief 表示单例生命周期。
     */
    Singleton
    /**
     * @brief 表示作用域生命周期。
     */
    | Scoped
    /**
     * @brief 表示瞬时生命周期。
     */
    | Transient

    /**
     * @brief 检查当前生命周期是否为作用域级。
     * @return 如果当前值为 `Scoped` 则返回 `true`，否则返回 `false`。
     */
    public func isScoped(): Bool {
        match (this) {
            case Scoped => true
            case _ => false
        }
    }

    /**
     * @brief 检查当前生命周期是否为瞬时级。
     * @return 如果当前值为 `Transient` 则返回 `true`，否则返回 `false`。
     */
    public func isTransient(): Bool {
        match (this) {
            case Transient => true
            case _ => false
        }
    }

    /**
     * @brief 检查当前生命周期是否为单例级。
     * @return 如果当前值为 `Singleton` 则返回 `true`，否则返回 `false`。
     */
    public func isSingleton(): Bool {
        match (this) {
            case Singleton => true
            case _ => false
        }
    }

    /**
     * @brief 返回当前生命周期的名称。
     * @return 当前生命周期对应的字符串表示。
     */
    public func toString(): String {
        return match (this) {
            case Singleton => "Singleton"
            case Scoped => "Scoped"
            case Transient => "Transient"
        }
    }

    /**
     * @brief 比较两个生命周期值是否相等。
     * @param that 要比较的另一个生命周期值。
     * @return 如果两个生命周期值相同则返回 `true`，否则返回 `false`。
     */
    public operator func ==(that: ServiceLifetime): Bool {
        return match ((this, that)) {
            case (Singleton, Singleton) => true
            case (Scoped, Scoped) => true
            case (Transient, Transient) => true
            case _ => false
        }
    }
}

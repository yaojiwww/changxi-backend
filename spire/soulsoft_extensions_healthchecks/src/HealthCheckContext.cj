// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_healthchecks

/**
 * @brief 表示健康检查执行时使用的上下文。
 */
public class HealthCheckContext {
    private let _registration: HealthCheckRegistration

    /**
     * @brief 创建健康检查上下文。
     * @param registration 当前要执行的健康检查注册信息。
     */
    public init(registration: HealthCheckRegistration) {
        _registration = registration
    }

    /**
     * @brief 返回当前健康检查的注册信息。
     * @return 返回当前健康检查的注册信息。
     */
    public prop registration: HealthCheckRegistration {
        get() {
            _registration
        }
    }
}

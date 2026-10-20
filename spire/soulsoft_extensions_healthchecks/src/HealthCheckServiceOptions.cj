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
 * @brief 表示健康检查服务的配置选项。
 */
public class HealthCheckServiceOptions {
    private let _registrations = ArrayList<HealthCheckRegistration>()

    /**
     * @brief 返回当前已注册的健康检查集合。
     * @return 返回当前已注册的健康检查集合。
     */
    public prop registrations: List<HealthCheckRegistration> {
        get() {
            _registrations
        }
    }
}

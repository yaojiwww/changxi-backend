// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_healthchecks

import soulsoft_extensions_injection.*

/**
 * @brief 表示单个健康检查的注册信息。
 */
public class HealthCheckRegistration {
    private let _name: String
    private let _timeout: Duration
    private let _tags: Array<String>
    private let _factory: (IServiceProvider) -> IHealthCheck

    /**
     * @brief 创建健康检查注册信息。
     * @param name 健康检查名称。
     * @param timeout 健康检查执行超时时长。
     * @param tags 健康检查关联的标签集合。
     * @param factory 基于服务提供程序创建健康检查实例的工厂。
     */
    public init(name: String, timeout: Duration, tags: Array<String>, factory: (IServiceProvider) -> IHealthCheck) {
        _name = name
        _tags = tags
        _timeout = timeout
        _factory = factory
    }

    /**
     * @brief 返回健康检查名称。
     * @return 返回健康检查名称。
     */
    public prop name: String {
        get() {
            _name
        }
    }

    /**
     * @brief 返回健康检查执行超时时长。
     * @return 返回健康检查执行超时时长。
     */
    public prop timeout: Duration {
        get() {
            _timeout
        }
    }

    /**
     * @brief 返回健康检查关联的标签集合。
     * @return 返回健康检查关联的标签集合。
     */
    public prop tags: Array<String> {
        get() {
            _tags
        }
    }

    /**
     * @brief 返回创建健康检查实例的工厂。
     * @return 返回创建健康检查实例的工厂。
     */
    public prop factory: (IServiceProvider) -> IHealthCheck {
        get() {
            _factory
        }
    }
}

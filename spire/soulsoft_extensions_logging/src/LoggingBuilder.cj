// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_logging

import soulsoft_extensions_injection.*

/**
 * @brief 提供日志系统的配置构建能力。
 */
public class LoggingBuilder {
    private var _services: ServiceCollection

    /**
     * @brief 使用指定服务集合创建日志构建器。
     * @param services 日志相关服务的容器。
     */
    public init(services: ServiceCollection) {
        _services = services
    }

    /**
     * @brief 获取当前绑定的服务集合。
     * @return 返回服务集合。
     */
    public prop services: ServiceCollection {
        get() {
            _services
        }
    }
}

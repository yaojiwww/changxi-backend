// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_hosting

import std.collection.*

/**
 * @brief 定义主机构建器的公共接口。
 */
public interface IHostBuilder {
    /**
     * @brief 返回日志构建器。
     */
    prop logging: LoggingBuilder

    /**
     * @brief 返回服务集合。
     */
    prop services: ServiceCollection

    /**
     * @brief 返回主机环境信息。
     */
    prop environment: IHostEnvironment

    /**
     * @brief 返回构建过程共享的属性集合。
     */
    prop properties: HashMap<String, Any>

    /**
     * @brief 返回主机配置管理器。
     */
    prop configuration: ConfigurationManager
}

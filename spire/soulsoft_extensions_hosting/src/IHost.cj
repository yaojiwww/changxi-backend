// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_hosting

/**
 * @brief 定义主机实例的公共接口。
 */
public interface IHost {
    /**
     * @brief 启动主机并等待其关闭。
     */
    func run(): Unit

    /**
     * @brief 启动主机。
     */
    func start(): Unit

    /**
     * @brief 停止主机。
     */
    func stop(): Unit

    /**
     * @brief 返回主机使用的日志记录器。
     */
    prop logger: ILogger

    /**
     * @brief 返回主机的应用生命周期控制器。
     */
    prop lifetime: IHostApplicationLifetime

    /**
     * @brief 返回主机的服务提供程序。
     */
    prop services: IServiceProvider

    /**
     * @brief 返回主机环境信息。
     */
    prop environment: IHostEnvironment

    /**
     * @brief 返回主机配置对象。
     */
    prop configuration: IConfiguration
}



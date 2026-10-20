// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_web_hosting

protected class HostedServiceExecutor {
    /**
     * @brief 创建一个托管服务执行器。
     * @param services 要统一启动和停止的托管服务集合。
     */
    public HostedServiceExecutor(private let services: Collection<IHostedService>) {
        
    }

    /**
     * @brief 顺序启动所有托管服务。
     */
    public func start(): Unit {
        for (service in services) {
            service.start()
        }
    }

    /**
     * @brief 顺序停止所有托管服务。
     */
    public func stop(): Unit {
        for (service in services) {
            service.stop()
        }
    }
}

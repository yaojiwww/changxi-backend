// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_hosting

/**
 * @brief 定义主机环境信息接口。
 */
public interface IHostEnvironment {
    /**
     * @brief 返回当前环境名称。
     */
    prop environmentName: String

    /**
     * @brief 返回内容根目录路径。
     */
    prop contentRootPath: String

    /**
     * @brief 返回应用程序名称。
     */
    prop applicationName: String
   
    /**
     * @brief 检查当前环境名称是否匹配指定值。
     * @param name 要比较的环境名称。
     * @return 如果当前环境名称匹配则返回 true，否则返回 false。
     */
    func isEnvironment(name: String): Bool {
        environmentName == name
    }
   
    /**
     * @brief 检查当前环境是否为预发布环境。
     * @return 如果当前环境为预发布环境则返回 true，否则返回 false。
     */
    func isStaging(): Bool {
        isEnvironment(Environments.Staging)
    }

    /**
     * @brief 检查当前环境是否为生产环境。
     * @return 如果当前环境为生产环境则返回 true，否则返回 false。
     */
    func isProduction(): Bool {
        isEnvironment(Environments.Production)
    }
   
    /**
     * @brief 检查当前环境是否为开发环境。
     * @return 如果当前环境为开发环境则返回 true，否则返回 false。
     */
    func isDevelopment(): Bool {
        isEnvironment(Environments.Development)
    }
}


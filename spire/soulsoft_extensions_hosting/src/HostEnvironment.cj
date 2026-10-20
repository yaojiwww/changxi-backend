// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_hosting

/**
 * @brief 提供主机环境信息实现。
 */
public class HostEnvironment <: IHostEnvironment {
    private let _environmentName: String
    private let _contentRootPath: String
    private let _applicationName: String
    
    /**
     * @brief 创建主机环境信息实例。
     * @param environmentName 当前环境名称。
     * @param contentRootPath 内容根目录路径。
     * @param applicationName 应用程序名称。
     */
    public init(environmentName: String, contentRootPath: String, applicationName: String) {
        _environmentName = environmentName
        _contentRootPath = contentRootPath
        _applicationName = applicationName
    }
    
    /**
     * @brief 返回当前环境名称。
     * @return 返回当前环境名称。
     */
    public prop environmentName: String {
        get() {
            _environmentName
        }
    }

    /**
     * @brief 返回内容根目录路径。
     * @return 返回内容根目录路径。
     */
    public prop contentRootPath: String {
        get() {
            _contentRootPath
        }
    }

    /**
     * @brief 返回应用程序名称。
     * @return 返回应用程序名称。
     */
    public prop applicationName: String {
        get() {
            _applicationName
        }
    }
}

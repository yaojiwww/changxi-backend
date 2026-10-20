// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_hosting

class WebHostEnvironment <: IWebHostEnvironment {
    private let _webRootPath: String
    private let _hostEnvironment: IHostEnvironment

    /**
     * @brief 创建一个 Web 主机环境实例。
     * @param webRootPath Web 根目录路径。
     * @param hostEnvironment 基础宿主环境信息。
     */
    public init(webRootPath: String, hostEnvironment: IHostEnvironment) {
        _webRootPath = webRootPath
        _hostEnvironment = hostEnvironment
    }

    /**
     * @brief 返回 Web 根目录路径。
     * @return 当前 Web 根目录路径。
     */
    public prop webRootPath: String {
        get() {
            _webRootPath
        }
    }

    /**
     * @brief 返回当前环境名称。
     * @return 当前环境名称。
     */
    public prop environmentName: String {
        get() {
            _hostEnvironment.environmentName
        }
    }

    /**
     * @brief 返回内容根目录路径。
     * @return 当前内容根目录路径。
     */
    public prop contentRootPath: String {
        get() {
            _hostEnvironment.contentRootPath
        }
    }

    /**
     * @brief 返回应用程序名称。
     * @return 当前应用程序名称。
     */
    public prop applicationName: String {
        get() {
            _hostEnvironment.applicationName
        }
    }
}

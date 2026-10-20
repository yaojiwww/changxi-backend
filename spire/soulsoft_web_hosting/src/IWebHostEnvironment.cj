// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_hosting

/**
 * @brief 定义 Web 主机环境信息。
 */
public interface IWebHostEnvironment <: IHostEnvironment {
    /**
     * @brief 返回 Web 根目录路径。
     * @return 当前 Web 根目录路径。
     */
    prop webRootPath: String
}

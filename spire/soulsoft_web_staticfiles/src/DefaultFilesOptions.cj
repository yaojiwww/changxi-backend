// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_staticfiles

import std.collection.*

/**
 * @brief 表示默认文件中间件的配置选项。
 */
public class DefaultFilesOptions <: SharedOptionsBase {
    /**
     * @brief 创建使用独立共享状态的默认文件选项。
     */
    public init() {
        super(SharedOptions())
    }

    /**
     * @brief 使用指定共享状态创建默认文件选项。
     * @param sharedOptions 要共享的选项状态。
     */
    public init(sharedOptions: SharedOptions) {
        super(sharedOptions)
    }

    /**
     * @brief 获取或修改按优先级排序的默认文件名列表。
     */
    public var defaultFileNames: ArrayList<String> = ArrayList<String>(
        ["default.htm", "default.html", "index.htm", "index.html"])
}

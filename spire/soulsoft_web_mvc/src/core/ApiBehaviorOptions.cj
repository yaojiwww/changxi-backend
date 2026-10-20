// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_mvc.core

import soulsoft_web_mvc.abstractions.*

/**
 * @brief 定义 API 行为相关选项。
 */
public class ApiBehaviorOptions {
    /**
     * @brief 表示无效模型状态时的响应工厂。
     */
    public var invalidModelStateResponseFactory: ?(ActionContext) -> IActionResult = None
}

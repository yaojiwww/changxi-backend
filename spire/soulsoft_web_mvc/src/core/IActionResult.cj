// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_web_mvc.core

import soulsoft_web_http.*

/**
 * @brief 定义可写入 HTTP 响应的动作结果。
 */
public interface IActionResult {
    /**
     * @brief 将当前结果写入 HTTP 响应。
     * @param context 当前请求的 HTTP 上下文。
     */
    func invoke(context: HttpContext): Unit
}

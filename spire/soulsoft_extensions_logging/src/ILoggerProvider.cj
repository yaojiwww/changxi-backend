// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_logging

/**
 * @brief 定义日志提供程序的公共接口。
 */
public interface ILoggerProvider <: Resource {
    /**
     * @brief 按分类名称创建日志记录器。
     * @param categoryName 日志分类名称。
     * @return 返回创建得到的日志记录器。
     */
    func createLogger(categoryName: String): ILogger
}

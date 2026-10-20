// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_logging

import std.reflect.*

/**
 * @brief 定义日志记录器工厂的公共接口。
 */
public interface ILoggerFactory <: Resource {
    /**
     * @brief 按泛型类型创建日志记录器。
     * @return 返回创建得到的日志记录器。
     */
    func createLogger<T>(): ILogger {
        createLogger(TypeInfo.of<T>().qualifiedName)
    }

    /**
     * @brief 按分类名称创建日志记录器。
     * @param categoryName 日志分类名称。
     * @return 返回创建得到的日志记录器。
     */
    func createLogger(categoryName: String): ILogger

    /**
     * @brief 在工厂运行时动态添加日志提供程序。
     * @param provider 要添加的日志提供程序。
     * @throws UnsupportedException 当日志记录器工厂已关闭时抛出。
     */
    func addProvider(provider: ILoggerProvider): Unit
}

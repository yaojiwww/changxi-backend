// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_web_mvc.formatters

/**
 * @brief 定义输出格式化器接口。
 */
public interface IOutputFormatter {
    /**
     * @brief 检查当前格式化器是否可以写出指定结果。
     * @param context 输出格式化检查上下文。
     * @return 如果当前格式化器可以写出该结果则返回 `true`。
     */
    func canWrite(context: OutputFormatterCanWriteContext): Bool
    /**
     * @brief 将结果写入 HTTP 响应。
     * @param context 输出格式化上下文。
     */
    func write(context: OutputFormatterContext): Unit
}

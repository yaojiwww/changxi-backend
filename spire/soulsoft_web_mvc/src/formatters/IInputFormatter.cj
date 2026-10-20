// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_web_mvc.formatters

/**
 * @brief 定义输入格式化器接口。
 */
public interface IInputFormatter {
    /**
     * @brief 检查当前格式化器是否可以读取指定输入。
     * @param context 输入格式化上下文。
     * @return 如果当前格式化器可以读取该输入则返回 `true`。
     */
    func canRead(context: InputFormatterContext): Bool
    /**
     * @brief 读取输入并返回格式化结果。
     * @param context 输入格式化上下文。
     * @return 输入格式化结果。
     */
    func read(context: InputFormatterContext): InputFormatterResult
}

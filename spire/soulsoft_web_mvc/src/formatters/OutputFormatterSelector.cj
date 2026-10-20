// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_mvc.formatters

import std.collection.*

/**
 * @brief 定义输出格式化器选择器基类。
 */
public abstract class OutputFormatterSelector {
    /**
     * @brief 从候选格式化器中选择可用的输出格式化器。
     * @param context 输出格式化检查上下文。
     * @param formatters 候选输出格式化器集合。
     * @param contentTypes 候选内容类型集合。
     * @return 选中的输出格式化器；如果没有匹配项则返回 `None`。
     */
    public func selectFormatter(context: OutputFormatterCanWriteContext, formatters: List<IOutputFormatter>,
        contentTypes: List<String>): ?IOutputFormatter
}

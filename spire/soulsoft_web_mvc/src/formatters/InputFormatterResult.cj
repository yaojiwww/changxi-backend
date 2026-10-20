// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_web_mvc.formatters

/**
 * @brief 表示输入格式化结果。
 */
public struct InputFormatterResult {
    private let _model: ?Any

    private init(model: ?Any) {
        _model = model
    }

    /**
     * @brief 返回格式化得到的模型值。
     * @return 格式化结果中的模型值；如果格式化失败则返回 `None`。
     */
    public prop model: ?Any {
        get() {
            _model
        }
    }

    /**
     * @brief 创建失败的输入格式化结果。
     * @return 不包含模型值的输入格式化结果。
     */
    public static func failure(): InputFormatterResult {
        InputFormatterResult(None)
    }

    /**
     * @brief 创建成功的输入格式化结果。
     * @param model 格式化得到的模型值。
     * @return 包含指定模型值的输入格式化结果。
     */
    public static func success(model: ?Any): InputFormatterResult {
        InputFormatterResult(model)
    }
}

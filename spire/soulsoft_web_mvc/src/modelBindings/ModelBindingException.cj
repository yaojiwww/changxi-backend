
// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_mvc.modelBindings

/**
 * @brief 表示模型绑定阶段抛出的异常。
 */
public class ModelBindingException <: Exception {
    /**
     * @brief 创建模型绑定异常实例。
     * @param message 异常消息。
     */
    public init(message: String) {
        super(message)
    }

    /**
     * @brief 返回当前异常的类型名称。
     * @return 当前异常的类型名称字符串。
     */
    public override func getClassName(): String {
        "ModelBindingException"
    }
}

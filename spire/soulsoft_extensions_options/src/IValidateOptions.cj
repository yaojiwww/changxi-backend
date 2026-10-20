// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_extensions_options

/**
 * @brief 定义验证选项实例的接口。
 */
public interface IValidateOptions<TOptions> where TOptions <: Object {
    /**
     * @brief 验证指定名称的选项实例。
     * @param name 选项名称。
     * @param options 待验证的选项实例。
     * @return 返回验证结果。
     */
    func validate(name: ?String, options: TOptions): ValidateOptionsResult
}

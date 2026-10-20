// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_options

import soulsoft_extensions_injection.*

/**
 * @brief 提供基于委托的选项验证实现。
 */
public class ValidateOptions<TOptions> <: IValidateOptions<TOptions> where TOptions <: Object {
    /**
     * @brief 创建选项验证实例。
     * @param name 需要匹配的选项名称；为空时表示匹配所有名称。
     * @param services 验证时使用的服务提供程序。
     * @param validation 实际执行验证的委托。
     * @param failureMessage 验证失败时返回的消息。
     */
    ValidateOptions(private let name: ?String, private let services: IServiceProvider,
        public let validation: (TOptions, IServiceProvider) -> Bool, private let failureMessage: String) {
    }

    /**
     * @brief 验证指定名称的选项实例。
     * @param name 当前选项名称。
     * @param options 需要验证的选项实例。
     * @return 返回验证结果。
     */
    public func validate(name: ?String, options: TOptions): ValidateOptionsResult {
        if (this.name.isNone() || this.name == name) {
            if (validation(options, services)) {
                return ValidateOptionsResult.success
            }
            return ValidateOptionsResult.fail(failureMessage)
        }

        return ValidateOptionsResult.skip
    }
}

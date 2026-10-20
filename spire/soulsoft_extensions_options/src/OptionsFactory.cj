// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_options

import std.reflect.*
import std.collection.*

/**
 * @brief 提供选项实例创建、配置与验证实现。
 */
public class OptionsFactory<TOptions> <: IOptionsFactory<TOptions> where TOptions <: Object {
    private let _configures: Collection<IConfigureOptions<TOptions>>
    private let _validations: Collection<IValidateOptions<TOptions>>
    private let _configureAfters: Collection<IConfigureAfterOptions<TOptions>>

    /**
     * @brief 创建选项工厂实例。
     * @param configures 选项配置器集合。
     * @param configureAfters 选项后置配置器集合。
     * @param validations 选项验证器集合。
     */
    public init(configures: Collection<IConfigureOptions<TOptions>>,
        configureAfters: Collection<IConfigureAfterOptions<TOptions>>, validations: Collection<IValidateOptions<TOptions>>) {
        _configures = configures
        _configureAfters = configureAfters
        _validations = validations
    }

    /**
     * @brief 按名称创建并验证选项实例。
     * @param name 选项名称。
     * @return 返回创建得到的选项实例。
     * @throws OptionsValidationException 当选项验证失败时抛出。
     * @throws UnsupportedException 当无法创建选项实例时抛出。
     */
    public func create(name: String): TOptions {
        let options = createInstance()
        for (pattern in _configures) {
            if (let configureNamed: IConfigureNamedOptions<TOptions> <- pattern) {
                configureNamed.configure(name, options)
            } else {
                pattern.configure(options)
            }
        }

        for (pattern in _configureAfters) {
            pattern.configureAfter(name, options)
        }

        if (_validations.size > 0) {
            let failures = ArrayList<String>()
            for (validate in _validations) {
                let result = validate.validate(name, options)
                if (result.failed) {
                    failures.add(all: result.failures.getOrThrow() |> collectArray)
                }
            }
            if (failures.size > 0) {
                throw OptionsValidationException(name, TypeInfo.of<TOptions>(), failures |> collectArray)
            }
        }
        return options
    }

    private func createInstance(): TOptions {
        return (ClassTypeInfo.of<TOptions>().construct() as TOptions) ??
            throw UnsupportedException("Failed to create instance of ${TypeInfo.of<TOptions>().name}: ensure it has a public parameterless constructor.")
    }
}

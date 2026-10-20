// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_options

import std.reflect.*
import soulsoft_extensions_injection.*

internal let DefaultValidationFailureMessage = "A validation error has occurred."

/**
 * @brief 提供命名选项的配置与验证构建能力。
 */
public class OptionsBuilder<TOptions> where TOptions <: Object {
    private let _name: String
    private let _services: ServiceCollection

    public init(name: String, services: ServiceCollection) {
        _name = name
        _services = services
    }

    /**
     * @brief 配置选项实例。
     * @param configureOptions 用于配置选项实例的回调。
     * @return 返回当前选项构建器，便于继续链式配置。
     */
    public func configure(configureOptions: (TOptions) -> Unit): OptionsBuilder<TOptions> {
        configure {
            options, _ => configureOptions(options)
        }
        return this
    }

    /**
     * @brief 配置选项实例并访问服务提供程序。
     * @param configureOptions 用于配置选项实例的回调。
     * @return 返回当前选项构建器，便于继续链式配置。
     */
    public func configure(configureOptions: (TOptions, IServiceProvider) -> Unit): OptionsBuilder<TOptions> {
        _services.configure(_name, configureOptions)
        return this
    }

    /**
     * @brief 在基础配置之后追加配置。
     * @param configureOptions 用于追加配置选项实例的回调。
     * @return 返回当前选项构建器，便于继续链式配置。
     */
    public func configureAfter(configureOptions: (TOptions) -> Unit): OptionsBuilder<TOptions> {
        configureAfter {
            options, _ => configureOptions(options)
        }
        return this
    }

    /**
     * @brief 在基础配置之后追加配置并访问服务提供程序。
     * @param configureOptions 用于追加配置选项实例的回调。
     * @return 返回当前选项构建器，便于继续链式配置。
     */
    public func configureAfter(configureOptions: (TOptions, IServiceProvider) -> Unit): OptionsBuilder<TOptions> {
        _services.configureAfter(_name, configureOptions)
        return this
    }

    /**
     * @brief 添加一个使用默认失败消息的验证规则。
     * @param validation 用于验证选项实例的回调。
     * @return 返回当前选项构建器，便于继续链式配置。
     */
    public func validate(validation: (TOptions) -> Bool): OptionsBuilder<TOptions> {
        return validate(DefaultValidationFailureMessage) {
            options => validation(options)
        }
    }

    /**
     * @brief 添加一个自定义失败消息的验证规则。
     * @param failureMessage 验证失败时使用的消息。
     * @param validation 用于验证选项实例的回调。
     * @return 返回当前选项构建器，便于继续链式配置。
     */
    public func validate(failureMessage: String, validation: (TOptions) -> Bool): OptionsBuilder<TOptions> {
        validate(failureMessage) {
            options, _ => validation(options)
        }
        return this
    }

    /**
     * @brief 添加一个可访问服务提供程序的验证规则。
     * @param validation 用于验证选项实例的回调。
     * @return 返回当前选项构建器，便于继续链式配置。
     */
    public func validate(validation: (TOptions, IServiceProvider) -> Bool): OptionsBuilder<TOptions> {
        return validate(DefaultValidationFailureMessage, validation)
    }

    /**
     * @brief 添加一个可访问服务提供程序且带自定义失败消息的验证规则。
     * @param failureMessage 验证失败时使用的消息。
     * @param validation 用于验证选项实例的回调。
     * @return 返回当前选项构建器，便于继续链式配置。
     */
    public func validate(failureMessage: String, validation: (TOptions, IServiceProvider) -> Bool): OptionsBuilder<TOptions> {
        _services.addSingleton<IValidateOptions<TOptions>, ValidateOptions<TOptions>> {
            sp => ValidateOptions<TOptions>(_name, sp, validation, failureMessage)
        }
        return this
    }

    /**
     * @brief 注册启动阶段验证当前选项的行为。
     * @return 返回当前选项构建器，便于继续链式配置。
     */
    public func validateOnStart(): OptionsBuilder<TOptions> {
        _services.tryAddTransient<IStartupValidator> {
            sp => StartupValidator(sp.getOrThrow<IOptions<StartupValidatorOptions>>())
        }
        _services.configure<StartupValidatorOptions>() {
            vo, sp =>
                let options = sp.getOrThrow<IOptionsMonitor<TOptions>>()
                vo.validators.add((TypeInfo.of<TOptions>(), _name, {
                        => options.get(_name)
                    }))
        }
        return this
    }
}

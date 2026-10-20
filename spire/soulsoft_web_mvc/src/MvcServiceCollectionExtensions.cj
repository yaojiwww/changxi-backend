// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_mvc

import std.reflect.*
import std.collection.*
import soulsoft_web_routing.*
import soulsoft_web_mvc.routing.*
import soulsoft_extensions_options.*
import soulsoft_web_mvc.formatters.*
import soulsoft_web_mvc.controllers.*
import soulsoft_extensions_injection.*
import soulsoft_web_mvc.modelBindings.*
import soulsoft_web_mvc.infrastructure.*
import soulsoft_web_mvc.applicationModels.*

/**
 * @brief 提供 MVC 服务注册扩展。
 */
public interface MvcServiceCollectionExtensions {
    /**
     * @brief 注册 MVC 控制器相关服务。
     * @return MVC 构建器实例。
     */
    func addControllers(): MvcBuilder {
        addControllers({_ =>})
    }
    /**
     * @brief 注册 MVC 控制器相关服务并添加指定应用程序部件。
     * @param packageName 要加载的包名称。
     * @return MVC 构建器实例。
     */
    func addControllers(packageName: String): MvcBuilder
    /**
     * @brief 注册 MVC 控制器相关服务并配置 MVC 选项。
     * @param configureOptions 用于修改 MVC 选项的回调。
     * @return MVC 构建器实例。
     */
    func addControllers(configureOptions: (MvcOptions) -> Unit): MvcBuilder
}

extend ServiceCollection <: MvcServiceCollectionExtensions {
    /**
     * @brief 注册 MVC 控制器相关服务并配置 MVC 选项。
     * @param configureOptions 用于修改 MVC 选项的回调。
     * @return MVC 构建器实例。
     */
    public func addControllers(configureOptions: (MvcOptions) -> Unit): MvcBuilder {
        let builder = this.addMvcCore(configureOptions)
        return builder
    }

    /**
     * @brief 注册 MVC 控制器相关服务并添加指定应用程序部件。
     * @param packageName 要加载的包名称。
     * @return MVC 构建器实例。
     */
    public func addControllers(packageName: String): MvcBuilder {
        return addControllers().addApplicationPart(packageName)
    }

    private func addMvcCore(configureOptions: (MvcOptions) -> Unit) {
        let partManager = getApplicationPartManager()
        this.addOptions<MvcOptions>()
        this.addSingleton<IConfigureOptions<MvcOptions>, MvcOptionsSetup>()
        this.configure<MvcOptions>(configureOptions)
        this.addOptions<ApiBehaviorOptions>()
        tryAddSingleton<ApplicationPartManager>(partManager)
        configureDefaultFeatureProviders(partManager)
        configureDefaultServices()
        addMvcCoreServices()
        return MvcBuilder(this, partManager)
    }

    private func getApplicationPartManager() {
        let service = this.iterator().filter {f => f.serviceType == TypeInfo.of<ApplicationPartManager>()}.first()
        if (let Some(serviceDescriptor) <- service) {
            if (let Some(instance) <- serviceDescriptor
                .implementationInstance
                .flatMap {f => f as ApplicationPartManager}) {
                return instance
            }
        }
        return ApplicationPartManager()
    }

    private func configureDefaultFeatureProviders(partManager: ApplicationPartManager) {
        if (!(partManager.featureProviders |> any {a => a is ControllerFeatureProvider})) {
            partManager.featureProviders.add(DefaultControllerFeatureProvider(TypeInfo.of<Controller>()))
        }
    }

    private func configureDefaultServices() {
        addRouting()
    }

    private func addMvcCoreServices() {
        //binding
        this.tryAddSingleton<IModelBinderFactory, ModelBinderFactory>()
        this.tryAddSingleton<IActionModelBinder, DefaultActionModelBinder>()
        //controller
        this.tryAddSingleton<ActionEndpointFactory, ActionEndpointFactory>()
        this.tryAddSingleton<IRequestDelegateFactory, ControllerRequestDelegateFactory>()
        this.tryAddSingleton<OutputFormatterSelector, DefaultOutputFormatterSelector>()
        this.tryAddSingleton<IActionDescriptorCollectionProvider, DefaultActionDescriptorCollectionProvider>()
    }
}

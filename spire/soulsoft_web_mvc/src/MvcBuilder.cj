// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_mvc

import std.reflect.*
import soulsoft_extensions_options.*
import soulsoft_extensions_injection.*
import soulsoft_web_mvc.applicationModels.*

/**
 * @brief 提供 MVC 服务和应用程序部件的链式配置入口。
 */
public class MvcBuilder {
    private let _services: ServiceCollection
    private let _partManager: ApplicationPartManager

    init(services: ServiceCollection, partManager: ApplicationPartManager) {
        _services = services
        _partManager = partManager
    }

    /**
     * @brief 返回当前 MVC 构建器使用的服务集合。
     * @return 当前绑定的服务集合。
     */
    public prop services: ServiceCollection {
        get() {
            _services
        }
    }

    /**
     * @brief 返回当前 MVC 构建器使用的应用程序部件管理器。
     * @return 当前绑定的应用程序部件管理器。
     */
    public prop partManager: ApplicationPartManager {
        get() {
            _partManager
        }
    }

    /**
     * @brief 配置 MVC 运行时选项。
     * @param configureOptions 用于修改 MVC 选项的回调。
     * @return 当前 MVC 构建器实例。
     */
    public func addMvcOptions(configureOptions: (MvcOptions) -> Unit): MvcBuilder {
        _services.configure(configureOptions)
        return this
    }
}

extend MvcBuilder {
    /**
     * @brief 按限定包名注册应用程序部件。
     * @param qualifiedName 要注册的包限定名。
     * @return 当前 MVC 构建器实例。
     */
    public func addApplicationPart(qualifiedName: String): MvcBuilder {
        let packageInfo = PackageInfo.get(qualifiedName)
        addApplicationPart(packageInfo)
        return this
    }

    /**
     * @brief 注册指定的程序集部件。
     * @param part 要添加的程序集部件。
     * @return 当前 MVC 构建器实例。
     */
    public func addApplicationPart(part: AssemblyPart): MvcBuilder {
        partManager.parts.add(part)
        return this
    }

    /**
     * @brief 根据包信息创建并注册程序集部件。
     * @param packageInfo 用于创建程序集部件的包信息。
     * @return 当前 MVC 构建器实例。
     */
    public func addApplicationPart(packageInfo: PackageInfo): MvcBuilder {
        partManager.parts.add(AssemblyPart(packageInfo.name, packageInfo.typeInfos))
        return this
    }

    /**
     * @brief 配置应用程序部件管理器。
     * @param configureOptions 用于修改应用程序部件管理器的回调。
     * @return 当前 MVC 构建器实例。
     */
    public func configureApplicationPartManager(configureOptions: (ApplicationPartManager) -> Unit): MvcBuilder {
        configureOptions(partManager)
        return this
    }
}

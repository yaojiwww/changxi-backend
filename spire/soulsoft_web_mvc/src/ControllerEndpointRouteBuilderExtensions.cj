// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_mvc

import std.collection.*
import soulsoft_web_routing.*
import soulsoft_web_mvc.routing.*
import soulsoft_web_mvc.routing.*
import soulsoft_extensions_injection.*
import soulsoft_web_mvc.applicationModels.*

/**
 * @brief 提供基于控制器的路由映射扩展。
 */
public interface ControllerEndpointRouteBuilderExtensions {
    /**
     * @brief 映射特性路由控制器端点。
     * @return 控制器动作端点约定构建器。
     */
    func mapControllers(): ControllerActionEndpointConventionBuilder
    /**
     * @brief 映射约定路由控制器端点。
     * @param name 路由名称。
     * @param pattern 路由模板。
     * @return 控制器动作端点约定构建器。
     */
    func mapControllerRoute(name!: String, pattern!: String): ControllerActionEndpointConventionBuilder
}

extend EndpointRouteBuilder <: ControllerEndpointRouteBuilderExtensions {
    /**
     * @brief 映射约定路由控制器端点。
     * @param name 路由名称。
     * @param pattern 路由模板。
     * @return 控制器动作端点约定构建器。
     */
    public func mapControllerRoute(name!: String, pattern!: String): ControllerActionEndpointConventionBuilder {
        let dataSource = getOrCreateEndpointDataSource(this)
        return dataSource.addRoute(name, pattern)
    }

    /**
     * @brief 映射特性路由控制器端点。
     * @return 控制器动作端点约定构建器。
     */
    public func mapControllers(): ControllerActionEndpointConventionBuilder {
        verifyMvcServicesAreRegistered()
        let dataSource = getOrCreateEndpointDataSource(this)
        return dataSource.defaultBuilder
    }

    private func getOrCreateEndpointDataSource(endpoints: EndpointRouteBuilder): ControllerActionEndpointDataSource {
        for (pattern in dataSources) {
            if (let dataSources: ControllerActionEndpointDataSource <- pattern) {
                return dataSources
            }
        }
        let dataSource = ActivatorUtilities.createInstance<ControllerActionEndpointDataSource>(this.services)
        endpoints.dataSources.add(dataSource)
        return dataSource
    }

    private func verifyMvcServicesAreRegistered() {
        let callSiteFactory = this.services.getOrThrow<IServiceProviderIsService>()
        if (!callSiteFactory.isService<ApplicationPartManager>()) {
            throw Exception(
                "Unable to find the required services. Please add all the required services by calling 'ServiceCollection.addControllers' inside the call to 'configureServices(...)' in the application startup code.")
        }
    }
}

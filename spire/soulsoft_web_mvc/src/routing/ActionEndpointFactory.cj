// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_mvc.routing

import std.collection.*
import soulsoft_web_http.*
import soulsoft_web_routing.*
import soulsoft_web_routing.http.*
import soulsoft_web_mvc.controllers.*
import soulsoft_web_routing.patterns.*
import soulsoft_web_mvc.abstractions.*
import soulsoft_extensions_injection.*

/**
 * 负责将 ControllerActionDescriptor 转换为路由 Endpoint 列表。
 *
 * 根据 action 上是否存在路由注解，分两条路径处理：
 *   - ApiController 路径：action 注解驱动（@HttpGet/@HttpPost 等），每个路由注解生成独立 Endpoint
 *   - MvcController 路径：全局约定路由驱动，每条约定路由生成一个 Endpoint
 */
protected class ActionEndpointFactory {
    private let _services: IServiceProvider
    private let _requestDelegateFactory: IRequestDelegateFactory

    /**
     * @brief 创建控制器动作端点工厂实例。
     * @param services 当前应用的服务提供器。
     * @param requestDelegateFactory 用于创建请求委托的工厂。
     */
    public init(services: IServiceProvider, requestDelegateFactory: IRequestDelegateFactory) {
        _services = services
        _requestDelegateFactory = requestDelegateFactory
    }

    /**
     * 入口：根据是否为 ApiController 选择注册策略。
     *
     * 判断依据：action 上是否存在实现了 IRouteTemplateProvider 的注解（如 @HttpGet/@Route）。
     */
    internal func addEndpoints(endpoints: List<Endpoint>, actionDescriptor: ControllerActionDescriptor,
        routes: ReadOnlyList<ConventionalRouteEntry>, conventions: ArrayList<(EndpointBuilder) -> Unit>) {
        if (isApiController(actionDescriptor)) {
            applyApiController(endpoints, actionDescriptor, conventions)
        } else {
            applyMvcController(endpoints, routes, actionDescriptor, conventions)
        }
    }

    /**
     * MvcController 路径：遍历全局约定路由，每条路由结合 actionDescriptor.routeValues 生成一个 Endpoint。
     *
     * 不处理 HTTP 方法约束，HTTP 方法过滤由约定路由自身或其他中间件负责。
     */
    private func applyMvcController(endpoints: List<Endpoint>, routes: ReadOnlyList<ConventionalRouteEntry>,
        actionDescriptor: ControllerActionDescriptor, conventions: ArrayList<(EndpointBuilder) -> Unit>) {
        for (route in routes) {
            let pattern = RoutePatternFactory.parse(route.template, actionDescriptor.routeValues)
            let endpointBuilder = createEndpointBuilder(pattern, actionDescriptor, conventions)
            endpoints.add(endpointBuilder.build())
        }
    }

    /**
     * 判断是否为 ApiController：action 上存在至少一个路由模板注解即视为 ApiController。
     *
     * 注意：以 action 注解为准而非 controller 类型注解，确保判断粒度精确到方法级别。
     */
    private func isApiController(actionDescriptor: ControllerActionDescriptor) {
        return actionDescriptor.actionFunction.annotations |> any {f => f is IRouteTemplateProvider}
    }

    /**
     * ApiController 路径：遍历 action 上所有注解，每个携带路由模板的注解生成独立 Endpoint。
     *
     * 路由模板拼接规则：
     *   1. controller 类上存在路由模板（如 @Route["[controller]"]）且 action 模板不以 '/' 开头
     *      → 拼接为 "{controllerTemplate}/{actionTemplate}"
     *   2. action 模板以 '/' 开头，或 controller 无路由模板
     *      → 直接使用 action 模板（绝对路径，忽略 controller 前缀）
     *
     * HTTP 方法约束：
     *   若同一注解同时实现了 IActionHttpMethodProvider（如 @HttpGet/@HttpPost），
     *   则向该 Endpoint 附加 HttpMethodMetadata，用于路由匹配时的 HTTP 方法过滤。
     *   纯路由注解（如 @Route）不附加 HTTP 方法约束，接受所有方法。
     *
     * 变量命名注意：循环变量使用 annotation 而非 pattern，避免与后续字符串模板变量遮盖。
     */
    private func applyApiController(endpoints: List<Endpoint>, actionDescriptor: ControllerActionDescriptor,
        conventions: ArrayList<(EndpointBuilder) -> Unit>) {
        /** 取 controller 类上第一个路由模板作为前缀，若无则为 None。 */
        let controllerTemplate = actionDescriptor.controllerType.annotations |>
            filterMap {f => f as IRouteTemplateProvider} |> filterMap {f => f.template} |> first
        for (annotation in actionDescriptor.actionFunction.annotations) {
            /** 仅处理携带路由模板的注解；不携带模板的注解（如 @Authorize）跳过。 */
            if (let routeProvider: IRouteTemplateProvider <- annotation && let Some(actionTemplate) <- routeProvider
                .template) {
                /** 决策：action 模板以 '/' 开头则使用绝对路径，否则拼接 controller 前缀。 */
                let template = if (let Some(controllerTemplate) <- controllerTemplate && !actionTemplate.startsWith('/')) {
                    "${controllerTemplate}/${actionTemplate}"
                } else {
                    actionTemplate
                }
                /** 替换模板中的占位符（[controller]、[action]）并统一转小写。 */
                let resolvedTemplate = replaceTemplateConstants(template, actionDescriptor)
                let endpointBuilder = createEndpointBuilder(resolvedTemplate, actionDescriptor, conventions)
                /**
                 * 若同一注解实现了 IActionHttpMethodProvider，附加 HTTP 方法元数据。
                 * 注意：必须对 annotation（注解对象）做类型匹配，而非对 resolvedTemplate（字符串）。
                 */
                if (let httpMethodProvider: IActionHttpMethodProvider <- annotation) {
                    endpointBuilder.metadata.add(HttpMethodMetadata(httpMethodProvider.httpMethods))
                }
                endpoints.add(endpointBuilder.build())
            }
        }
    }

    /**
     * 重载1：接受已解析的 RoutePattern，附加 actionDescriptor 元数据并应用所有约定。
     *
     * 所有 createEndpointBuilder 重载最终都汇聚到此方法。
     *   - actionDescriptor：供中间件/过滤器通过元数据反查 action 信息
     *   - endpointMetadata：action 上声明的附加元数据（如授权策略、响应缓存等）
     */
    private func createEndpointBuilder(routePattern: RoutePattern, actionDescriptor: ControllerActionDescriptor,
        conventions: ArrayList<(EndpointBuilder) -> Unit>) {
        let requestDelegate = _requestDelegateFactory.createRequestDelegate(actionDescriptor)
        let builder = RouteEndpointBuilder(routePattern, requestDelegate, _services)
        builder.metadata.add(actionDescriptor)
        builder.metadata.add(all: actionDescriptor.endpointMetadata)
        for (convention in conventions) {
            convention(builder)
        }
        return builder
    }

    /**
     * 重载2：接受模板字符串，解析为 RoutePattern 后委托给重载1。
     */
    private func createEndpointBuilder(pattern: String, actionDescriptor: ControllerActionDescriptor,
        conventions: ArrayList<(EndpointBuilder) -> Unit>) {
        // 转小写是因为cangjie的hashmap不支持忽略大小写的hashmap
        let routePattern = RoutePatternFactory.parse(pattern.toAsciiLower())
        routePattern.displayText = pattern
        return createEndpointBuilder(routePattern, actionDescriptor, conventions)
    }

    /**
     * 将模板中的 [controller]、[action] 占位符替换为实际名称，仅将首字母转小写。
     *
     * 示例："/[controller]/[action]" → "/Hello/index"（首字母小写 → "/hello/Index"）
     */
    private func replaceTemplateConstants(pattern: String, actionDescriptor: ControllerActionDescriptor) {
        let controllerName = actionDescriptor.controllerName
        let actionName = actionDescriptor.actionName      
        return pattern
            .replace("[controller]", controllerName)
            .replace("[action]", actionName)
            .trimStart('/')
            .trimEnd('/')
    }
}

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_web_routing

/**
 * @brief 定义路由中间件使用的属性键常量。
 */
public class RoutingConstants {
    // 由 hosting 基础设施预置的全局构建器（外部注入，可选）
    /**
     * @brief 表示全局端点路由构建器的属性键。
     */
    public static const GlobalEndpointRouteBuilderKey = "__GlobalEndpointRouteBuilder"
    // 由 useRouting() 设置、供 useEndpoints() 读取的本地构建器
    /**
     * @brief 表示局部端点路由构建器的属性键。
     */
    public static const EndpointRouteBuilderKey = "__EndpointRouteBuilder"
    /**
     * @brief 表示是否已启用路由匹配中间件的属性键。
     */
    public static const UseRoutingKey = "__UseRouting"
    /**
     * @brief 表示是否已启用端点执行中间件的属性键。
     */
    public static const UseEndpointsKey = "__UseEndpoints"
}

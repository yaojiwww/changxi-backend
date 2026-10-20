// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_web_healthchecks

import std.collection.*

/**
 * @brief 表示健康检查中间件和终结点使用的选项集合。
 */
public class HealthCheckOptions {
    /**
     * @brief 保存不同健康状态对应的响应状态码映射。
     */
    public var resultStatusCodes: HashMap<HealthStatus, UInt16>

    /**
     * @brief 创建一个带默认状态码映射的健康检查选项实例。
     */
    public init() {
        resultStatusCodes = HashMap<HealthStatus, UInt16>(
            [(HealthStatus.Healthy, UInt16(StatusCodes.Ok)), (HealthStatus.Degraded, UInt16(StatusCodes.Ok)),
                (HealthStatus.Unhealthy, UInt16(StatusCodes.ServiceUnavailable))])
    }
    
    /**
     * @brief 指示健康检查响应是否允许被缓存。
     */
    public var allowCachingResponses = false

    /**
     * @brief 定义用于筛选要执行的健康检查注册项的条件。
     */
    public var predicate: (HealthCheckRegistration) -> Bool = {
        _ => true
    }

    /**
     * @brief 定义将健康检查结果写入 HTTP 响应的回调。
     */
    public var responseWriter: (HttpContext, HealthReport) -> Unit = {
        context, report =>
            context.response.contentType = "text/plain"
            context.response.write(report.status.toString())
    }
}

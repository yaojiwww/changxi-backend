// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_openapi.transformers

import soulsoft_web_mvc.controllers.*
import soulsoft_extensions_injection.*

/**
 * @brief 提供操作转换器执行时的上下文信息。
 */
public class OpenApiOperationTransformerContext {
    /**
     * @brief 当前正在生成的文档名称。
     */
    public let documentName: String
    /**
     * @brief 请求作用域的服务提供器。
     */
    public let services: IServiceProvider
    /**
     * @brief 当前操作关联的控制器动作描述。
     */
    public let description: ?ControllerActionDescriptor

    /**
     * @brief 创建操作转换器上下文实例。
     * @param services 请求作用域的服务提供器。
     * @param documentName 当前正在生成的文档名称。
     * @param description 当前操作关联的控制器动作描述。
     */
    public init(services: IServiceProvider, documentName: String, description: ?ControllerActionDescriptor) {
        this.services = services
        this.documentName = documentName
        this.description = description
    }
}

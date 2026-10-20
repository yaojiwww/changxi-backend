// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_extensions_http

/**
 * @brief 定义 HTTP 消息处理器构建过滤器接口。
 */
public interface IHttpMessageHandlerBuilderFilter {
    /**
     * @brief 包装下一个消息处理器构建步骤。
     * @param next 下一个消息处理器构建步骤。
     * @return 返回包装后的消息处理器构建步骤。
     */
    func configure(next: (HttpMessageHandlerBuilder) -> Unit): (HttpMessageHandlerBuilder) -> Unit
}

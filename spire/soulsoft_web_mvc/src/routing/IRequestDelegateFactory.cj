// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_web_mvc.routing

import soulsoft_web_http.*
import soulsoft_web_mvc.controllers.*

/**
 * @brief 定义请求委托工厂接口。
 */
public interface IRequestDelegateFactory {
    /**
     * @brief 为控制器动作描述符创建请求委托。
     * @param actionDescriptor 要执行的控制器动作描述符。
     * @return 处理该动作的请求委托。
     */
    func createRequestDelegate(actionDescriptor: ControllerActionDescriptor): RequestDelegate
}

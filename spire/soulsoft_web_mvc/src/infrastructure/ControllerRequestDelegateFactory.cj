// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_mvc.infrastructure

import std.reflect.*
import std.collection.*
import soulsoft_web_http.*
import soulsoft_web_mvc.core.*
import soulsoft_serialization.*
import soulsoft_web_mvc.routing.*
import soulsoft_extensions_options.*
import soulsoft_web_mvc.controllers.*
import soulsoft_web_mvc.abstractions.*
import soulsoft_extensions_injection.*
import soulsoft_web_mvc.modelBindings.*

/**
 * @brief 负责将 ControllerActionDescriptor 转换为 RequestDelegate。
 * @description 每次路由匹配后，框架调用 createRequestDelegate 获得委托，再由该委托驱动 ControllerActionInvoker 完成请求。
 */
protected class ControllerRequestDelegateFactory <: IRequestDelegateFactory {
    private let _mvcOptions: MvcOptions
    private let _modelBinder: IActionModelBinder

    /**
     * @brief 创建控制器请求委托工厂实例。
     * @param mvcOptions MVC 选项访问器。
     * @param modelBinder 动作模型绑定器。
     * @param services 服务提供器。
     */
    public init(mvcOptions: IOptions<MvcOptions>, modelBinder: IActionModelBinder, services: IServiceProvider) {
        _mvcOptions = mvcOptions.value
        _modelBinder = modelBinder
    }

    /**
     * @brief 为指定的 Action 描述符创建请求处理委托。
     * @param actionDescriptor 要执行的控制器动作描述符。
     * @return 用于处理该动作的请求委托。
     */
    public func createRequestDelegate(actionDescriptor: ControllerActionDescriptor): RequestDelegate {
        return {
            context => ControllerActionInvoker(context, _modelBinder, actionDescriptor, _mvcOptions).apply()
        }
    }
}

/**
 * @brief 表示单次请求的动作执行器。
 * @description 该执行器负责完成模型绑定、调用动作并派发结果。
 */
struct ControllerActionInvoker {
    ControllerActionInvoker(let context: HttpContext, let modelBinder: IActionModelBinder,
        let actionDescriptor: ControllerActionDescriptor, let mvcOptions: MvcOptions) {
    }

    /**
     * @brief 执行完整的请求处理管线。
     */
    public func apply(): Unit {
        let controller = createControllerInstance()
        let modelBindingContext = ActionBindingContext(context, actionDescriptor.actionFunction.parameters)
        let boundParameters = modelBinder.bind(modelBindingContext)
        if (!modelBindingContext.modelState.isValid) {
            handleInvalidModelState(modelBindingContext)
        } else {
            let actionResult = actionDescriptor.actionFunction.apply(controller, boundParameters)
            dispatchResult(actionResult)
        }
    }

    /// 模型绑定失败时写入 ProblemDetails 响应（优先使用自定义工厂）
    private func handleInvalidModelState(modelBindingContext: ActionBindingContext) {
        let options = context.services.getOrThrow<IOptions<ApiBehaviorOptions>>()
        if (let Some(factory) <- options.value.invalidModelStateResponseFactory) {
            let actionContext = ActionContext(context, modelBindingContext.modelState)
            factory(actionContext).invoke(context)
        } else {
            let details = createValidationProblemDetails(modelBindingContext)
            if (let Some(status) <- details.status) {
                context.response.statusCode = UInt16(status)
            }
            context.response.writeAsJson(details)
        }
    }

    /// 按返回值类型派发 Action 结果：IActionResult → 直接调用；String → ContentResult；ISerializable → ObjectResult；其余 → 204
    private func dispatchResult(actionResult: Any) {
        if (let result: IActionResult <- actionResult) {
            result.invoke(context)
        } else if (let result: String <- actionResult) {
            ContentResult(result).invoke(context)
        } else if (let result: ISerializable <- actionResult) {
            ObjectResult<Any>(result).invoke(context)
        } else {
            context.response.statusCode = StatusCodes.NoContent
        }
    }

    /// 根据 ModelState 错误构建 ValidationProblemDetails，区分 415 和 400 两种场景
    private func createValidationProblemDetails(modelBindingContext: ActionBindingContext) {
        let details = ValidationProblemDetails()
        if (hasUnsupportedContentTypeError(modelBindingContext.modelState)) {
            details.`type` = "https://tools.ietf.org/html/rfc9110#section-15.5.16"
            details.title = "Unsupported Media Type"
            details.status = 415
        } else {
            details.`type` = "https://tools.ietf.org/html/rfc9110#section-15.5.1"
            details.title = "One or more validation errors occurred."
            details.status = 400
            for ((name, entry) in modelBindingContext.modelState) {
                details.errors.add(name, entry.errors |> map {f => f.description} |> collectArray)
            }
        }
        return details
    }

    /// 检查 ModelState 中是否含有 UnsupportedContentTypeException 错误
    private func hasUnsupportedContentTypeError(modelState: ModelStateDictionary) {
        for ((_, entry) in modelState) {
            for (error in entry.errors) {
                if (error.exception.flatMap {f => f as UnsupportedContentTypeException}.isSome()) {
                    return true
                }
            }
        }
        return false
    }

    /// 通过 DI 容器实例化控制器，并注入当前 HttpContext
    private func createControllerInstance(): Object {
        let instance = ActivatorUtilities.createInstance(context.services, actionDescriptor.controllerType)
        if (let controller: Controller <- instance) {
            controller.setup(context)
        }
        return instance
    }
}

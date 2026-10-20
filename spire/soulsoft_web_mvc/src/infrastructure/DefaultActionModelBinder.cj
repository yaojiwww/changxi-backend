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
import soulsoft_extensions_options.*
import soulsoft_web_mvc.formatters.*
import soulsoft_web_mvc.annotations.*
import soulsoft_web_mvc.abstractions.*
import soulsoft_web_mvc.modelBindings.*
import soulsoft_web_mvc.utilities.*

protected class DefaultActionModelBinder <: IActionModelBinder {
    private let _mvcOptions: MvcOptions
    private let _factory: IModelBinderFactory

    public init(mvcOptions: IOptions<MvcOptions>, factory: IModelBinderFactory) {
        _mvcOptions = mvcOptions.value
        _factory = factory
    }

    public func bind(context: ActionBindingContext): Array<Any> {
        if (context.parameters.size == 0) {
            return []
        }
        let parameters = Array<Any>(context.parameters.size, repeat: ())
        for ((index, parameter) in context.parameters |> enumerate) {
            parameters[index] = bindParameter(context, parameter)
        }
        return parameters
    }

    private func bindParameter(context: ActionBindingContext, parameter: ParameterInfo): Any {
        if (let Some(fromQuery) <- parameter.findAnnotation<FromQuery>()) {
            return bindFromValueProvider(context, parameter, context.httpContext.request.query,
                bindingName: BindingNameUtilities.resolveQueryName(parameter))
        } else if (let Some(fromForm) <- parameter.findAnnotation<FromForm>()) {
            return bindFromValueProvider(context, parameter, context.httpContext.request.form,
                bindingName: BindingNameUtilities.resolveFormName(parameter))
        } else if (let Some(fromRoute) <- parameter.findAnnotation<FromRoute>()) {
            return bindFromValueProvider(context, parameter, context.httpContext.request.routeValues,
                bindingName: BindingNameUtilities.resolveRouteName(parameter))
        } else if (let Some(fromHeader) <- parameter.findAnnotation<FromHeader>()) {
            return bindFromValueProvider(context, parameter, context.httpContext.request.headers,
                bindingName: BindingNameUtilities.resolveHeaderName(parameter))
        } else if (parameter.findAnnotation<FromServices>().isSome()) {
            return context.httpContext.services.getOrThrow(parameter.typeInfo)
        } else {
            return bindFromBody(context, parameter)
        }
    }

    private func bindFromBody(context: ActionBindingContext, parameter: ParameterInfo): Any {
        let formatterContext = InputFormatterContext(parameter.name, parameter.typeInfo, context.modelState,
            context.httpContext)
        if (let Some(formatter) <- selectInputFormatter(formatterContext)) {
            let result = formatter.read(formatterContext)
            if (let Some(model) <- result.model) {
                return model
            }
        } else {
            let contentType = context.httpContext.request.contentType ?? String.empty
            let exception = UnsupportedContentTypeException("Unsupported content type '${contentType}'.")
            context.modelState.addError(parameter.name, exception)
        }
        return ()
    }

    private func bindFromValueProvider(context: ActionBindingContext, parameter: ParameterInfo, source: IValueProvider,
        bindingName!: String = parameter.name): Any {
        if (let Some(binder) <- _factory.createBinder(parameter.typeInfo)) {
            let bindingCtx = ModelBindingContext(
                bindingName,
                parameter.typeInfo,
                source,
                context.modelState,
                context.httpContext,
                _factory,
                _mvcOptions.jsonSerializerOptions
            )
            return binder.bind(bindingCtx)
        }
        context
            .modelState
            .addError(parameter.name, "No model binder found for type '${parameter.typeInfo.qualifiedName}'.")
        return ()
    }

    private func selectInputFormatter(context: InputFormatterContext): ?IInputFormatter {
        for (formatter in _mvcOptions.inputFormatters) {
            if (formatter.canRead(context)) {
                return formatter
            }
        }
        return None
    }
}

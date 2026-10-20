// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_mvc.infrastructure

import std.io.*
import std.reflect.*
import std.unicode.*
import stdx.encoding.json.*
import soulsoft_web_mvc.core.*
import soulsoft_serialization.*
import soulsoft_extensions_options.*
import soulsoft_web_mvc.formatters.*
import soulsoft_web_mvc.abstractions.*

protected class JsonInputFormatter <: IInputFormatter {
    // Supported media types per RFC 4627 / RFC 7159 / RFC 8259
    private static let _supportedMediaTypes: Array<String> = [
        "application/json",
        "text/json",
        "application/*+json"
    ]

    public func canRead(context: InputFormatterContext): Bool {
        if (let Some(contentType) <- context.httpContext.request.contentType) {
            let requestMediaType = MediaType.parse(contentType.trim())
            // Per ASP.NET Core: check if request Content-Type is a subset of any supported media type.
            // e.g. "application/json; charset=utf-8" ⊆ "application/json" → accept
            //      "application/problem+json"         ⊆ "application/*+json" → accept
            for (supported in _supportedMediaTypes) {
                let supportedMediaType = MediaType.parse(supported)
                if (requestMediaType.isSubsetOf(supportedMediaType)) {
                    return true
                }
            }
        }
        return false
    }

    public func read(context: InputFormatterContext): InputFormatterResult {
        let requestBody = StringReader(context.httpContext.request.body).readToEnd()
        if (requestBody.isEmpty()) {
            context.modelState.addError("", "A non-empty request body is required.")
            context.modelState.addError(context.modelName, "The ${context.modelName} field is required.")
            return InputFormatterResult.failure()
        }

        let jsonValue = try {
            JsonValue.fromStr(requestBody)
        } catch (ex: Exception) {
            context.modelState.addError("$", ex.message)
            context.modelState.addError(context.modelName, "The ${context.modelName} field is required.")
            return InputFormatterResult.failure()
        }

        let mvcOptions = context.httpContext.services.getOrThrow<IOptions<MvcOptions>>().value
        try {
            let modelValue = deserialize(context.modelType, jsonValue, mvcOptions.jsonSerializerOptions)
            return InputFormatterResult.success(modelValue)
        } catch (ex: JsonSerializationException) {
            context.modelState.addError(ex.path ?? String.empty, ex.message)
            return InputFormatterResult.failure()
        } catch (ex: Exception) {
            context.modelState.addError("", ex.message)
            return InputFormatterResult.failure()
        }
    }

    private static func deserialize(typeInfo: TypeInfo, jsonValue: JsonValue, jsonSerializerOptions: JsonSerializerOptions): Any {
        return JsonSerializer.deserialize(typeInfo, jsonValue, jsonSerializerOptions)
    }
}

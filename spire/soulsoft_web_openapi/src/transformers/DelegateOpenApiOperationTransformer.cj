// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_openapi.transformers

import soulsoft_web_openapi.models.*

protected class DelegateOpenApiOperationTransformer <: IOpenApiOperationTransformer {
    private let _transformer: (OpenApiOperation, OpenApiOperationTransformerContext) -> Unit

    public init(transformer: (OpenApiOperation, OpenApiOperationTransformerContext) -> Unit) {
        _transformer = transformer
    }

    public func transform(operation: OpenApiOperation, context: OpenApiOperationTransformerContext): Unit {
        _transformer(operation, context)
    }
}

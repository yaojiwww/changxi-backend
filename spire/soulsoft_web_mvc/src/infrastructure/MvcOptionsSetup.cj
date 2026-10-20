// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_mvc.infrastructure

import std.math.numeric.*
import soulsoft_web_mvc.core.*
import soulsoft_extensions_options.*
import soulsoft_web_mvc.formatters.*
import soulsoft_web_mvc.modelBindings.*

/// MVC 框架默认选项配置，对应 ASP.NET Core 的 MvcCoreMvcOptionsSetup
/// 注册内置 InputFormatter、OutputFormatter 和 ModelBinder（后注册优先级更高，用户可在之后覆盖）
protected class MvcOptionsSetup <: IConfigureOptions<MvcOptions> {
    public func configure(options: MvcOptions): Unit {
        options.inputFormatters.add(JsonInputFormatter())
        options.outputFormatters.add(TextOutputFormatter())
        options.outputFormatters.add(JsonOutputFormatter())
        options
            .modelBinders
            .add(ParsableModelBinder<Bool>(defaultValue: false))
            .add(ParsableModelBinder<Int8>(defaultValue: 0))
            .add(ParsableModelBinder<Int16>(defaultValue: 0))
            .add(ParsableModelBinder<Int32>(defaultValue: 0))
            .add(ParsableModelBinder<Int64>(defaultValue: 0))
            .add(ParsableModelBinder<UInt8>(defaultValue: 0))
            .add(ParsableModelBinder<UInt16>(defaultValue: 0))
            .add(ParsableModelBinder<UInt32>(defaultValue: 0))
            .add(ParsableModelBinder<UInt64>(defaultValue: 0))
            .add(ParsableModelBinder<Float16>(defaultValue: 0.0))
            .add(ParsableModelBinder<Float32>(defaultValue: 0.0))
            .add(ParsableModelBinder<Float64>(defaultValue: 0.0))
            .add(ParsableModelBinder<BigInt>(defaultValue: BigInt(0)))
            .add(ParsableModelBinder<Decimal>(defaultValue: Decimal(0)))
            .add(StringModelBinder())
            .add(DateTimeModelBinder())
            .add(FormFileModelBinder())
            .add(FormFileArrayModelBinder())
    }
}

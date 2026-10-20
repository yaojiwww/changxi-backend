// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_logging_console

import soulsoft_extensions_configuration.*
import soulsoft_extensions_logging_configuration.*
import soulsoft_extensions_options.*

/*
cangjie不支持协变： 因此IConfigureOptions<ConsoleFormatterOptions> 不能拿去约束 IConfigureOptions<JsonConsoleFormatterOptions>
*/
class ConsoleFormatterConfigureOptions<TOptions> <: IConfigureOptions<TOptions> where TOptions <: ConsoleFormatterOptions {
    private let _configuration: IConfiguration

    public init(providerConfiguration: ILoggerProviderConfiguration<ConsoleLoggerProvider>) {
        _configuration = getFormatterOptionsSection(providerConfiguration)
    }

    public func configure(options: TOptions): Unit {
        options.configure(_configuration)
    }
}

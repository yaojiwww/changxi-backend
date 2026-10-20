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

class ConsoleLoggerConfigureOptions <: IConfigureOptions<ConsoleLoggerOptions> {
    private let _configuration: IConfiguration

    public init(providerConfiguration: ILoggerProviderConfiguration<ConsoleLoggerProvider>) {
        _configuration = providerConfiguration.configuration
    }

    public func configure(options: ConsoleLoggerOptions): Unit {
        ConfigurationBinder.bind(options, _configuration)
    }
}

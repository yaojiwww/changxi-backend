// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_options

import std.collection.*
import soulsoft_extensions_options.exceptions.*

class StartupValidator <: IStartupValidator {
    public StartupValidator(let validatorOptions: IOptions<StartupValidatorOptions>) {
    }

    public func validate(): Unit {
        var exceptions: ?ArrayList<Exception> = None
        for ((_, _, validator) in validatorOptions.value.validators) {
            try {
                validator()
            } catch (ex: OptionsValidationException) {
                if (let Some(exceptions) <- exceptions) {
                    exceptions.add(ex)
                } else {
                    exceptions = ArrayList<Exception>([ex])
                }
            }
        }

        if (let Some(exceptions) <- exceptions) {
            if (exceptions.size == 1) {
                throw exceptions[0]
            } else {
                throw AggregateException(exceptions)
            }
        }
    }
}

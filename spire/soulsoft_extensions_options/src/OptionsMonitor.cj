// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_options

class OptionsMonitor<TOptions> <: IOptionsMonitor<TOptions> where TOptions <: Object {
    private let _cache: IOptionsMonitorCache<TOptions>
    private let _optionsFactory: IOptionsFactory<TOptions>

    public init(cache: IOptionsMonitorCache<TOptions>, optionsFactory: IOptionsFactory<TOptions>) {
        _cache = cache
        _optionsFactory = optionsFactory
    }

    public func get(name: String): TOptions {
        return _cache.getOrAdd(name) {
            _optionsFactory.create(name)
        }
    }

    public prop currentValue: TOptions {
        get() {
            get(Options.defaultName)
        }
    }
}

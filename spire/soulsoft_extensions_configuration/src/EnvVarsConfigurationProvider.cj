// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_configuration

import std.env.*
import std.reflect.*

class EnvVarsConfigurationProvider <: ConfigurationProvider {
    private let _prefix: String
    private let _normalizedPrefix: String

    init(prefix: String) {
        _prefix = prefix
        _normalizedPrefix = normalize(prefix)
    }

    /**
     * @brief 返回当前环境变量配置提供程序的描述信息。
     * @return 返回当前环境变量配置提供程序的描述信息。
     */
    public func toString(): String {
        "${ClassTypeInfo.of(this).name} Prefix: '${_prefix}'"
    }

    public override func load() {
        for ((name, value) in getVariables()) {
            addIfNormalizedKeyMatchesPrefix(normalize(name), value)
        }
    }

    private func addIfNormalizedKeyMatchesPrefix(normalizedKey: String, value: String) {
        if (normalizedKey.startsWithIgnoreAsciiCase(_normalizedPrefix)) {
            data[normalizedKey[_normalizedPrefix.size..]] = value
        }
    }

    private static func normalize(key: String) {
        return key.replace("__", ConfigurationPath.delimiter)
    }
}

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_configuration

import std.collection.*

class ConfigurationUtilities {
    private init() {
    }

    public static func getChildKeys(configuration: IConfigurationRoot, path: ?String): Collection<String> {
        let results = HashSet<String>()
        let providers = configuration.providers
        var index = providers.size - 1
        while (index >= 0) {
            let provider = providers[index]
            let keys = provider.getChildKeys(results, path)
            for (key in keys) {
                results.add(key)
            }
            index--
        }
        return results
    }

    public static func asEnumerable(configuration: IConfiguration, makePathsRelative: Bool): Collection<(String, ?String)> {
        let items = ArrayList<(String, ?String)>()
        var prefixLength: Int64 = 0
        if (makePathsRelative) {
            if (let section: IConfigurationSection <- configuration) {
                prefixLength = section.path.size + 1
            }
        }

        var includeCurrent = false
        if (!makePathsRelative) {
            includeCurrent = configuration is IConfigurationSection
        }

        collectAsEnumerable(configuration, makePathsRelative, prefixLength, includeCurrent, items)
        items
    }

    private static func collectAsEnumerable(configuration: IConfiguration, makePathsRelative: Bool, prefixLength: Int64,
        includeCurrent: Bool, items: ArrayList<(String, ?String)>): Unit {
        if (includeCurrent && let section: IConfigurationSection <- configuration) {
            let path = if (makePathsRelative) {
                section.path[prefixLength..]
            } else {
                section.path
            }
            items.add((path, section.value))
        }

        for (child in configuration.getChildren()) {
            collectAsEnumerable(child, makePathsRelative, prefixLength, true, items)
        }
    }
}

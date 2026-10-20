// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_configuration

import std.collection.*

class CmdArgsConfigurationProvider <: ConfigurationProvider {
    private let _args: Array<String>
    private let _switchMappings: ?Map<String, String>

    init(args: Array<String>, switchMappings!: ?Map<String, String> = None) {
        _args = args
        if (let Some(switchMappings) <- switchMappings) {
            _switchMappings = getValidatedSwitchMappingsCopy(switchMappings)
        } else {
            _switchMappings = None
        }
    }

    public override func load() {
        let it = _args.iterator()
        while (let Some(next) <- it.next()) {
            var currentArg = next
            var keyStartIndex = 0
            if (currentArg.startsWith('--')) {
                keyStartIndex = 2
            } else if (currentArg.startsWith('-')) {
                keyStartIndex = 1
            } else if (currentArg.startsWith('/')) {
                keyStartIndex = 2
                currentArg = "--${currentArg[1..]}"
            }

            if (let Some(separator) <- currentArg.indexOf('=')) {
                let keySegment = currentArg[0..separator]

                let key = if (let Some(switchMappings) <- _switchMappings && let Some(mappedKeySegment) <- switchMappings
                    .get(keySegment)) {
                    mappedKeySegment
                } else {
                    if (keyStartIndex == 1) {
                        throw IllegalFormatException(
                            "The short switch '${currentArg}' is not defined in the switch mappings.")
                    }
                    currentArg[keyStartIndex..separator]
                }
                data[key] = currentArg[separator + 1..]
            } else {
                if (keyStartIndex == 0) {
                    continue
                }

                let key = if (let Some(switchMappings) <- _switchMappings && let Some(mappedKey) <- switchMappings.get(
                    currentArg)) {
                    mappedKey
                } else {
                    if (keyStartIndex == 1) {
                        continue
                    }
                    currentArg[keyStartIndex..]
                }

                if (let Some(next) <- it.next()) {
                    data[key] = next
                } else {
                    continue
                }
            }
        }
    }

    private static func getValidatedSwitchMappingsCopy(switchMappings: Map<String, String>) {
        let switchMappingsCopy = IgnoreCaseHashMap<String>()

        for ((key, value) in switchMappings) {
            if (!key.startsWith('-') && !key.startsWith('--')) {
                throw IllegalArgumentException("The switch mappings contain an invalid switch '${key}'.")
            }
            if (switchMappingsCopy.contains(key)) {
                throw IllegalArgumentException(
                    "Keys in switch mappings are case-insensitive. A duplicated key '${key}' was found.")
            }
            switchMappingsCopy.add(key, value)
        }

        return switchMappingsCopy
    }
}

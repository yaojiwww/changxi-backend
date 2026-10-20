// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_protocols

import std.unicode.UnicodeStringExtension

class Utility {
    public static func isHttps(address: String): Bool {
        return address.toLower().startsWith("https://")
    }
}

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_protection.utilities

import stdx.crypto.crypto.*

protected class SecureRandomUtil {
    public static let instance = SecureRandom()

    public static func generate(size: Int64) {
        let bytes = Array<Byte>(size, repeat: 0)
        instance.nextBytes(bytes)
        return bytes
    }
}

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_web_authentication_cookies

import stdx.encoding.base64.*

class Base64UrlEncoder {
    public static func encode(input: String) {
        return encode(input.toArray())
    }

    public static func encode(data: Array<Byte>) {
        return toBase64String(data).replace('+', '-').replace('/', '_').trimEnd(r'=')
    }

    public static func decodeBytes(input: String): ?Array<Byte> {
        let base64 = input.replace('-', '+').replace('_', '/')
        let remainder = base64.toRuneArray().size % 4
        if (remainder > 0) {
            let endStr = String(Array<Rune>(4 - remainder, repeat: r'='))
            return fromBase64String("${base64}${endStr}")
        }
        return fromBase64String("${base64}")
    }

    public static func decode(input: String): ?String {
        if (let Some(data) <- decodeBytes(input)) {
            return String.fromUtf8(data)
        }
        return None
    }
}
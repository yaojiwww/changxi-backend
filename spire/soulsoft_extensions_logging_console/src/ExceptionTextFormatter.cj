// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_logging_console

import std.core.*

internal class ExceptionTextFormatter {
    internal static let shared = ExceptionTextFormatter()

    private init() {
    }

    public func format(exception: ?Exception): String {
        if (let Some(ex) <- exception) {
            let sb = StringBuilder()
            appendException(sb, ex, None)
            return sb.toString().trimEnd()
        }
        return String.empty
    }

    private func appendException(sb: StringBuilder, exception: Exception, caption: ?String): Unit {
        if (let Some(caption) <- caption) {
            sb.append(caption)
            sb.append(" ")
        }
        sb.append(exception.toString())
        let trace = exception.getStackTrace()
        for (element in trace) {
            if (element.methodName.contains("Exception::init")) {
                continue
            }
            sb.append("\n\t at ")
            sb.append(element.toString())
        }
        if (let Some(cause) <- exception.causedBy) {
            sb.append("\n")
            appendException(sb, cause, Some("Caused by:"))
        }
    }
}

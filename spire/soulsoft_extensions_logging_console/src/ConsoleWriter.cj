// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_logging_console

import std.env.*

class ConsoleWriter {
    private let _writer = getStdOut()
    private let _errorWriter = getStdErr()
    private let _stdErr: Bool

    init(stdErr!: Bool = false) {
        _stdErr = stdErr
    }

    public func write(message: String): Unit {
        if (_stdErr) {
            _errorWriter.write(message)
            _errorWriter.flush()
            return
        }
        _writer.write(message)
        _writer.flush()
    }
}

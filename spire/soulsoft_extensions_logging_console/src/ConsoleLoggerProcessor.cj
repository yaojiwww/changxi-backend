// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_logging_console

import std.collection.concurrent.*

class ConsoleLoggerProcessor {
    private var _worker: ?Future<Unit> = None
    private let _queue: LinkedBlockingQueue<Option<LogMessageEntry>>
    private let _console: IConsole
    private let _errorConsole: IConsole
    private var _fullMode: ConsoleLoggerQueueFullMode = ConsoleLoggerQueueFullMode.Wait
    private var _maxQueueLength: Int64

    init(console: IConsole, errorConsole: IConsole, fullMode: ConsoleLoggerQueueFullMode, maxQueueLength: Int64) {
        _queue = LinkedBlockingQueue(maxQueueLength)
        _console = console
        _errorConsole = errorConsole
        _fullMode = fullMode
        _maxQueueLength = maxQueueLength
        start()
    }

    public mut prop fullMode: ConsoleLoggerQueueFullMode {
        get() {
            _fullMode
        }
        set(value) {
            _fullMode = value
        }
    }

    public mut prop maxQueueLength: Int64 {
        get() {
            _maxQueueLength
        }
        set(value) {
            _maxQueueLength = value
        }
    }

    func enqueue(entry: LogMessageEntry): Unit {
        if (isDropWriteMode()) {
            _queue.tryAdd(Some(entry))
            return
        }
        _queue.add(Some(entry))
    }

    private func start(): Unit {
        _worker = spawn {processQueue()}
    }

    private func processQueue(): Unit {
        while (true) {
            match (_queue.remove()) {
                case None => break
                case Some(entry) => try {
                    writeMessage(entry)
                } catch (_: Exception) {
                }
            }
        }
    }

    private func writeMessage(entry: LogMessageEntry): Unit {
        let console = if (entry.logAsError) {
            _errorConsole
        } else {
            _console
        }
        console.write(entry.message)
    }

    private func isDropWriteMode(): Bool {
        return match (_fullMode) {
            case ConsoleLoggerQueueFullMode.DropWrite => true
            case ConsoleLoggerQueueFullMode.Wait => false
        }
    }

    func dispose(): Unit {
        _queue.add(None)
        if (let Some(future) <- _worker) {
            future.get()
        }
    }
}

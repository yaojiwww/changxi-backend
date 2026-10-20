// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_routing.matching

import std.reflect.*
import std.collection.*

/*
路径跳转表
 */
protected abstract class JumpTable {
    public func getDestination(path: String): Int64

    protected open func debuggerToString(): String {
        ClassTypeInfo.of(this).qualifiedName
    }
}

/*
空项跳转表
 */
protected class ZeroEntryJumpTable <: JumpTable {
    private let _exitDestination: Int64
    private let _defaultDestination: Int64

    public init(defaultDestination: Int64, exitDestination: Int64) {
        _exitDestination = exitDestination
        _defaultDestination = defaultDestination
    }

    public func getDestination(path: String): Int64 {
        if (path.size == 0) {
            return _exitDestination
        } else {
            _defaultDestination
        }
    }

    protected func debuggerToString(): String {
        return "{ $+: ${_defaultDestination}, $0: ${_exitDestination} }"
    }
}

/*
单项跳转表
 */
protected class SingleEntryJumpTable <: JumpTable {
    private let _exitDestination: Int64
    private let _defaultDestination: Int64
    private let _entry: (String, Int64)

    public init(defaultDestination: Int64, exitDestination: Int64, entry: (String, Int64)) {
        _exitDestination = exitDestination
        _defaultDestination = defaultDestination
        _entry = entry
    }

    public func getDestination(path: String): Int64 {
        if (path.size == 0) {
            return _exitDestination
        }

        if (_entry[0] == path) {
            return _entry[1]
        }

        return _defaultDestination
    }

    protected func debuggerToString(): String {
        return "{ ${_entry[0]}: ${_entry[1]}, $+: ${_defaultDestination}, $0: ${_exitDestination} }"
    }
}

/*
线性搜索跳转表
 */
protected class LinearSearchJumpTable <: JumpTable {
    private let _exitDestination: Int64
    private let _defaultDestination: Int64
    private let _entries: Array<(String, Int64)>

    public init(defaultDestination: Int64, exitDestination: Int64, entries: Array<(String, Int64)>) {
        _exitDestination = exitDestination
        _defaultDestination = defaultDestination
        _entries = entries
    }

    public func getDestination(path: String): Int64 {
        if (path.size == 0) {
            return _exitDestination
        }

        let entries = _entries
        // 规避迭代器gc压力问题
        var i = 0
        while (i < entries.size) {
            if (entries[i][0] == path) {
                return entries[i][1]
            }
            i++
        }

        return _defaultDestination
    }

    protected func debuggerToString(): String {
        let parts = ArrayList<String>()
        for ((k, v) in _entries) {
            parts.add("${k}: ${v}")
        }
        parts.add("$+: ${_defaultDestination}")
        parts.add("$0: ${_exitDestination}")
        return "{ ${String.join(parts |> collectArray, delimiter: ", ")} }"
    }
}

/*
字典跳转表
 */
protected class DictionaryJumpTable <: JumpTable {
    private let _exitDestination: Int64
    private let _defaultDestination: Int64
    private let _entries: HashMap<String, Int64>

    public init(defaultDestination: Int64, exitDestination: Int64, entries: Collection<(String, Int64)>) {
        _exitDestination = exitDestination
        _defaultDestination = defaultDestination
        _entries = HashMap<String, Int64>(entries)
    }

    public func getDestination(path: String): Int64 {
        if (path.size == 0) {
            return _exitDestination
        }

        if (let Some(destination) <- _entries.get(path)) {
            return destination
        }

        return _defaultDestination
    }

    protected func debuggerToString(): String {
        let parts = ArrayList<String>()
        for ((k, v) in _entries) {
            parts.add("${k}: ${v}")
        }
        parts.add("$+: ${_defaultDestination}")
        parts.add("$0: ${_exitDestination}")
        return "{ ${String.join(parts |> collectArray, delimiter: ", ")} }"
    }
}

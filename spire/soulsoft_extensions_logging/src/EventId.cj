// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_extensions_logging

/**
 * @brief 表示日志事件标识。
 */
public struct EventId <: Equatable<EventId> & Hashable {
    private let _id: Int64
    private let _name: ?String

    /**
     * @brief 使用事件编号创建事件标识。
     * @param id 事件编号。
     */
    public init(id: Int64) {
        this(id, None)
    }

    /**
     * @brief 使用事件编号和名称创建事件标识。
     * @param id 事件编号。
     * @param name 事件名称。
     */
    public init(id: Int64, name: ?String) {
        _id = id
        _name = name
    }

    /**
     * @brief 获取事件编号。
     * @return 返回事件编号。
     */
    public prop id: Int64 {
        get() {
            _id
        }
    }

    /**
     * @brief 获取事件名称。
     * @return 返回事件名称；如果未设置则返回 `None`。
     */
    public prop name: ?String {
        get() {
            _name
        }
    }

    /**
     * @brief 返回事件标识的哈希值。
     * @return 返回基于事件编号计算得到的哈希值。
     */
    public func hashCode() {
        _id
    }

    /**
     * @brief 比较两个事件标识是否相等。
     * @param that 要比较的另一个事件标识。
     * @return 当两个事件编号相同时返回 `true`，否则返回 `false`。
     */
    public operator func ==(that: EventId) {
        this._id == that._id
    }
}

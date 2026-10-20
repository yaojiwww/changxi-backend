// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_http

import std.sync.*

private let _hashFactory = AtomicInt64(0)

/**
 * @brief 表示一个可执行的 HTTP 端点。
 */
public abstract class Endpoint <: ToString & Hashable & Equatable<Endpoint> {
    private let _hashCode: Int64
    private let _displayName: ?String
    private let _delegate: RequestDelegate
    private let _metadata: EndpointMetadataCollection

    /**
     * @brief 创建一个端点实例。
     * @param delegate 端点执行委托。
     * @param metadata 端点元数据集合。
     * @param displayName 端点显示名称。
     */
    public init(delegate: RequestDelegate, metadata: EndpointMetadataCollection, displayName: ?String) {
        _delegate = delegate
        _metadata = metadata
        _displayName = displayName
        _hashCode = _hashFactory.fetchAdd(1)
    }

    /**
     * @brief 返回端点执行委托。
     * @return 当前端点执行委托。
     */
    public prop delegate: RequestDelegate {
        get() {
            _delegate
        }
    }

    /**
     * @brief 返回端点元数据集合。
     * @return 当前端点元数据集合。
     */
    public prop metadata: EndpointMetadataCollection {
        get() {
            _metadata
        }
    }

    /**
     * @brief 返回端点显示名称。
     * @return 当前端点显示名称；如果未设置则返回空。
     */
    public prop displayName: ?String {
        get() {
            _displayName
        }
    }

    /**
     * @brief 返回当前端点的哈希值。
     * @return 当前端点的哈希值。
     */
    public func hashCode(): Int64 {
        _hashCode
    }

    /**
     * @brief 返回当前端点的显示名称。
     * @return 端点显示名称；未设置时返回空字符串。
     */
    public open func toString(): String {
        return _displayName ?? String.empty
    }

    /**
     * @brief 比较两个端点是否相等。
     * @param that 要比较的端点。
     * @return 如果两个端点相等则返回 true，否则返回 false。
     */
    public operator func ==(that: Endpoint): Bool {
        return this._hashCode == that._hashCode
    }
}

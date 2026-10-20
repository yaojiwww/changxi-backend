// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_extensions_objectpool

import std.core.StringBuilder

/**
 * @brief 提供 StringBuilder 的对象池策略。
 */
public class StringBuilderPooledObjectPolicy <: PooledObjectPolicy<StringBuilder> {
    /**
     * @brief 表示新建 StringBuilder 时使用的初始容量。
     */
    public var initialCapacity: Int64 = 100

    /**
     * @brief 表示允许保留在对象池中的最大 StringBuilder 容量。
     */
    public var maximumRetainedCapacity: Int64 = 4 * 1024

    /**
     * @brief 创建 StringBuilder 对象池策略实例。
     */
    public init() {}

    /**
     * @brief 创建一个新的 StringBuilder 实例。
     * @return 新创建的 StringBuilder 实例。
     */
    public override func create(): StringBuilder {
        StringBuilder(initialCapacity)
    }

    /**
     * @brief 处理 StringBuilder 归还到对象池时的重置逻辑。
     * @param obj 待归还的 StringBuilder 实例。
     * @return 如果对象可以重新保留到对象池，则返回 true；否则返回 false。
     */
    public override func release(obj: StringBuilder): Bool {
        if (obj.capacity > maximumRetainedCapacity) {
            return false
        }

        // 与 aspnetcore 的差异：
        // 仓颉 StringBuilder 没有公开提供等价于 Clear() 的 API，
        // 无法在清空内容的同时保证保留当前容量。reset(capacity:)
        // 会在清空内容的同时重置容量，因此这里保留的对象会回缩到
        // initialCapacity，而不是保留归还前的容量。
        obj.reset(capacity: initialCapacity)
        return true
    }
}

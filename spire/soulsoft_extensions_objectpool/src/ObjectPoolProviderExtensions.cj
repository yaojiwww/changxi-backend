// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_extensions_objectpool

/**
 * @brief 提供 ObjectPoolProvider 的扩展创建函数。
 */
extend ObjectPoolProvider {
    /**
     * @brief 创建一个用于复用 StringBuilder 的对象池。
     * @return StringBuilder 对象池实例。
     */
    public func createStringBuilderPool(): ObjectPool<StringBuilder> {
        this.create<StringBuilder>(StringBuilderPooledObjectPolicy())
    }

    /**
     * @brief 创建一个带有容量配置的 StringBuilder 对象池。
     * @param initialCapacity StringBuilder 的初始容量。
     * @param maximumRetainedCapacity 允许保留的最大容量。
     * @return StringBuilder 对象池实例。
     */
    public func createStringBuilderPool(initialCapacity: Int64, maximumRetainedCapacity: Int64): ObjectPool<StringBuilder> {
        let policy = StringBuilderPooledObjectPolicy()
        policy.initialCapacity = initialCapacity
        policy.maximumRetainedCapacity = maximumRetainedCapacity
        return create<StringBuilder>(policy)
    }
}

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_extensions_objectpool

import std.sync.*

/**
 * @brief 提供可关闭对象的对象池实现。
 * @param T 对象池管理的对象类型。
 */
protected class DisposableObjectPool<T> <: DefaultObjectPool<T> & Resource where T <: Object {
    private let _isClosed = AtomicBool(false)

    /**
     * @brief 使用指定策略和保留容量创建可关闭对象池。
     * @param policy 对象池策略。
     * @param maximumRetained 对象池允许保留的最大对象数。
     */
    public init(policy: IPooledObjectPolicy<T>, maximumRetained: Int64) {
        super(policy, maximumRetained)
    }

    /**
     * @brief 从对象池获取一个对象实例。
     * @return 可供调用方使用的对象实例。
     * @throws IllegalStateException 当对象池已关闭时抛出。
     */
    public override func get(): T {
        if (_isClosed.load()) {
            throw IllegalStateException("The object pool is closed.")
        }
        super.get()
    }

    /**
     * @brief 将对象归还到对象池，必要时关闭对象。
     * @param obj 待归还的对象实例。
     */
    public func put(obj: T): Unit {
        if (_isClosed.load() || !`putCore`(obj)) {
            closeItem(obj)
        }
    }

    /**
     * @brief 检查对象池是否已关闭。
     * @return 如果对象池已关闭，则返回 true；否则返回 false。
     */
    public override func isClosed(): Bool {
        _isClosed.load()
    }

    /**
     * @brief 关闭对象池并清理池中保留的对象。
     */
    public override func close(): Unit {
        if (!_isClosed.compareAndSwap(false, true)) {
            return
        }

        match (fastItem.swap(None)) {
            case Some(item) => closeItem(item)
            case None => ()
        }

        while (true) {
            match (items.remove()) {
                case Some(item) => closeItem(item)
                case None => break
            }
        }
    }

    private func closeItem(item: T): Unit {
        if (let Some(resource) <- (item as Resource)) {
            if (!resource.isClosed()) {
                resource.close()
            }
        }
    }
}

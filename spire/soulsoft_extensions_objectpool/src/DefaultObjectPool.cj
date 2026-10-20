// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_extensions_objectpool

import std.sync.*
import std.runtime.*
import std.collection.concurrent.*

/**
 * @brief 提供默认的对象池实现。
 * @param T 对象池管理的对象类型。
 */
public open class DefaultObjectPool<T> <: ObjectPool<T> where T <: Object {
    private let _createFunc: () -> T
    private let _returnFunc: (T) -> Bool
    private let _maxCapacity: Int64
    private let _numItems = AtomicInt64(0)

    private let _items = ConcurrentLinkedQueue<T>()
    private let _fastItem = AtomicOptionReference<T>(None)

    /**
     * @brief 使用默认保留容量创建对象池实例。
     * @param policy 对象池策略。
     */
    public init(policy: IPooledObjectPolicy<T>) {
        this(policy, getProcessorCount() * 2)
    }

    /**
     * @brief 使用指定保留容量创建对象池实例。
     * @param policy 对象池策略。
     * @param maximumRetained 对象池允许保留的最大对象数。
     */
    public init(policy: IPooledObjectPolicy<T>, maximumRetained: Int64) {
        _createFunc = policy.create
        _returnFunc = policy.release
        _maxCapacity = maximumRetained - 1
    }

    /**
     * @brief 获取对象池内部保留对象的队列。
     * @return 用于存放保留对象的并发队列。
     */
    protected prop items: ConcurrentLinkedQueue<T> {
        get() {
            _items
        }
    }

    /**
     * @brief 获取对象池的快速缓存槽。
     * @return 用于快速复用单个对象的原子引用槽。
     */
    protected prop fastItem: AtomicOptionReference<T> {
        get() {
            _fastItem
        }
    }

    /**
     * @brief 从对象池获取一个对象实例。
     * @return 可供调用方使用的对象实例。
     */
    public open func get(): T {
        let item = _fastItem.load()
        if (let Some(value) <- item) {
            // 尝试无锁占用单个快速缓存槽。
            if (_fastItem.compareAndSwap(item, None)) {
                return value
            }
        }

        // 快速缓存槽为空或竞争失败时，回退到保留队列。
        if (let Some(value) <- _items.remove()) {
            _numItems.fetchSub(1)
            return value
        }

        // 没有可复用对象时，创建新实例。
        return _createFunc()
    }

    /**
     * @brief 将对象归还到对象池。
     * @param obj 待归还的对象实例。
     */
    public open func put(obj: T): Unit {
        putCore(obj)
    }

    /**
     * @brief 执行对象归还的核心逻辑。
     * @param obj 待归还的对象实例。
     * @return 如果对象被成功保留到池中，则返回 true；否则返回 false。
     */
    protected func putCore(obj: T): Bool {
        if (!_returnFunc(obj)) {
            return false
        }

        if (_fastItem.compareAndSwap(None, obj)) {
            return true
        }

        let retained = _numItems.fetchAdd(1) + 1
        if (retained <= _maxCapacity) {
            _items.add(obj)
            return true
        }

        _numItems.fetchSub(1)
        return false
    }
}

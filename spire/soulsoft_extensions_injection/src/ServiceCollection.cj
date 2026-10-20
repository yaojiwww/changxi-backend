// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_injection

import std.sync.*
import std.reflect.*
import std.collection.*

/**
 * @brief 表示用于注册服务描述的集合。
 */
public class ServiceCollection <: List<ServiceDescriptor> {
    private let _lock = Mutex()
    private let _isBuilt = AtomicBool(false)
    private let _items = ArrayList<ServiceDescriptor>()

    /**
     * @brief 在集合末尾添加一个服务描述。
     * @param element 要添加的服务描述。
     * @throws UnsupportedException 当服务集合已构建时抛出。
     */
    public func add(element: ServiceDescriptor): Unit {
        ensureWritable()
        _items.add(element)
    }

    /**
     * @brief 在集合末尾追加多个服务描述。
     * @param all 要添加的服务描述集合。
     * @throws UnsupportedException 当服务集合已构建时抛出。
     */
    public func add(all!: Collection<ServiceDescriptor>): Unit {
        ensureWritable()
        _items.add(all: all)
    }

    /**
     * @brief 在指定位置插入一个服务描述。
     * @param element 要插入的服务描述。
     * @param at 插入位置。
     * @throws UnsupportedException 当服务集合已构建时抛出。
     */
    public func add(element: ServiceDescriptor, at!: Int64): Unit {
        ensureWritable()
        _items.add(element, at: at)
    }

    /**
     * @brief 在指定位置插入多个服务描述。
     * @param all 要插入的服务描述集合。
     * @param at 插入位置。
     * @throws UnsupportedException 当服务集合已构建时抛出。
     */
    public func add(all!: Collection<ServiceDescriptor>, at!: Int64): Unit {
        ensureWritable()
        _items.add(all: all, at: at)
    }

    /**
     * @brief 删除指定位置的服务描述。
     * @param at 要删除的位置。
     * @return 返回被删除的服务描述。
     * @throws UnsupportedException 当服务集合已构建时抛出。
     */
    public func remove(at!: Int64): ServiceDescriptor {
        ensureWritable()
        _items.remove(at: at)
    }

    /**
     * @brief 删除指定范围内的服务描述。
     * @param range 要删除的索引范围。
     * @throws UnsupportedException 当服务集合已构建时抛出。
     */
    public func remove(range: Range<Int64>): Unit {
        ensureWritable()
        _items.remove(range)
    }

    /**
     * @brief 删除满足条件的服务描述。
     * @param predicate 用于判断是否删除的条件函数。
     * @throws UnsupportedException 当服务集合已构建时抛出。
     */
    public func removeIf(predicate: (ServiceDescriptor) -> Bool): Unit {
        ensureWritable()
        _items.removeIf(predicate)
    }

    /**
     * @brief 检查集合是否为空。
     * @return 如果集合中没有服务描述则返回 `true`，否则返回 `false`。
     */
    public func isEmpty(): Bool {
        _items.isEmpty()
    }

    /**
     * @brief 清空当前服务集合。
     * @throws UnsupportedException 当服务集合已构建时抛出。
     */
    public func clear(): Unit {
        ensureWritable()
        _items.clear()
    }

    /**
     * @brief 返回指定位置的服务描述。
     * @param index 要读取的索引位置。
     * @return 指定位置的服务描述。
     */
    public func get(index: Int64): ?ServiceDescriptor {
        _items.get(index)
    }

    /**
     * @brief 返回集合中的第一个服务描述。
     * @return 第一个服务描述；集合为空时返回 `None`。
     */
    public prop first: ?ServiceDescriptor {
        get() {
            _items.first
        }
    }

    /**
     * @brief 返回集合中的最后一个服务描述。
     * @return 最后一个服务描述；集合为空时返回 `None`。
     */
    public prop last: ?ServiceDescriptor {
        get() {
            _items.last
        }
    }

    /**
     * @brief 返回集合中的服务描述数量。
     * @return 当前集合中的元素个数。
     */
    public prop size: Int64 {
        get() {
            _items.size
        }
    }

    /**
     * @brief 将当前服务集合转换为数组。
     * @return 包含全部服务描述的数组副本。
     */
    public func toArray(): Array<ServiceDescriptor> {
        _items.toArray()
    }

    /**
     * @brief 返回遍历当前服务集合的迭代器。
     * @return 当前服务集合的迭代器。
     */
    public func iterator(): Iterator<ServiceDescriptor> {
        _items.iterator()
    }

    /**
     * @brief 读取指定索引位置的服务描述。
     * @param index 要读取的索引位置。
     * @return 指定索引位置的服务描述。
     */
    public operator func [](index: Int64): ServiceDescriptor {
        _items[index]
    }

    /**
     * @brief 设置指定索引位置的服务描述。
     * @param index 要写入的索引位置。
     * @param value 要设置的服务描述。
     * @throws UnsupportedException 当服务集合已构建时抛出。
     */
    public operator func [](index: Int64, value!: ServiceDescriptor): Unit {
        ensureWritable()
        _items[index] = value
    }

    /**
     * @brief 使用默认选项构建服务提供者。
     * @return 构建得到的服务提供者。
     * @throws Exception 当构建或校验服务图失败时抛出。
     */
    public func build(): IServiceProvider {
        build({_ =>})
    }

    /**
     * @brief 使用自定义选项构建服务提供者。
     * @param configureOptions 用于配置服务提供者选项的回调。
     * @return 构建得到的服务提供者。
     * @throws Exception 当构建或校验服务图失败时抛出。
     */
    public func build(configureOptions: (ServiceProviderOptions) -> Unit): IServiceProvider {
        synchronized(_lock) {
            _isBuilt.swap(true)
            let options = ServiceProviderOptions()
            configureOptions(options)
            return ServiceProvider(this, options)
        }
    }

    private func ensureWritable() {
        if (_isBuilt.load()) {
            throw UnsupportedException("The service collection cannot be modified because it has been built.")
        }
    }
}

extend ServiceCollection {
    /**
     * @brief 仅当相同服务类型和服务键尚未注册时添加服务描述。
     * @param element 要尝试添加的服务描述。
     * @throws UnsupportedException 当服务集合已构建时抛出。
     */
    public func tryAdd(element: ServiceDescriptor): Unit {
        for (index in 0..this.size) {
            if (this[index].serviceType == element.serviceType && this[index].serviceKey == element.serviceKey) {
                return
            }
        }
        add(element)
    }
}

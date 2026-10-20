// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_objectpool

/**
 * @brief 表示对象池的抽象接口。
 * @param T 对象池管理的对象类型。
 */
public abstract class ObjectPool<T> where T <: Object {
    /**
     * @brief 从对象池获取一个对象实例。
     * @return 可供调用方使用的对象实例。
     */
    public func get(): T

    /**
     * @brief 将对象归还到对象池。
     * @param obj 待归还的对象实例。
     */
    public func put(obj: T): Unit
}

/**
 * @brief 提供创建默认对象池实例的静态工厂入口。
 */
public class ObjectPoolFactory {

    /**
     * @brief 使用对象工厂创建一个采用默认策略的对象池。
     * @param factory 用于创建对象实例的工厂函数。
     * @return 由默认对象池提供程序创建的对象池实例。
     */
    public static func create<T>(factory: () -> T): ObjectPool<T> where T <: Object {
        let provider = DefaultObjectPoolProvider()
        return provider.create(DefaultPooledObjectPolicy<T>(factory))
    }

    /**
     * @brief 使用指定策略创建对象池；未提供策略时回退到默认策略。
     * @param policy 对象池策略；为 None 时基于 factory 构造 DefaultPooledObjectPolicy。
     * @return 由 DefaultObjectPoolProvider 创建的对象池实例。
     */
    public static func create<T>(policy: IPooledObjectPolicy<T>): ObjectPool<T> where T <: Object {
        let provider = DefaultObjectPoolProvider()
        return provider.create(policy)
    }
}

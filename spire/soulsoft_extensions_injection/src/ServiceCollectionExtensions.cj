// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_injection

import std.reflect.*

extend ServiceCollection {
   
    /**
     * @brief 注册一个单例实例。
     * @param instance 要注册的单例实例。
     * @return 当前服务集合。
     * @throws UnsupportedException 当服务集合已构建时抛出。
     */
    public func addSingleton<TService>(instance: TService): ServiceCollection {
        add(ServiceDescriptor.singleton<TService>(instance))
        return this
    }

    /**
     * @brief 注册一个指定服务类型和实现实例的单例。
     * @param instance 要注册的实现实例。
     * @return 当前服务集合。
     * @throws UnsupportedException 当服务集合已构建时抛出。
     */
    public func addSingleton<TService, TImplementation>(instance: TImplementation): ServiceCollection where TImplementation <: Object {
        add(ServiceDescriptor.singleton<TService, TImplementation>(instance))
        return this
    }

    /**
     * @brief 注册一个指定服务类型和实现类型的单例映射。
     * @return 当前服务集合。
     * @throws UnsupportedException 当服务集合已构建时抛出。
     */
    public func addSingleton<TService, TImplementation>(): ServiceCollection where TImplementation <: Object {
        add(ServiceDescriptor.singleton<TService, TImplementation>())
        return this
    }

    /**
     * @brief 注册一个单例工厂。
     * @param factory 用于创建单例实例的工厂。
     * @return 当前服务集合。
     * @throws UnsupportedException 当服务集合已构建时抛出。
     */
    public func addSingleton<TService>(factory: (IServiceProvider) -> TService): ServiceCollection {
        add(ServiceDescriptor.singleton<TService>(factory))
        return this
    }

    /**
     * @brief 注册一个指定服务类型和实现类型的单例工厂。
     * @param factory 用于创建实现实例的工厂。
     * @return 当前服务集合。
     * @throws UnsupportedException 当服务集合已构建时抛出。
     */
    public func addSingleton<TService, TImplementation>(factory: (IServiceProvider) -> TImplementation): ServiceCollection where TImplementation <: Object {
        add(ServiceDescriptor.singleton<TService, TImplementation>(factory))
        return this
    }

    /**
     * @brief 将指定运行时类型按自身类型注册为单例。
     * @param serviceType 要注册的服务类型。
     * @return 当前服务集合。
     * @throws UnsupportedException 当服务集合已构建时抛出。
     */
    public func addSingleton(serviceType: TypeInfo): ServiceCollection {
        add(ServiceDescriptor.singleton(serviceType, serviceType))
        return this
    }

    /**
     * @brief 将指定运行时类型按单例映射方式注册。
     * @param serviceType 要注册的服务类型。
     * @param implementationType 对应的实现类型。
     * @return 当前服务集合。
     * @throws UnsupportedException 当服务集合已构建时抛出。
     */
    public func addSingleton(serviceType: TypeInfo, implementationType: TypeInfo): ServiceCollection {
        add(ServiceDescriptor.singleton(serviceType, implementationType))
        return this
    }

    /**
     * @brief 仅当服务尚未注册时添加一个单例实例。
     * @param instance 要注册的单例实例。
     * @return 当前服务集合。
     * @throws UnsupportedException 当服务集合已构建时抛出。
     */
    public func tryAddSingleton<TService>(instance: TService): ServiceCollection where TService <: Object {
        tryAdd(ServiceDescriptor.singleton<TService>(instance))
        return this
    }

    /**
     * @brief 仅当服务尚未注册时添加一个单例类型映射。
     * @return 当前服务集合。
     * @throws UnsupportedException 当服务集合已构建时抛出。
     */
    public func tryAddSingleton<TService, TImplementation>(): ServiceCollection where TImplementation <: Object {
        tryAdd(ServiceDescriptor.singleton<TService, TImplementation>())
        return this
    }

    /**
     * @brief 仅当服务尚未注册时添加一个指定实现实例的单例。
     * @param instance 要注册的实现实例。
     * @return 当前服务集合。
     * @throws UnsupportedException 当服务集合已构建时抛出。
     */
    public func tryAddSingleton<TService, TImplementation>(instance: TImplementation): ServiceCollection where TImplementation <: Object {
        tryAdd(ServiceDescriptor.singleton<TService, TImplementation>(instance))
        return this
    }

    /**
     * @brief 仅当服务尚未注册时添加一个单例工厂。
     * @param factory 用于创建单例实例的工厂。
     * @return 当前服务集合。
     * @throws UnsupportedException 当服务集合已构建时抛出。
     */
    public func tryAddSingleton<TService>(factory: (IServiceProvider) -> TService): ServiceCollection {
        tryAdd(ServiceDescriptor.singleton<TService>(factory))
        return this
    }

    /**
     * @brief 仅当服务尚未注册时添加一个指定实现类型的单例工厂。
     * @param factory 用于创建实现实例的工厂。
     * @return 当前服务集合。
     * @throws UnsupportedException 当服务集合已构建时抛出。
     */
    public func tryAddSingleton<TService, TImplementation>(factory: (IServiceProvider) -> TImplementation): ServiceCollection where TImplementation <: Object {
        tryAdd(ServiceDescriptor.singleton<TService, TImplementation>(factory))
        return this
    }

    /**
     * @brief 仅当服务尚未注册时按自身类型添加单例。
     * @param serviceType 要注册的服务类型。
     * @return 当前服务集合。
     * @throws UnsupportedException 当服务集合已构建时抛出。
     */
    public func tryAddSingleton(serviceType: TypeInfo): ServiceCollection {
        tryAdd(ServiceDescriptor.singleton(serviceType, serviceType))
        return this
    }

    /**
     * @brief 仅当服务尚未注册时按运行时类型添加单例映射。
     * @param serviceType 要注册的服务类型。
     * @param implementationType 对应的实现类型。
     * @return 当前服务集合。
     * @throws UnsupportedException 当服务集合已构建时抛出。
     */
    public func tryAddSingleton(serviceType: TypeInfo, implementationType: TypeInfo): ServiceCollection {
        tryAdd(ServiceDescriptor.singleton(serviceType, implementationType))
        return this
    }

    /**
     * @brief 注册一个指定服务类型和实现类型的作用域映射。
     * @return 当前服务集合。
     * @throws UnsupportedException 当服务集合已构建时抛出。
     */
    public func addScoped<TService, TImplementation>(): ServiceCollection where TImplementation <: Object {
        add(ServiceDescriptor.scoped<TService, TImplementation>())
        return this
    }

    /**
     * @brief 注册一个作用域工厂。
     * @param factory 用于创建作用域实例的工厂。
     * @return 当前服务集合。
     * @throws UnsupportedException 当服务集合已构建时抛出。
     */
    public func addScoped<TService>(factory: (IServiceProvider) -> TService): ServiceCollection {
        add(ServiceDescriptor.scoped<TService>(factory))
        return this
    }

    /**
     * @brief 注册一个指定服务类型和实现类型的作用域工厂。
     * @param factory 用于创建实现实例的工厂。
     * @return 当前服务集合。
     * @throws UnsupportedException 当服务集合已构建时抛出。
     */
    public func addScoped<TService, TImplementation>(factory: (IServiceProvider) -> TImplementation): ServiceCollection where TImplementation <: Object {
        add(ServiceDescriptor.scoped<TService, TImplementation>(factory))
        return this
    }

    /**
     * @brief 将指定运行时类型按自身类型注册为作用域服务。
     * @param serviceType 要注册的服务类型。
     * @return 当前服务集合。
     * @throws UnsupportedException 当服务集合已构建时抛出。
     */
    public func addScoped(serviceType: TypeInfo): ServiceCollection {
        add(ServiceDescriptor.scoped(serviceType, serviceType))
        return this
    }

    /**
     * @brief 将指定运行时类型按作用域映射方式注册。
     * @param serviceType 要注册的服务类型。
     * @param implementationType 对应的实现类型。
     * @return 当前服务集合。
     * @throws UnsupportedException 当服务集合已构建时抛出。
     */
    public func addScoped(serviceType: TypeInfo, implementationType: TypeInfo): ServiceCollection {
        add(ServiceDescriptor.scoped(serviceType, implementationType))
        return this
    }

    /**
     * @brief 仅当服务尚未注册时添加一个作用域类型映射。
     * @return 当前服务集合。
     * @throws UnsupportedException 当服务集合已构建时抛出。
     */
    public func tryAddScoped<TService, TImplementation>(): ServiceCollection where TImplementation <: Object {
        tryAdd(ServiceDescriptor.scoped<TService, TImplementation>())
        return this
    }

    /**
     * @brief 仅当服务尚未注册时添加一个作用域工厂。
     * @param factory 用于创建作用域实例的工厂。
     * @return 当前服务集合。
     * @throws UnsupportedException 当服务集合已构建时抛出。
     */
    public func tryAddScoped<TService>(factory: (IServiceProvider) -> TService): ServiceCollection {
        tryAdd(ServiceDescriptor.scoped<TService>(factory))
        return this
    }

    /**
     * @brief 仅当服务尚未注册时添加一个指定实现类型的作用域工厂。
     * @param factory 用于创建实现实例的工厂。
     * @return 当前服务集合。
     * @throws UnsupportedException 当服务集合已构建时抛出。
     */
    public func tryAddScoped<TService, TImplementation>(factory: (IServiceProvider) -> TImplementation): ServiceCollection where TImplementation <: Object {
        tryAdd(ServiceDescriptor.scoped<TService, TImplementation>(factory))
        return this
    }

    /**
     * @brief 仅当服务尚未注册时按自身类型添加作用域服务。
     * @param serviceType 要注册的服务类型。
     * @return 当前服务集合。
     * @throws UnsupportedException 当服务集合已构建时抛出。
     */
    public func tryAddScoped(serviceType: TypeInfo): ServiceCollection {
        tryAdd(ServiceDescriptor.scoped(serviceType, serviceType))
        return this
    }

    /**
     * @brief 仅当服务尚未注册时按运行时类型添加作用域映射。
     * @param serviceType 要注册的服务类型。
     * @param implementationType 对应的实现类型。
     * @return 当前服务集合。
     * @throws UnsupportedException 当服务集合已构建时抛出。
     */
    public func tryAddScoped(serviceType: TypeInfo, implementationType: TypeInfo): ServiceCollection {
        tryAdd(ServiceDescriptor.scoped(serviceType, implementationType))
        return this
    }

    /**
     * @brief 注册一个指定服务类型和实现类型的瞬时映射。
     * @return 当前服务集合。
     * @throws UnsupportedException 当服务集合已构建时抛出。
     */
    public func addTransient<TService, TImplementation>(): ServiceCollection {
        add(ServiceDescriptor.transient<TService, TImplementation>())
        return this
    }

    /**
     * @brief 注册一个瞬时工厂。
     * @param factory 用于创建瞬时实例的工厂。
     * @return 当前服务集合。
     * @throws UnsupportedException 当服务集合已构建时抛出。
     */
    public func addTransient<TService>(factory: (IServiceProvider) -> TService): ServiceCollection {
        add(ServiceDescriptor.transient<TService>(factory))
        return this
    }

    /**
     * @brief 注册一个指定服务类型和实现类型的瞬时工厂。
     * @param factory 用于创建实现实例的工厂。
     * @return 当前服务集合。
     * @throws UnsupportedException 当服务集合已构建时抛出。
     */
    public func addTransient<TService, TImplementation>(factory: (IServiceProvider) -> TImplementation): ServiceCollection where TImplementation <: Object {
        add(ServiceDescriptor.transient<TService, TImplementation>(factory))
        return this
    }

    /**
     * @brief 将指定运行时类型按自身类型注册为瞬时服务。
     * @param serviceType 要注册的服务类型。
     * @return 当前服务集合。
     * @throws UnsupportedException 当服务集合已构建时抛出。
     */
    public func addTransient(serviceType: TypeInfo): ServiceCollection {
        add(ServiceDescriptor.transient(serviceType, serviceType))
        return this
    }

    /**
     * @brief 将指定运行时类型按瞬时映射方式注册。
     * @param serviceType 要注册的服务类型。
     * @param implementationType 对应的实现类型。
     * @return 当前服务集合。
     * @throws UnsupportedException 当服务集合已构建时抛出。
     */
    public func addTransient(serviceType: TypeInfo, implementationType: TypeInfo): ServiceCollection {
        add(ServiceDescriptor.transient(serviceType, implementationType))
        return this
    }

    /**
     * @brief 仅当服务尚未注册时添加一个瞬时类型映射。
     * @return 当前服务集合。
     * @throws UnsupportedException 当服务集合已构建时抛出。
     */
    public func tryAddTransient<TService, TImplementation>(): ServiceCollection where TImplementation <: Object {
        tryAdd(ServiceDescriptor.transient<TService, TImplementation>())
        return this
    }

    /**
     * @brief 仅当服务尚未注册时添加一个瞬时工厂。
     * @param factory 用于创建瞬时实例的工厂。
     * @return 当前服务集合。
     * @throws UnsupportedException 当服务集合已构建时抛出。
     */
    public func tryAddTransient<TService>(factory: (IServiceProvider) -> TService): ServiceCollection {
        tryAdd(ServiceDescriptor.transient<TService>(factory))
        return this
    }

    /**
     * @brief 仅当服务尚未注册时添加一个指定实现类型的瞬时工厂。
     * @param factory 用于创建实现实例的工厂。
     * @return 当前服务集合。
     * @throws UnsupportedException 当服务集合已构建时抛出。
     */
    public func tryAddTransient<TService, TImplementation>(factory: (IServiceProvider) -> TImplementation): ServiceCollection where TImplementation <: Object {
        tryAdd(ServiceDescriptor.transient<TService, TImplementation>(factory))
        return this
    }

    /**
     * @brief 仅当服务尚未注册时按自身类型添加瞬时服务。
     * @param serviceType 要注册的服务类型。
     * @return 当前服务集合。
     * @throws UnsupportedException 当服务集合已构建时抛出。
     */
    public func tryAddTransient(serviceType: TypeInfo): ServiceCollection {
        tryAdd(ServiceDescriptor.transient(serviceType, serviceType))
        return this
    }

    /**
     * @brief 仅当服务尚未注册时按运行时类型添加瞬时映射。
     * @param serviceType 要注册的服务类型。
     * @param implementationType 对应的实现类型。
     * @return 当前服务集合。
     * @throws UnsupportedException 当服务集合已构建时抛出。
     */
    public func tryAddTransient(serviceType: TypeInfo, implementationType: TypeInfo): ServiceCollection {
        tryAdd(ServiceDescriptor.transient(serviceType, implementationType))
        return this
    }

    /**
     * @brief 仅当相同服务类型、实现类型和服务键尚未注册时添加服务描述。
     * @param descriptor 要尝试添加的服务描述。
     * @return 当前服务集合。
     * @throws IllegalArgumentException 当实现类型与服务类型不可区分时抛出。
     * @throws UnsupportedException 当服务集合已构建时抛出。
     */
    public func tryAddEnumerable(descriptor: ServiceDescriptor): ServiceCollection {
        let implementationType = descriptor.getImplementationType()
        if (implementationType == TypeInfo.of<Object>() || implementationType == TypeInfo.of<Any>() ||
            implementationType == descriptor.serviceType) {
            throw IllegalArgumentException(
                "Implementation type cannot be '${implementationType}' because it is indistinguishable from other services registered for '${descriptor.serviceType}'.")
        }
        for (index in 0..this.size) {
            if (this[index].serviceType == descriptor.serviceType && this[index].implementationType == implementationType &&
                this[index].serviceKey == descriptor.serviceKey) {
                return this
            }
        }
        add(descriptor)
        return this
    }

    /**
     * @brief 仅当各项描述尚未重复注册时批量添加服务描述。
     * @param descriptors 要尝试添加的服务描述集合。
     * @return 当前服务集合。
     * @throws IllegalArgumentException 当某项实现类型与服务类型不可区分时抛出。
     * @throws UnsupportedException 当服务集合已构建时抛出。
     */
    public func tryAddEnumerable(descriptors: Collection<ServiceDescriptor>): ServiceCollection {
        for (descriptor in descriptors) {
            tryAddEnumerable(descriptor)
        }
        return this
    }
}

extend ServiceCollection {
    /**
     * @brief 注册一个带键的单例实例。
     * @param serviceKey 要绑定的服务键。
     * @param instance 要注册的单例实例。
     * @return 当前服务集合。
     * @throws UnsupportedException 当服务集合已构建时抛出。
     */
    public func addKeyedSingleton<TService>(serviceKey: String, instance: TService): ServiceCollection {
        add(ServiceDescriptor.keyedSingleton<TService>(serviceKey, instance))
        return this
    }

    /**
     * @brief 注册一个指定服务类型和实现实例的带键单例。
     * @param serviceKey 要绑定的服务键。
     * @param instance 要注册的实现实例。
     * @return 当前服务集合。
     * @throws UnsupportedException 当服务集合已构建时抛出。
     */
    public func addKeyedSingleton<TService, TImplementation>(serviceKey: String, instance: TImplementation): ServiceCollection where TImplementation <: Object {
        add(ServiceDescriptor.keyedSingleton<TService, TImplementation>(serviceKey, instance))
        return this
    }

    /**
     * @brief 注册一个指定服务类型和实现类型的带键单例映射。
     * @param serviceKey 要绑定的服务键。
     * @return 当前服务集合。
     * @throws UnsupportedException 当服务集合已构建时抛出。
     */
    public func addKeyedSingleton<TService, TImplementation>(serviceKey: String): ServiceCollection where TImplementation <: Object {
        add(ServiceDescriptor.keyedSingleton<TService, TImplementation>(serviceKey))
        return this
    }

    /**
     * @brief 注册一个带键的单例工厂。
     * @param serviceKey 要绑定的服务键。
     * @param factory 用于创建单例实例的工厂。
     * @return 当前服务集合。
     * @throws UnsupportedException 当服务集合已构建时抛出。
     */
    public func addKeyedSingleton<TService>(serviceKey: String, factory: (IServiceProvider) -> TService): ServiceCollection {
        add(ServiceDescriptor.keyedSingleton<TService>(serviceKey, factory))
        return this
    }

    /**
     * @brief 注册一个指定服务类型和实现类型的带键单例工厂。
     * @param serviceKey 要绑定的服务键。
     * @param factory 用于创建实现实例的工厂。
     * @return 当前服务集合。
     * @throws UnsupportedException 当服务集合已构建时抛出。
     */
    public func addKeyedSingleton<TService, TImplementation>(serviceKey: String,
        factory: (IServiceProvider) -> TImplementation): ServiceCollection where TImplementation <: Object {
        add(ServiceDescriptor.keyedSingleton<TService, TImplementation>(serviceKey, factory))
        return this
    }

    /**
     * @brief 将指定运行时类型按自身类型注册为带键单例。
     * @param serviceKey 要绑定的服务键。
     * @param serviceType 要注册的服务类型。
     * @return 当前服务集合。
     * @throws UnsupportedException 当服务集合已构建时抛出。
     */
    public func addKeyedSingleton(serviceKey: String, serviceType: TypeInfo): ServiceCollection {
        add(ServiceDescriptor.keyedSingleton(serviceKey, serviceType, serviceType))
        return this
    }

    /**
     * @brief 将指定运行时类型按带键单例映射方式注册。
     * @param serviceKey 要绑定的服务键。
     * @param serviceType 要注册的服务类型。
     * @param implementationType 对应的实现类型。
     * @return 当前服务集合。
     * @throws UnsupportedException 当服务集合已构建时抛出。
     */
    public func addKeyedSingleton(serviceKey: String, serviceType: TypeInfo, implementationType: TypeInfo): ServiceCollection {
        add(ServiceDescriptor.keyedSingleton(serviceKey, serviceType, implementationType))
        return this
    }

    /**
     * @brief 仅当服务尚未注册时添加一个带键单例实例。
     * @param serviceKey 要绑定的服务键。
     * @param instance 要注册的单例实例。
     * @return 当前服务集合。
     * @throws UnsupportedException 当服务集合已构建时抛出。
     */
    public func tryAddKeyedSingleton<TService>(serviceKey: String, instance: TService): ServiceCollection where TService <: Object {
        tryAdd(ServiceDescriptor.keyedSingleton<TService>(serviceKey, instance))
        return this
    }

    /**
     * @brief 仅当服务尚未注册时添加一个带键单例类型映射。
     * @param serviceKey 要绑定的服务键。
     * @return 当前服务集合。
     * @throws UnsupportedException 当服务集合已构建时抛出。
     */
    public func tryAddKeyedSingleton<TService, TImplementation>(serviceKey: String): ServiceCollection where TImplementation <: Object {
        tryAdd(ServiceDescriptor.keyedSingleton<TService, TImplementation>(serviceKey))
        return this
    }

    /**
     * @brief 仅当服务尚未注册时添加一个指定实现实例的带键单例。
     * @param serviceKey 要绑定的服务键。
     * @param instance 要注册的实现实例。
     * @return 当前服务集合。
     * @throws UnsupportedException 当服务集合已构建时抛出。
     */
    public func tryAddKeyedSingleton<TService, TImplementation>(serviceKey: String, instance: TImplementation): ServiceCollection where TImplementation <: Object {
        tryAdd(ServiceDescriptor.keyedSingleton<TService, TImplementation>(serviceKey, instance))
        return this
    }

    /**
     * @brief 仅当服务尚未注册时添加一个带键单例工厂。
     * @param serviceKey 要绑定的服务键。
     * @param factory 用于创建单例实例的工厂。
     * @return 当前服务集合。
     * @throws UnsupportedException 当服务集合已构建时抛出。
     */
    public func tryAddKeyedSingleton<TService>(serviceKey: String, factory: (IServiceProvider) -> TService): ServiceCollection {
        tryAdd(ServiceDescriptor.keyedSingleton<TService>(serviceKey, factory))
        return this
    }

    /**
     * @brief 仅当服务尚未注册时添加一个指定实现类型的带键单例工厂。
     * @param serviceKey 要绑定的服务键。
     * @param factory 用于创建实现实例的工厂。
     * @return 当前服务集合。
     * @throws UnsupportedException 当服务集合已构建时抛出。
     */
    public func tryAddKeyedSingleton<TService, TImplementation>(serviceKey: String,
        factory: (IServiceProvider) -> TImplementation): ServiceCollection where TImplementation <: Object {
        tryAdd(ServiceDescriptor.keyedSingleton<TService, TImplementation>(serviceKey, factory))
        return this
    }

    /**
     * @brief 仅当服务尚未注册时按自身类型添加带键单例。
     * @param serviceKey 要绑定的服务键。
     * @param serviceType 要注册的服务类型。
     * @return 当前服务集合。
     * @throws UnsupportedException 当服务集合已构建时抛出。
     */
    public func tryAddKeyedSingleton(serviceKey: String, serviceType: TypeInfo): ServiceCollection {
        tryAdd(ServiceDescriptor.keyedSingleton(serviceKey, serviceType, serviceType))
        return this
    }

    /**
     * @brief 仅当服务尚未注册时按运行时类型添加带键单例映射。
     * @param serviceKey 要绑定的服务键。
     * @param serviceType 要注册的服务类型。
     * @param implementationType 对应的实现类型。
     * @return 当前服务集合。
     * @throws UnsupportedException 当服务集合已构建时抛出。
     */
    public func tryAddKeyedSingleton(serviceKey: String, serviceType: TypeInfo, implementationType: TypeInfo): ServiceCollection {
        tryAdd(ServiceDescriptor.keyedSingleton(serviceKey, serviceType, implementationType))
        return this
    }

    /**
     * @brief 注册一个指定服务类型和实现类型的带键作用域映射。
     * @param serviceKey 要绑定的服务键。
     * @return 当前服务集合。
     * @throws UnsupportedException 当服务集合已构建时抛出。
     */
    public func addKeyedScoped<TService, TImplementation>(serviceKey: String): ServiceCollection where TImplementation <: Object {
        add(ServiceDescriptor.keyedScoped<TService, TImplementation>(serviceKey))
        return this
    }

    /**
     * @brief 注册一个带键的作用域工厂。
     * @param serviceKey 要绑定的服务键。
     * @param factory 用于创建作用域实例的工厂。
     * @return 当前服务集合。
     * @throws UnsupportedException 当服务集合已构建时抛出。
     */
    public func addKeyedScoped<TService>(serviceKey: String, factory: (IServiceProvider) -> TService): ServiceCollection {
        add(ServiceDescriptor.keyedScoped<TService>(serviceKey, factory))
        return this
    }

    /**
     * @brief 注册一个指定服务类型和实现类型的带键作用域工厂。
     * @param serviceKey 要绑定的服务键。
     * @param factory 用于创建实现实例的工厂。
     * @return 当前服务集合。
     * @throws UnsupportedException 当服务集合已构建时抛出。
     */
    public func addKeyedScoped<TService, TImplementation>(serviceKey: String,
        factory: (IServiceProvider) -> TImplementation): ServiceCollection where TImplementation <: Object {
        add(ServiceDescriptor.keyedScoped<TService, TImplementation>(serviceKey, factory))
        return this
    }

    /**
     * @brief 将指定运行时类型按自身类型注册为带键作用域服务。
     * @param serviceKey 要绑定的服务键。
     * @param serviceType 要注册的服务类型。
     * @return 当前服务集合。
     * @throws UnsupportedException 当服务集合已构建时抛出。
     */
    public func addKeyedScoped(serviceKey: String, serviceType: TypeInfo): ServiceCollection {
        add(ServiceDescriptor.keyedScoped(serviceKey, serviceType, serviceType))
        return this
    }

    /**
     * @brief 将指定运行时类型按带键作用域映射方式注册。
     * @param serviceKey 要绑定的服务键。
     * @param serviceType 要注册的服务类型。
     * @param implementationType 对应的实现类型。
     * @return 当前服务集合。
     * @throws UnsupportedException 当服务集合已构建时抛出。
     */
    public func addKeyedScoped(serviceKey: String, serviceType: TypeInfo, implementationType: TypeInfo): ServiceCollection {
        add(ServiceDescriptor.keyedScoped(serviceKey, serviceType, implementationType))
        return this
    }

    /**
     * @brief 仅当服务尚未注册时添加一个带键作用域类型映射。
     * @param serviceKey 要绑定的服务键。
     * @return 当前服务集合。
     * @throws UnsupportedException 当服务集合已构建时抛出。
     */
    public func tryAddKeyedScoped<TService, TImplementation>(serviceKey: String): ServiceCollection where TImplementation <: Object {
        tryAdd(ServiceDescriptor.keyedScoped<TService, TImplementation>(serviceKey))
        return this
    }

    /**
     * @brief 仅当服务尚未注册时添加一个带键作用域工厂。
     * @param serviceKey 要绑定的服务键。
     * @param factory 用于创建作用域实例的工厂。
     * @return 当前服务集合。
     * @throws UnsupportedException 当服务集合已构建时抛出。
     */
    public func tryAddKeyedScoped<TService>(serviceKey: String, factory: (IServiceProvider) -> TService): ServiceCollection {
        tryAdd(ServiceDescriptor.keyedScoped<TService>(serviceKey, factory))
        return this
    }

    /**
     * @brief 仅当服务尚未注册时添加一个指定实现类型的带键作用域工厂。
     * @param serviceKey 要绑定的服务键。
     * @param factory 用于创建实现实例的工厂。
     * @return 当前服务集合。
     * @throws UnsupportedException 当服务集合已构建时抛出。
     */
    public func tryAddKeyedScoped<TService, TImplementation>(serviceKey: String,
        factory: (IServiceProvider) -> TImplementation): ServiceCollection where TImplementation <: Object {
        tryAdd(ServiceDescriptor.keyedScoped<TService, TImplementation>(serviceKey, factory))
        return this
    }

    /**
     * @brief 仅当服务尚未注册时按自身类型添加带键作用域服务。
     * @param serviceKey 要绑定的服务键。
     * @param serviceType 要注册的服务类型。
     * @return 当前服务集合。
     * @throws UnsupportedException 当服务集合已构建时抛出。
     */
    public func tryAddKeyedScoped(serviceKey: String, serviceType: TypeInfo): ServiceCollection {
        tryAdd(ServiceDescriptor.keyedScoped(serviceKey, serviceType, serviceType))
        return this
    }

    /**
     * @brief 仅当服务尚未注册时按运行时类型添加带键作用域映射。
     * @param serviceKey 要绑定的服务键。
     * @param serviceType 要注册的服务类型。
     * @param implementationType 对应的实现类型。
     * @return 当前服务集合。
     * @throws UnsupportedException 当服务集合已构建时抛出。
     */
    public func tryAddKeyedScoped(serviceKey: String, serviceType: TypeInfo, implementationType: TypeInfo): ServiceCollection {
        tryAdd(ServiceDescriptor.keyedScoped(serviceKey, serviceType, implementationType))
        return this
    }

    /**
     * @brief 注册一个指定服务类型和实现类型的带键瞬时映射。
     * @param serviceKey 要绑定的服务键。
     * @return 当前服务集合。
     * @throws UnsupportedException 当服务集合已构建时抛出。
     */
    public func addKeyedTransient<TService, TImplementation>(serviceKey: String): ServiceCollection {
        add(ServiceDescriptor.keyedTransient<TService, TImplementation>(serviceKey))
        return this
    }

    /**
     * @brief 注册一个带键的瞬时工厂。
     * @param serviceKey 要绑定的服务键。
     * @param factory 用于创建瞬时实例的工厂。
     * @return 当前服务集合。
     * @throws UnsupportedException 当服务集合已构建时抛出。
     */
    public func addKeyedTransient<TService>(serviceKey: String, factory: (IServiceProvider) -> TService): ServiceCollection {
        add(ServiceDescriptor.keyedTransient<TService>(serviceKey, factory))
        return this
    }

    /**
     * @brief 注册一个指定服务类型和实现类型的带键瞬时工厂。
     * @param serviceKey 要绑定的服务键。
     * @param factory 用于创建实现实例的工厂。
     * @return 当前服务集合。
     * @throws UnsupportedException 当服务集合已构建时抛出。
     */
    public func addKeyedTransient<TService, TImplementation>(serviceKey: String,
        factory: (IServiceProvider) -> TImplementation): ServiceCollection where TImplementation <: Object {
        add(ServiceDescriptor.keyedTransient<TService, TImplementation>(serviceKey, factory))
        return this
    }

    /**
     * @brief 将指定运行时类型按自身类型注册为带键瞬时服务。
     * @param serviceKey 要绑定的服务键。
     * @param serviceType 要注册的服务类型。
     * @return 当前服务集合。
     * @throws UnsupportedException 当服务集合已构建时抛出。
     */
    public func addKeyedTransient(serviceKey: String, serviceType: TypeInfo): ServiceCollection {
        add(ServiceDescriptor.keyedTransient(serviceKey, serviceType, serviceType))
        return this
    }

    /**
     * @brief 将指定运行时类型按带键瞬时映射方式注册。
     * @param serviceKey 要绑定的服务键。
     * @param serviceType 要注册的服务类型。
     * @param implementationType 对应的实现类型。
     * @return 当前服务集合。
     * @throws UnsupportedException 当服务集合已构建时抛出。
     */
    public func addKeyedTransient(serviceKey: String, serviceType: TypeInfo, implementationType: TypeInfo): ServiceCollection {
        add(ServiceDescriptor.keyedTransient(serviceKey, serviceType, implementationType))
        return this
    }

    /**
     * @brief 仅当服务尚未注册时添加一个带键瞬时类型映射。
     * @param serviceKey 要绑定的服务键。
     * @return 当前服务集合。
     * @throws UnsupportedException 当服务集合已构建时抛出。
     */
    public func tryAddKeyedTransient<TService, TImplementation>(serviceKey: String): ServiceCollection where TImplementation <: Object {
        tryAdd(ServiceDescriptor.keyedTransient<TService, TImplementation>(serviceKey))
        return this
    }

    /**
     * @brief 仅当服务尚未注册时添加一个带键瞬时工厂。
     * @param serviceKey 要绑定的服务键。
     * @param factory 用于创建瞬时实例的工厂。
     * @return 当前服务集合。
     * @throws UnsupportedException 当服务集合已构建时抛出。
     */
    public func tryAddKeyedTransient<TService>(serviceKey: String, factory: (IServiceProvider) -> TService): ServiceCollection {
        tryAdd(ServiceDescriptor.keyedTransient<TService>(serviceKey, factory))
        return this
    }

    /**
     * @brief 仅当服务尚未注册时添加一个指定实现类型的带键瞬时工厂。
     * @param serviceKey 要绑定的服务键。
     * @param factory 用于创建实现实例的工厂。
     * @return 当前服务集合。
     * @throws UnsupportedException 当服务集合已构建时抛出。
     */
    public func tryAddKeyedTransient<TService, TImplementation>(serviceKey: String,
        factory: (IServiceProvider) -> TImplementation): ServiceCollection where TImplementation <: Object {
        tryAdd(ServiceDescriptor.keyedTransient<TService, TImplementation>(serviceKey, factory))
        return this
    }

    /**
     * @brief 仅当服务尚未注册时按自身类型添加带键瞬时服务。
     * @param serviceKey 要绑定的服务键。
     * @param serviceType 要注册的服务类型。
     * @return 当前服务集合。
     * @throws UnsupportedException 当服务集合已构建时抛出。
     */
    public func tryAddKeyedTransient(serviceKey: String, serviceType: TypeInfo): ServiceCollection {
        tryAdd(ServiceDescriptor.keyedTransient(serviceKey, serviceType, serviceType))
        return this
    }

    /**
     * @brief 仅当服务尚未注册时按运行时类型添加带键瞬时映射。
     * @param serviceKey 要绑定的服务键。
     * @param serviceType 要注册的服务类型。
     * @param implementationType 对应的实现类型。
     * @return 当前服务集合。
     * @throws UnsupportedException 当服务集合已构建时抛出。
     */
    public func tryAddKeyedTransient(serviceKey: String, serviceType: TypeInfo, implementationType: TypeInfo): ServiceCollection {
        tryAdd(ServiceDescriptor.keyedTransient(serviceKey, serviceType, implementationType))
        return this
    }
}

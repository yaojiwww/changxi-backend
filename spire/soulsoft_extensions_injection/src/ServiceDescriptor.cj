// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_injection

import std.reflect.*
import std.collection.*

/**
 * @brief 表示一条服务注册描述。
 */
public class ServiceDescriptor <: ToString {
    private let _serviceKey: ?String
    private let _serviceType: TypeInfo
    private let _implementationType: ?TypeInfo
    private let _implementationInstance: ?Object
    private let _implementationFactory: ?(IServiceProvider) -> Any
    private let _lifetime: ServiceLifetime

    internal init(serviceKey: ?String, serviceType: TypeInfo, instance: Any) {
        let implType = ClassTypeInfo.of(instance)
        ServiceDescriptor.requireSubtype(serviceType, implType)
        _serviceKey = serviceKey
        _serviceType = serviceType
        _implementationType = None
        _implementationFactory = None
        _implementationInstance = (instance as Object).getOrThrow()
        _lifetime = ServiceLifetime.Singleton
    }

    internal init(serviceKey: ?String, serviceType: TypeInfo, implementationType: ?TypeInfo, lifetime: ServiceLifetime,
        factory: (IServiceProvider) -> Any) {
        if (let Some(implType) <- implementationType) {
            ServiceDescriptor.requireSubtype(serviceType, implType)
        }
        _serviceKey = serviceKey
        _serviceType = serviceType
        _implementationType = implementationType
        _implementationFactory = factory
        _implementationInstance = None
        _lifetime = lifetime
    }

    internal init(serviceKey: ?String, serviceType: TypeInfo, implementationType: TypeInfo, lifetime: ServiceLifetime) {
        ServiceDescriptor.requireSubtype(serviceType, implementationType)
        _serviceKey = serviceKey
        _serviceType = serviceType
        _implementationType = implementationType
        _implementationFactory = None
        _implementationInstance = None
        _lifetime = lifetime
    }

    /**
     * @brief 返回当前描述使用的服务键。
     * @return 当前服务键；非带键服务时返回 `None`。
     */
    public prop serviceKey: ?String {
        get() {
            _serviceKey
        }
    }

    /**
     * @brief 返回当前描述对应的服务类型。
     * @return 当前描述注册的服务类型。
     */
    public prop serviceType: TypeInfo {
        get() {
            _serviceType
        }
    }

    /**
     * @brief 返回当前描述使用的实现类型。
     * @return 当前描述对应的实现类型；实例注册或无法确定时返回 `None`。
     */
    public prop implementationType: ?TypeInfo {
        get() {
            _implementationType
        }
    }

    /**
     * @brief 返回当前描述使用的服务生命周期。
     * @return 当前描述对应的生命周期值。
     */
    public prop lifetime: ServiceLifetime {
        get() {
            _lifetime
        }
    }

    /**
     * @brief 返回当前描述绑定的实现实例。
     * @return 当前描述绑定的实例；非实例注册时返回 `None`。
     */
    public prop implementationInstance: ?Object {
        get() {
            _implementationInstance
        }
    }

    /**
     * @brief 返回当前描述绑定的实现工厂。
     * @return 当前描述绑定的工厂；非工厂注册时返回 `None`。
     */
    public prop implementationFactory: ?(IServiceProvider) -> Any {
        get() {
            _implementationFactory
        }
    }

    /**
     * @brief 检查当前描述是否表示带键服务。
     * @return 如果当前描述包含服务键则返回 `true`，否则返回 `false`。
     */
    public prop isKeyedService: Bool {
        get() {
            serviceKey.isSome()
        }
    }

    protected func getImplementationType(): ?TypeInfo {
        if (let Some(implementationType) <- implementationType) {
            return implementationType
        } else if (let Some(implementationInstance) <- implementationInstance) {
            return ClassTypeInfo.of(implementationInstance)
        } else if (let Some(implementationFactory) <- implementationFactory) {
            return FunctionTypeInfo.of(implementationFactory).returnType
        } else {
            return None
        }
    }

    /**
     * @brief 返回当前服务描述的字符串表示。
     * @return 当前描述的字符串形式。
     */
    public func toString(): String {
        if (let Some(serviceKey) <- serviceKey) {
            return "${serviceKey}:${serviceType}"
        }
        return serviceType.toString()
    }

    private static func requireSubtype(serviceType: TypeInfo, implementationType: TypeInfo) {
        if (!implementationType.isSubtypeOf(serviceType)) {
            throw UnsupportedException(
                "The implementation type '${implementationType}' is not a subtype of the service type '${serviceType}'. ")
        }
    }
}

extend ServiceDescriptor {
    /**
     * @brief 创建一个单例实例注册描述。
     * @param instance 要注册的单例实例。
     * @return 创建得到的服务描述。
     */
    public static func singleton<TService>(instance: TService): ServiceDescriptor {
        return ServiceDescriptor(None, TypeInfo.of<TService>(), instance)
    }

    /**
     * @brief 创建一个指定服务类型和实现实例的单例注册描述。
     * @param instance 要注册的实现实例。
     * @return 创建得到的服务描述。
     */
    public static func singleton<TService, TImplementation>(instance: TImplementation): ServiceDescriptor {
        return ServiceDescriptor(None, TypeInfo.of<TService>(), instance)
    }

    /**
     * @brief 创建一个单例工厂注册描述。
     * @param factory 用于创建服务实例的工厂。
     * @return 创建得到的服务描述。
     */
    public static func singleton<TService>(factory: (IServiceProvider) -> TService): ServiceDescriptor {
        return ServiceDescriptor(None, TypeInfo.of<TService>(), None, ServiceLifetime.Singleton,
            (factory as (IServiceProvider) -> Any).getOrThrow())
    }

    /**
     * @brief 创建一个指定服务类型和实现类型的单例工厂注册描述。
     * @param factory 用于创建服务实例的工厂。
     * @return 创建得到的服务描述。
     */
    public static func singleton<TService, TImplementation>(factory: (IServiceProvider) -> TImplementation): ServiceDescriptor where TImplementation <: Object {
        return ServiceDescriptor(None, TypeInfo.of<TService>(), TypeInfo.of<TImplementation>(),
            ServiceLifetime.Singleton, factory)
    }

    /**
     * @brief 创建一个作用域工厂注册描述。
     * @param factory 用于创建服务实例的工厂。
     * @return 创建得到的服务描述。
     */
    public static func scoped<TService>(factory: (IServiceProvider) -> TService): ServiceDescriptor {
        return ServiceDescriptor(None, TypeInfo.of<TService>(), None, ServiceLifetime.Scoped,
            (factory as (IServiceProvider) -> Any).getOrThrow())
    }

    /**
     * @brief 创建一个指定服务类型和实现类型的作用域工厂注册描述。
     * @param factory 用于创建服务实例的工厂。
     * @return 创建得到的服务描述。
     */
    public static func scoped<TService, TImplementation>(factory: (IServiceProvider) -> TImplementation): ServiceDescriptor where TImplementation <: Object {
        return ServiceDescriptor(None, TypeInfo.of<TService>(), TypeInfo.of<TImplementation>(), ServiceLifetime.Scoped,
            factory)
    }

    /**
     * @brief 创建一个瞬时工厂注册描述。
     * @param factory 用于创建服务实例的工厂。
     * @return 创建得到的服务描述。
     */
    public static func transient<TService>(factory: (IServiceProvider) -> TService): ServiceDescriptor {
        return ServiceDescriptor(None, TypeInfo.of<TService>(), None, ServiceLifetime.Transient,
            (factory as (IServiceProvider) -> Any).getOrThrow())
    }

    /**
     * @brief 创建一个指定服务类型和实现类型的瞬时工厂注册描述。
     * @param factory 用于创建服务实例的工厂。
     * @return 创建得到的服务描述。
     */
    public static func transient<TService, TImplementation>(factory: (IServiceProvider) -> TImplementation): ServiceDescriptor where TImplementation <: Object {
        return ServiceDescriptor(None, TypeInfo.of<TService>(), TypeInfo.of<TImplementation>(),
            ServiceLifetime.Transient, factory)
    }

    /**
     * @brief 创建一个指定服务类型和实现类型的作用域类型映射描述。
     * @return 创建得到的服务描述。
     */
    public static func scoped<TService, TImplementation>(): ServiceDescriptor {
        return scoped(TypeInfo.of<TService>(), TypeInfo.of<TImplementation>())
    }

    /**
     * @brief 创建一个指定服务类型和实现类型的瞬时类型映射描述。
     * @return 创建得到的服务描述。
     */
    public static func transient<TService, TImplementation>(): ServiceDescriptor {
        return transient(TypeInfo.of<TService>(), TypeInfo.of<TImplementation>())
    }

    /**
     * @brief 创建一个指定服务类型和实现类型的单例类型映射描述。
     * @return 创建得到的服务描述。
     */
    public static func singleton<TService, TImplementation>(): ServiceDescriptor {
        return singleton(TypeInfo.of<TService>(), TypeInfo.of<TImplementation>())
    }

    /**
     * @brief 创建一个基于运行时类型的作用域注册描述。
     * @param serviceType 要注册的服务类型。
     * @param implementationType 对应的实现类型。
     * @return 创建得到的服务描述。
     */
    public static func scoped(serviceType: TypeInfo, implementationType: TypeInfo): ServiceDescriptor {
        return ServiceDescriptor(None, serviceType, implementationType, ServiceLifetime.Scoped)
    }

    /**
     * @brief 创建一个基于运行时类型的瞬时注册描述。
     * @param serviceType 要注册的服务类型。
     * @param implementationType 对应的实现类型。
     * @return 创建得到的服务描述。
     */
    public static func transient(serviceType: TypeInfo, implementationType: TypeInfo): ServiceDescriptor {
        return ServiceDescriptor(None, serviceType, implementationType, ServiceLifetime.Transient)
    }

    /**
     * @brief 创建一个基于运行时类型的单例注册描述。
     * @param serviceType 要注册的服务类型。
     * @param implementationType 对应的实现类型。
     * @return 创建得到的服务描述。
     */
    public static func singleton(serviceType: TypeInfo, implementationType: TypeInfo): ServiceDescriptor {
        return ServiceDescriptor(None, serviceType, implementationType, ServiceLifetime.Singleton)
    }
}

/*
keyed
 */
extend ServiceDescriptor {
    /**
     * @brief 创建一个带键的单例实例注册描述。
     * @param serviceKey 要绑定的服务键。
     * @param instance 要注册的单例实例。
     * @return 创建得到的服务描述。
     */
    public static func keyedSingleton<TService>(serviceKey: String, instance: TService): ServiceDescriptor {
        return ServiceDescriptor(serviceKey, TypeInfo.of<TService>(), instance)
    }

    /**
     * @brief 创建一个指定服务类型和实现实例的带键单例注册描述。
     * @param serviceKey 要绑定的服务键。
     * @param instance 要注册的实现实例。
     * @return 创建得到的服务描述。
     */
    public static func keyedSingleton<TService, TImplementation>(serviceKey: String, instance: TImplementation): ServiceDescriptor {
        return ServiceDescriptor(serviceKey, TypeInfo.of<TService>(), instance)
    }

    /**
     * @brief 创建一个带键的作用域工厂注册描述。
     * @param serviceKey 要绑定的服务键。
     * @param factory 用于创建服务实例的工厂。
     * @return 创建得到的服务描述。
     */
    public static func keyedScoped<TService>(serviceKey: String, factory: (IServiceProvider) -> TService): ServiceDescriptor {
        return ServiceDescriptor(serviceKey, TypeInfo.of<TService>(), None, ServiceLifetime.Scoped,
            (factory as (IServiceProvider) -> Any).getOrThrow())
    }

    /**
     * @brief 创建一个指定服务类型和实现类型的带键作用域工厂注册描述。
     * @param serviceKey 要绑定的服务键。
     * @param factory 用于创建服务实例的工厂。
     * @return 创建得到的服务描述。
     */
    public static func keyedScoped<TService, TImplementation>(serviceKey: String,
        factory: (IServiceProvider) -> TImplementation): ServiceDescriptor where TImplementation <: Object {
        return ServiceDescriptor(serviceKey, TypeInfo.of<TService>(), TypeInfo.of<TImplementation>(),
            ServiceLifetime.Scoped, factory)
    }

    /**
     * @brief 创建一个带键的瞬时工厂注册描述。
     * @param serviceKey 要绑定的服务键。
     * @param factory 用于创建服务实例的工厂。
     * @return 创建得到的服务描述。
     */
    public static func keyedTransient<TService>(serviceKey: String, factory: (IServiceProvider) -> TService): ServiceDescriptor {
        return ServiceDescriptor(serviceKey, TypeInfo.of<TService>(), None, ServiceLifetime.Transient,
            (factory as (IServiceProvider) -> Any).getOrThrow())
    }

    /**
     * @brief 创建一个指定服务类型和实现类型的带键瞬时工厂注册描述。
     * @param serviceKey 要绑定的服务键。
     * @param factory 用于创建服务实例的工厂。
     * @return 创建得到的服务描述。
     */
    public static func keyedTransient<TService, TImplementation>(serviceKey: String,
        factory: (IServiceProvider) -> TImplementation): ServiceDescriptor where TImplementation <: Object {
        return ServiceDescriptor(serviceKey, TypeInfo.of<TService>(), TypeInfo.of<TImplementation>(),
            ServiceLifetime.Transient, factory)
    }

    /**
     * @brief 创建一个带键的单例工厂注册描述。
     * @param serviceKey 要绑定的服务键。
     * @param factory 用于创建服务实例的工厂。
     * @return 创建得到的服务描述。
     */
    public static func keyedSingleton<TService>(serviceKey: String, factory: (IServiceProvider) -> TService): ServiceDescriptor {
        return ServiceDescriptor(serviceKey, TypeInfo.of<TService>(), None, ServiceLifetime.Singleton,
            (factory as (IServiceProvider) -> Any).getOrThrow())
    }

    /**
     * @brief 创建一个指定服务类型和实现类型的带键单例工厂注册描述。
     * @param serviceKey 要绑定的服务键。
     * @param factory 用于创建服务实例的工厂。
     * @return 创建得到的服务描述。
     */
    public static func keyedSingleton<TService, TImplementation>(serviceKey: String,
        factory: (IServiceProvider) -> TImplementation): ServiceDescriptor where TImplementation <: Object {
        return ServiceDescriptor(serviceKey, TypeInfo.of<TService>(), TypeInfo.of<TImplementation>(),
            ServiceLifetime.Singleton, factory)
    }

    /**
     * @brief 创建一个指定服务类型和实现类型的带键作用域类型映射描述。
     * @param serviceKey 要绑定的服务键。
     * @return 创建得到的服务描述。
     */
    public static func keyedScoped<TService, TImplementation>(serviceKey: String): ServiceDescriptor {
        return keyedScoped(serviceKey, TypeInfo.of<TService>(), TypeInfo.of<TImplementation>())
    }

    /**
     * @brief 创建一个指定服务类型和实现类型的带键瞬时类型映射描述。
     * @param serviceKey 要绑定的服务键。
     * @return 创建得到的服务描述。
     */
    public static func keyedTransient<TService, TImplementation>(serviceKey: String): ServiceDescriptor {
        return keyedTransient(serviceKey, TypeInfo.of<TService>(), TypeInfo.of<TImplementation>())
    }

    /**
     * @brief 创建一个指定服务类型和实现类型的带键单例类型映射描述。
     * @param serviceKey 要绑定的服务键。
     * @return 创建得到的服务描述。
     */
    public static func keyedSingleton<TService, TImplementation>(serviceKey: String): ServiceDescriptor {
        return keyedSingleton(serviceKey, TypeInfo.of<TService>(), TypeInfo.of<TImplementation>())
    }

    /**
     * @brief 创建一个基于运行时类型的带键作用域注册描述。
     * @param serviceKey 要绑定的服务键。
     * @param serviceType 要注册的服务类型。
     * @param implementationType 对应的实现类型。
     * @return 创建得到的服务描述。
     */
    public static func keyedScoped(serviceKey: String, serviceType: TypeInfo, implementationType: TypeInfo): ServiceDescriptor {
        return ServiceDescriptor(serviceKey, serviceType, implementationType, ServiceLifetime.Scoped)
    }

    /**
     * @brief 创建一个基于运行时类型的带键瞬时注册描述。
     * @param serviceKey 要绑定的服务键。
     * @param serviceType 要注册的服务类型。
     * @param implementationType 对应的实现类型。
     * @return 创建得到的服务描述。
     */
    public static func keyedTransient(serviceKey: String, serviceType: TypeInfo, implementationType: TypeInfo): ServiceDescriptor {
        return ServiceDescriptor(serviceKey, serviceType, implementationType, ServiceLifetime.Transient)
    }

    /**
     * @brief 创建一个基于运行时类型的带键单例注册描述。
     * @param serviceKey 要绑定的服务键。
     * @param serviceType 要注册的服务类型。
     * @param implementationType 对应的实现类型。
     * @return 创建得到的服务描述。
     */
    public static func keyedSingleton(serviceKey: String, serviceType: TypeInfo, implementationType: TypeInfo): ServiceDescriptor {
        return ServiceDescriptor(serviceKey, serviceType, implementationType, ServiceLifetime.Singleton)
    }
}

extend ArrayList<ServiceDescriptor> {
    internal func indexOf(element: ServiceDescriptor): ?Int64 {
        for (index in 0..this.size) {
            if (refEq(this[index], element)) {
                return index
            }
        }
        return None
    }
}

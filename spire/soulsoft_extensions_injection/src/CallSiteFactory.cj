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
import std.collection.concurrent.*

/*
设计师：负责基于服务描述设计图纸
1. 生成设计图纸
2. 循环依赖检测
 */
class CallSiteFactory <: IServiceProviderIsKeyedService {
    private static let DefaultSlot = 0
    private let _descriptors: List<ServiceDescriptor>
    private let _callSiteLocks = ConcurrentHashMap<ServiceIdentifier, Mutex>()
    private let _callSiteCache = ConcurrentHashMap<ServiceCacheKey, ServiceCallSite>()
    // 该字段在容器构建时创建一次，并且容器构建是并发安全的，无需考虑并发问题
    private let _descriptorLookup = HashMap<ServiceIdentifier, ServiceDescriptorCacheItem>()

    init(descriptors: List<ServiceDescriptor>) {
        _descriptors = descriptors
        populate()
    }

    /*
    初始化服务描述，用于精细化控制
     */
    private func populate() {
        for (descriptor in _descriptors) {
            let serviceType = descriptor.serviceType
            if (let Some(implementationType) <- descriptor.implementationType) {
                if ((implementationType as ClassTypeInfo).flatMap {f => f.isAbstract()} == true ||
                    (implementationType as InterfaceTypeInfo).isSome()) {
                    throw IllegalArgumentException(
                        "Cannot instantiate implementation type '${implementationType}' for service type '${serviceType}'.")
                }
            }

            let cacheKey = ServiceIdentifier.fromDescriptor(descriptor)
            if (let Some(cacheItem) <- _descriptorLookup.get(cacheKey)) {
                //如果存在，那么基于上一次的创建新的缓存项
                _descriptorLookup[cacheKey] = cacheItem.add(descriptor)
            } else {
                let cacheItem = ServiceDescriptorCacheItem()
                _descriptorLookup[cacheKey] = cacheItem.add(descriptor)
            }
        }
    }

    public func isService(serviceType: TypeInfo): Bool {
        return isService(ServiceIdentifier.fromServiceType(serviceType))
    }

    public func isKeyedService(serviceKey: String, serviceType: TypeInfo) {
        return isService(ServiceIdentifier.fromServiceType(serviceKey, serviceType))
    }

    private func isService(identifier: ServiceIdentifier) {
        if (_descriptorLookup.contains(identifier)) {
            return true
        }
        let serviceType = identifier.serviceType
        if (GenericTypeHelper.isCollectionGenericType(serviceType)) {
            return true
        }
        return serviceType == TypeInfo.of<IServiceProvider>() || serviceType == TypeInfo.of<IServiceScopeFactory>() ||
            serviceType == TypeInfo.of<IServiceProviderIsService>() ||
            serviceType == TypeInfo.of<IServiceProviderIsKeyedService>()
    }

    public func add(identifier: ServiceIdentifier, serviceCallSite: ServiceCallSite): Unit {
        _callSiteCache.add(ServiceCacheKey(DefaultSlot, identifier), serviceCallSite)
    }

    /*
    获取图纸
     */
    public func getCallSite(identifier: ServiceIdentifier, callSiteChain: CallSiteChain): ?ServiceCallSite {
        let cacheKey = ServiceCacheKey(DefaultSlot, identifier)

        if (let Some(callSite) <- _callSiteCache.get(cacheKey)) {
            return callSite
        } else {
            return createCallSite(identifier, callSiteChain)
        }
    }

    /*
    获取图纸：用于验证时
     */
    public func getCallSite(descriptor: ServiceDescriptor, callSiteChain: CallSiteChain): ?ServiceCallSite {
        let identifier = ServiceIdentifier.fromDescriptor(descriptor)
        if (let Some(descriptorCacheItem) <- _descriptorLookup.get(identifier)) {
            return tryCreateExact(descriptor, identifier, callSiteChain, descriptorCacheItem.getSlot(descriptor))
        }
        return None
    }

    /*
    创建施工图纸，并发安全的
     */
    private func createCallSite(identifier: ServiceIdentifier, callSiteChain: CallSiteChain): ?ServiceCallSite {
        // 获取并发锁
        let callsiteLock = _callSiteLocks.entryView(identifier) {
            view => if (view.value.isNone()) {
                view.value = Mutex()
            }
        }.getOrThrow()

        synchronized(callsiteLock) {

            // 循环依赖检测
            callSiteChain.checkCircularDependency(identifier)

            let callSite: ?ServiceCallSite = tryCreateExact(identifier, callSiteChain) ?? tryCreateCollection(
                identifier, callSiteChain)

            return callSite
        }
    }

    /*
    创建施工图纸：使用默认插槽
     */
    private func tryCreateExact(identifier: ServiceIdentifier, callSiteChain: CallSiteChain): ?ServiceCallSite {
        if (let Some(descriptor) <- _descriptorLookup.get(identifier)) {
            // 最后注册的服务描述，ServiceCacheKey的插槽为0       
            return tryCreateExact(descriptor.last, identifier, callSiteChain, DefaultSlot)
        }
        return None
    }

    /*
    创建施工图纸：使用指定插槽
     */
    private func tryCreateExact(descriptor: ServiceDescriptor, identifier: ServiceIdentifier,
        callSiteChain: CallSiteChain, slot: Int64): ?ServiceCallSite {
        if (shouldCreateExact(descriptor.serviceType, identifier.serviceType)) {
            return createExact(descriptor, identifier, callSiteChain, slot)
        }

        return None
    }

    private static func shouldCreateExact(descriptorType: TypeInfo, serviceType: TypeInfo) {
        descriptorType == serviceType
    }

    /*
    创建施工图纸
     */
    private func createExact(descriptor: ServiceDescriptor, identifier: ServiceIdentifier, callSiteChain: CallSiteChain,
        slot: Int64): ServiceCallSite {
        let callSiteKey = ServiceCacheKey(slot, identifier)
        if (let Some(callSite) <- _callSiteCache.get(callSiteKey)) {
            return callSite
        }

        let lifetime = CallSiteResultCache(callSiteKey, descriptor.lifetime)

        //确定使用那个图纸模板
        let callSite = if (let Some(implementationInstance) <- descriptor.implementationInstance) {
            ConstantCallSite(descriptor.serviceKey, descriptor.serviceType, implementationInstance)
        } else if (let Some(implementationFactory) <- descriptor.implementationFactory) {
            FactoryCallSite(lifetime, descriptor.serviceKey, descriptor.serviceType, implementationFactory)
        } else if (let Some(implementationType) <- descriptor.implementationType.flatMap {f => f as ClassTypeInfo}) {
            createConstructorCallSite(lifetime, identifier, implementationType, callSiteChain)
        } else {
            throw UnsupportedException("Invalid service descriptor")
        }
        _callSiteCache[callSiteKey] = callSite
        return callSite
    }

    /*
    创建基于构造器方式的图纸
     */
    private func createConstructorCallSite(lifetime: CallSiteResultCache, identifier: ServiceIdentifier,
        implementationType: ClassTypeInfo, callSiteChain: CallSiteChain): ConstructorCallSite {
        try {
            callSiteChain.add(identifier, implementationType: implementationType)

            let constructors = implementationType.constructors.toArray()
            if (constructors.size == 0) {
                throw UnsupportedException(
                    "A suitable constructor for type '${implementationType}' could not be located. Ensure the type is concrete and services are registered for all parameters of a public constructor.")
            } else if (constructors.size == 1) {
                let constructor = constructors[0]
                let parameters = constructor.parameters
                if (parameters.size == 0) {
                    return ConstructorCallSite(lifetime, identifier.serviceKey, identifier.serviceType, constructor, [])
                }
                let parameterCallSites = createArgumentCallSites(identifier, implementationType, callSiteChain,
                    parameters, true)
                return ConstructorCallSite(lifetime, identifier.serviceKey, identifier.serviceType, constructor,
                    parameterCallSites.getOrThrow())
            }

            /*
            计算出最匹配的构造器
                1. 默认以第一个匹配项为准
                2. 如果出现多个匹配项，那么检查依赖的服务种类是否一致，若不一致抛出异常
             */
            var bestConstructor: ?ConstructorInfo = None
            var parameterCallSites: ?Array<ServiceCallSite> = None
            var bestConstructorParameterTypes: ?HashSet<TypeInfo> = None
            for (constructor in constructors) {
                let parameters = constructor.parameters
                let currentParameterCallSites = createArgumentCallSites(identifier, implementationType, callSiteChain,
                    parameters, false)
                if (let Some(currentParameterCallSites) <- currentParameterCallSites) {
                    // 存在多个匹配构造器
                    if (let Some(bestConstructor) <- bestConstructor) {
                        if (bestConstructorParameterTypes.isNone()) {
                            bestConstructorParameterTypes = HashSet<TypeInfo>()
                            for (pattern in bestConstructor.parameters) {
                                bestConstructorParameterTypes?.add(pattern.typeInfo)
                            }
                        }

                        for (pattern in parameters) {
                            if (bestConstructorParameterTypes?.contains(pattern.typeInfo) == false) {
                                throw UnsupportedException(
                                    String.join(
                                        "Unable to activate type '${implementationType}'. The following constructors are ambiguous:",
                                        bestConstructor.toString(), constructor.toString(), delimiter: "\r\n"))
                            }
                        }
                    } else {
                        bestConstructor = constructor
                        parameterCallSites = currentParameterCallSites
                    }
                }
            }

            if (let Some(bestConstructor) <- bestConstructor && let Some(parameterCallSites) <- parameterCallSites) {
                return ConstructorCallSite(lifetime, identifier.serviceKey, identifier.serviceType, bestConstructor,
                    parameterCallSites)
            } else {
                throw UnsupportedException(
                    "No constructor for type '${implementationType}' can be instantiated using services from the service container and default values.")
            }
        } finally {
            callSiteChain.remove(identifier)
        }
    }

    /*
    基于参数依赖的服务类型创建图纸
     */
    private func createArgumentCallSites(identifier: ServiceIdentifier, implementationType: ClassTypeInfo,
        callSiteChain: CallSiteChain, parameters: Collection<ParameterInfo>, throwIfCallSiteNotFound: Bool): ?Array<ServiceCallSite> {
        let parameterCallSites = ArrayList<ServiceCallSite>()
        for (parameter in parameters) {
            let parameterType = parameter.typeInfo
            var callSite: ?ServiceCallSite = None
            var isKeyedParameter = false
            // 解析命名键   
            if (let Some(serviceKey) <- identifier.serviceKey && parameter.findAnnotation<ServiceKey>().isSome()) {
                callSite = ConstantCallSite(None, parameterType, serviceKey)
            }
            // 解析命名服务
            if (let Some(mode) <- parameter.findAnnotation<FromKeyedServices>().flatMap {f => f.mode}) {
                // 服务key是否继承
                let serviceKey: ?String = match (mode) {
                    case Inherit => identifier.serviceKey
                    case Explicit(serviceKey) => serviceKey
                }

                if (let Some(serviceKey) <- serviceKey) {
                    isKeyedParameter = true
                    callSite = getCallSite(ServiceIdentifier.fromServiceType(serviceKey, parameterType), callSiteChain)
                }
            }

            if (!isKeyedParameter && callSite.isNone()) {
                callSite = getCallSite(ServiceIdentifier.fromServiceType(parameterType), callSiteChain)
            }

            if (let Some(callSite) <- callSite) {
                parameterCallSites.add(callSite)
            } else {
                if (throwIfCallSiteNotFound) {
                    throw UnsupportedException(
                        "Unable to resolve service for type '${parameterType}' while attempting to activate '${implementationType}'.")
                }
                return None
            }
        }

        return parameterCallSites.toArray()
    }

    /*
    基于Collection<T>的服务类型创建图纸
     */
    private func tryCreateCollection(identifier: ServiceIdentifier, callSiteChain: CallSiteChain): ?ServiceCallSite {
        let callSiteKey = ServiceCacheKey(DefaultSlot, identifier)
        if (let Some(callSite) <- _callSiteCache.get(callSiteKey)) {
            return callSite
        }

        try {
            callSiteChain.add(identifier)
            let serviceType = identifier.serviceType

            if (!GenericTypeHelper.isCollectionGenericType(identifier.serviceType)) {
                return None
            }

            let itemType = GenericTypeHelper.getCollectionGenericParameters(serviceType)

            if (!(itemType is ClassTypeInfo || itemType is InterfaceTypeInfo)) {
                throw UnsupportedException(
                    "Unable to create an Collection service of type '${itemType}' because it is a ValueType.")
            }

            let cacheKey = ServiceIdentifier(identifier.serviceKey, itemType)

            var cacheLocation = CallSiteResultCacheLocation.Root

            let callSites: Array<ServiceCallSite>
            if (let Some(descriptors) <- _descriptorLookup.get(cacheKey)) {
                var slot = descriptors.size
                callSites = Array<ServiceCallSite>(descriptors.size, repeat: unsafe {
                    zeroValue<ServiceCallSite>()
                })
                for (index in 0..descriptors.size) {
                    let descriptor = descriptors[index]
                    slot--
                    let callSite = createExact(descriptor, cacheKey, callSiteChain, slot)
                    cacheLocation = getCommonCacheLocation(cacheLocation, callSite.cache.location)
                    callSites[index] = callSite
                }
            } else {
                callSites = []
            }

            let lifetime = match (cacheLocation) {
                case CallSiteResultCacheLocation.Scope | CallSiteResultCacheLocation.Root => CallSiteResultCache(
                    callSiteKey, cacheLocation)
                case _ => CallSiteResultCache(callSiteKey, CallSiteResultCacheLocation.Other)
            }
            let callSite = CollectionCallSite(lifetime, identifier.serviceKey, serviceType, itemType, callSites)
            _callSiteCache[callSiteKey] = callSite
            return callSite
        } finally {
            callSiteChain.remove(identifier)
        }
    }

    /*
    对于Collection<T>获取最大生命周期
     */
    private func getCommonCacheLocation(locationA: CallSiteResultCacheLocation, locationB: CallSiteResultCacheLocation) {
        if (locationA > locationB) {
            return locationA
        }
        return locationB
    }
}

/*
服务描述缓存项：用于精细化描述服务
 */
private struct ServiceDescriptorCacheItem {
    private var _item: ?ServiceDescriptor = None // 永远指向同一服务的第一项
    private var _items: ?ArrayList<ServiceDescriptor> = None

    public func add(descriptor: ServiceDescriptor) {
        var newCacheItem = ServiceDescriptorCacheItem()
        /*
        由于一个服务会有多个实现方式
            1. 我们以最后注册的服务图纸，作为该服务类型的默认实现
         */
        if (this._item.isNone()) {
            //第一次创建
            newCacheItem._item = descriptor
        } else {
            //第二次创建
            newCacheItem._item = this._item
            newCacheItem._items = this._items ?? ArrayList<ServiceDescriptor>()
            newCacheItem._items?.add(descriptor)
        }

        return newCacheItem
    }

    public prop last: ServiceDescriptor {
        get() {
            if (let Some(items) <- _items && items.size > 0) {
                return items[items.size - 1]
            }
            return _item.getOrThrow()
        }
    }

    public prop size: Int64 {
        get() {
            if (_item.isNone()) {
                return 0
            }
            return 1 + (_items.flatMap {f => f.size} ?? 0)
        }
    }

    /*
    获取插槽
     */
    public func getSlot(descriptor: ServiceDescriptor) {
        /*
        我们按照注册顺序，从0倒序生成插槽
         */
        if (let Some(item) <- _item && refEq(descriptor, item)) {
            return size - 1
        }

        if (let Some(items) <- _items && let Some(index) <- items.indexOf(descriptor)) {
            return items.size - (index + 1)
        }

        throw UnsupportedException("Requested service descriptor doesn't exist.")
    }

    public operator func [](index: Int64) {
        if (index >= size) {
            throw IndexOutOfBoundsException("index")
        }

        if (index == 0) {
            return _item.getOrThrow()
        }

        return _items.flatMap {f => f[index - 1]}.getOrThrow()
    }
}

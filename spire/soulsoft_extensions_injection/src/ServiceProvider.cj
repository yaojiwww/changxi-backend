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
import soulsoft_extensions_injection.exceptions.*


/**
 * @brief 表示根服务提供者并负责解析服务实例。
 */
public class ServiceProvider <: IServiceProvider & Resource {
    private let _isClosed = AtomicBool(false)
    private let _services: ServiceCollection
    private let _engine: ServiceProviderEngine
    private let _options: ServiceProviderOptions
    private let _callSiteFactory: CallSiteFactory
    private var _root: ?ServiceProviderEngineScope = None
    private var _callSiteValidator: ?CallSiteValidator = None
    private let _serviceAccessors: ConcurrentHashMap<ServiceIdentifier, ServiceAccessor>

    init(services: ServiceCollection, options: ServiceProviderOptions) {
        _services = services
        _options = options
        _engine = DynamicServiceProviderEngine()
        _callSiteFactory = CallSiteFactory(services)
        _serviceAccessors = ConcurrentHashMap<ServiceIdentifier, ServiceAccessor>()
        _root = ServiceProviderEngineScope(this, isRootScope: true)

        //添加IServiceProvider图纸：注意它返回的是this不是常量
        _callSiteFactory.add(ServiceIdentifier.fromServiceType(TypeInfo.of<IServiceProvider>()),
            ServiceProviderCallSite())

        //添加IServiceScopeFactory图纸    
        _callSiteFactory.add(ServiceIdentifier.fromServiceType(TypeInfo.of<IServiceScopeFactory>()),
            ConstantCallSite(None, TypeInfo.of<IServiceScopeFactory>(), root))

        //添加IServiceProviderIsService图纸        
        _callSiteFactory.add(ServiceIdentifier.fromServiceType(TypeInfo.of<IServiceProviderIsService>()),
            ConstantCallSite(None, TypeInfo.of<IServiceProviderIsService>(), _callSiteFactory))

        //添加IServiceProviderIsKeyedService图纸        
        _callSiteFactory.add(ServiceIdentifier.fromServiceType(TypeInfo.of<IServiceProviderIsKeyedService>()),
            ConstantCallSite(None, TypeInfo.of<IServiceProviderIsKeyedService>(), _callSiteFactory))

        // 每次解析时验证作业域
        if (options.validateScopes) {
            _callSiteValidator = CallSiteValidator()
        }

        // 在启动阶段验证作用域
        if (options.validateOnBuild) {
            var exceptions: ?ArrayList<Exception> = None
            for (pattern in services) {
                try {
                    validateService(pattern)
                } catch (exception: Exception) {
                    exceptions = exceptions ?? ArrayList<Exception>()
                    exceptions?.add(exception)
                }
            }
            if (let Some(exceptions) <- exceptions) {
                if (exceptions.size == 1) {
                    throw exceptions[0]
                }
                throw AggregateException("Some services are not able to be constructed", exceptions)
            }
        }
    }

    internal prop root: ServiceProviderEngineScope {
        get() {
            _root.getOrThrow()
        }
    }

    /**
     * @brief 按运行时类型解析服务。
     * @param serviceType 要解析的服务类型。
     * @return 解析得到的服务实例；未注册时返回 `None`。
     * @throws UnsupportedException 当服务提供者已关闭时抛出。
     */
    public func get(serviceType: TypeInfo): ?Any {
        return root.get(serviceType)
    }

    /**
     * @brief 按服务键和运行时类型解析服务。
     * @param serviceKey 要解析的服务键。
     * @param serviceType 要解析的服务类型。
     * @return 解析得到的服务实例；未注册时返回 `None`。
     * @throws UnsupportedException 当服务提供者已关闭时抛出。
     */
    public func get(serviceKey: String, serviceType: TypeInfo): ?Any {
        return root.get(serviceKey, serviceType)
    }

    /**
     * @brief 关闭当前服务提供者并释放已捕获的资源。
     */
    public func close(): Unit {
        if (_isClosed.compareAndSwap(false, true)) {
            root.close()
        }
    }

    /**
     * @brief 检查当前服务提供者是否已关闭。
     * @return 如果服务提供者已关闭则返回 `true`，否则返回 `false`。
     */
    public func isClosed(): Bool {
        return _isClosed.load()
    }

    /**
     * @brief 基于当前根容器创建一个新的作用域。
     * @return 新创建的服务作用域。
     * @throws UnsupportedException 当服务提供者已关闭时抛出。
     */
    public func createScope(): IServiceScope {
        checkIsClosed()
        return ServiceProviderEngineScope(this, isRootScope: false)
    }

    internal func resolve(identifier: ServiceIdentifier, scope: ServiceProviderEngineScope): Any {
        checkIsClosed()

        let serviceAccessor = _serviceAccessors.entryView(identifier) {
            view => if (view.value.isNone()) {
                view.value = createServiceAccessor(identifier)
            }
        }.getOrThrow()

        onResolve(serviceAccessor.callSite, scope)

        return serviceAccessor.realizedService(scope)
    }

    private func checkIsClosed() {
        if (isClosed()) {
            throw UnsupportedException("Cannot access a disposed object.\r\nObject name: 'IServiceProvider'.")
        }
    }

    private func createServiceAccessor(identifier: ServiceIdentifier): ServiceAccessor {
        if (let Some(callSite) <- _callSiteFactory.getCallSite(identifier, CallSiteChain())) {
            onCreate(callSite)
            if (callSite.cache.location == CallSiteResultCacheLocation.Root) {
                let value = CallSiteRuntimeResolver.Instance.resolve(callSite, root)
                return ServiceAccessor(callSite) {
                    _ => value
                }
            }
            let realizedService = _engine.realizeService(callSite)
            return ServiceAccessor(callSite, realizedService)
        } else {
            return ServiceAccessor(None, {_ => ()})
        }
    }

    private func validateService(descriptor: ServiceDescriptor) {
        try {
            if (let Some(callSite) <- _callSiteFactory.getCallSite(descriptor, CallSiteChain())) {
                onCreate(callSite)
            }
        } catch (exception: Exception) {
            throw UnsupportedException(
                "Error while validating the service descriptor '${descriptor}': ${exception.message}")
        }
    }

    private func onCreate(callSite: ServiceCallSite) {
        _callSiteValidator?.validateCallSite(callSite)
    }

    private func onResolve(callSite: ?ServiceCallSite, scope: IServiceScope) {
        if (let Some(callSite) <- callSite) {
            _callSiteValidator?.validateResolution(callSite, scope, root)
        }
    }
}

/*
服务访问器，用于缓描述每个图纸的解析引擎
 */
private class ServiceAccessor {
    ServiceAccessor(let callSite: ?ServiceCallSite, let realizedService: (ServiceProviderEngineScope) -> Any) {
    }
}

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
import soulsoft_extensions_injection.exceptions.*

/*
子容器
 */
class ServiceProviderEngineScope <: IServiceProvider & IServiceScope & IServiceScopeFactory {
    private let _sync = Mutex()
    private var _isClosed = false
    private var _disposables: ?List<Resource> = None
    private var _resolvedServices: ?HashMap<ServiceCacheKey, Any> = None

    ServiceProviderEngineScope(let rootProvider: ServiceProvider, let isRootScope!: Bool) {
    }

    internal prop sync: Mutex {
        get() {
            _sync
        }
    }

    internal mut prop resolvedServices: ?HashMap<ServiceCacheKey, Any> {
        get() {
            return _resolvedServices
        }
        set(value) {
            _resolvedServices = value
        }
    }

    public func createScope(): IServiceScope {
        return rootProvider.createScope()
    }

    public func get(serviceType: TypeInfo): ?Any {
        checkIsClosed()
        let instance = rootProvider.resolve(ServiceIdentifier(serviceType), this)
        if (instance is Unit) {
            return None
        }
        return instance
    }

    public func get(serviceKey: String, serviceType: TypeInfo): ?Any {
        checkIsClosed()
        let instance = rootProvider.resolve(ServiceIdentifier(serviceKey, serviceType), this)
        if (instance is Unit) {
            return None
        }
        return instance
    }

    public prop services: IServiceProvider {
        get() {
            this
        }
    }

    public func close(): Unit {
        if (let Some(disposables) <- beginDispose()) {
            var exceptions: ?ArrayList<Exception> = None

            // 逆序释放
            for (index in disposables.size - 1..=0 : -1) {
                try {
                    disposables[index].close()
                } catch (exception: Exception) {
                    exceptions = exceptions ?? ArrayList<Exception>()
                    exceptions?.add(exception)
                }
            }

            if (let Some(exceptions) <- exceptions) {
                if (exceptions.size == 1) {
                    throw exceptions[0]
                }
                throw AggregateException("Exceptions occurred while closing services", exceptions)
            }
        }
    }

    public func isClosed(): Bool {
        synchronized(_sync) {
            _isClosed
        }
    }

    private func checkIsClosed() {
        if (isClosed()) {
            throw UnsupportedException("Cannot access a disposed object.\r\nObject name: 'IServiceProvider'.")
        }
    }

    /*
    如果A线程在解析服务时持有容器，B线程恰好也在解析服务，A线程解析完成释放容器
    1. 如果A线将容器释放，那么B线程解析出来的服务应立即释放防止内存泄漏
     */
    internal func captureDisposable(service: Any): Any {
        if (let resource: Resource <- service) {
            // 排除掉自身引用，防止重复释放
            if (let object: Object <- service && refEq(object, this)) {
                return service
            }

            var disposed = false
            synchronized(_sync) {
                if (_isClosed) {
                    disposed = true
                } else {
                    if (let Some(disposables) <- _disposables) {
                        disposables.add(resource)
                    } else {
                        _disposables = ArrayList<Resource>([resource])
                    }
                }
            }

            if (disposed && !resource.isClosed()) {
                resource.close()
            }
        }
        return service
    }

    private func beginDispose(): ?List<Resource> {
        let disposables = synchronized(sync) {
            if (_isClosed) {
                return None
            }
            _isClosed = true
            _disposables
        }

        if (isRootScope && !rootProvider.isClosed()) {
            rootProvider.close()
        }

        return disposables
    }
}

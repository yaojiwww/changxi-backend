// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_http

import std.collection.*
import std.sync.*
import soulsoft_net_http.*
import soulsoft_extensions_options.*
import std.collection.concurrent.*
import soulsoft_extensions_injection.*

/*
该类是单例的并且线程安全的，需要关注多线创建同名的client导致的并发安全问题
 */
class DefaultHttpClientFactory <: IHttpClientFactory & IHttpMessageHandlerFactory {
    private let _lock = Mutex()
    private var _cleanupTimer: ?Timer = None
    private let _cleanupTimerLock = Mutex()
    private let _cleanupActiveLock = Mutex()
    private static let _cleanupInterval = Duration.second * 10

    private let _serviceScopeFactory: IServiceScopeFactory
    private let _optionsMonitor: IOptionsMonitor<HttpClientFactoryOptions>
    private let _filters: Array<IHttpMessageHandlerBuilderFilter>
    // issue: 由于ConcurrentHashMap当前存在内存泄漏的问题，因此暂时使用HashMap+Mutex
    private let _activeHandlers = HashMap<String, ActiveHandlerTrackingEntry>()
    private let _expiredHandlers = ConcurrentLinkedQueue<ExpiredHandlerTrackingEntry>()

    /**
     * @brief 创建默认 HTTP 客户端工厂实例。
     * @param serviceScopeFactory 用于创建处理器作用域的工厂。
     * @param optionsMonitor 用于读取命名客户端配置的选项监视器。
     * @param filters 用于装饰消息处理器构建过程的过滤器集合。
     */
    public init(serviceScopeFactory: IServiceScopeFactory, optionsMonitor: IOptionsMonitor<HttpClientFactoryOptions>,
        filters: Array<IHttpMessageHandlerBuilderFilter>) {
        _serviceScopeFactory = serviceScopeFactory
        _optionsMonitor = optionsMonitor
        _filters = filters
    }

    /**
     * @brief 创建指定名称的 HTTP 客户端实例。
     * @param name 客户端名称。
     * @return 返回创建得到的 HTTP 客户端实例。
     */
    public func createClient(name: String): HttpClient {
        let options = _optionsMonitor.get(name)
        let handler = createHandler(name)
        let client = HttpClient(handler, false)
        for (action in options.httpClientActions) {
            action(client)
        }
        return client
    }

    /**
     * @brief 创建指定名称的 HTTP 消息处理器。
     * @param name 客户端名称。
     * @return 返回可复用的 HTTP 消息处理器实例。
     */
    public func createHandler(name: String): HttpMessageHandler {
        //处理器应被设计为线程安全的
        let entry = getOrCreateActiveHandlerTrackingEntry(name)
        startHandlerEntryTimer(entry)
        return entry.handler
    }

    private func getOrCreateActiveHandlerTrackingEntry(name: String) {
        synchronized(_lock) {
            if (let Some(entry) <- _activeHandlers.get(name)) {
                return entry
            }
            let entry = createHandlerEntry(name)
            _activeHandlers.add(name, entry)
            return entry
        }
    }

    private func createHandlerEntry(name: String): ActiveHandlerTrackingEntry {
        let scope = _serviceScopeFactory.createScope()
        let options = _optionsMonitor.get(name)
        try {
            let builder = scope.services.getOrThrow<HttpMessageHandlerBuilder>()
            builder.name = name

            // 构建过滤器装饰链（洋葱模型），与 C# 参考实现对齐：
            // 基础配置函数：按序执行所有 httpMessageHandlerBuilderActions
            var configure: (HttpMessageHandlerBuilder) -> Unit = {
                b => for (action in options.httpMessageHandlerBuilderActions) {
                    action(b)
                }
            }
            // 逆序包装：_filters[last] 最先执行，_filters[0] 最后执行（最靠近内层）
            var i = _filters.size - 1
            while (i >= 0) {
                let next = configure
                configure = _filters[i].configure(next)
                i--
            }
            configure(builder)

            // 转换成支持生命周期跟踪的处理器
            let handler = LifetimeTrackingHttpMessageHandler(builder.build())
            return ActiveHandlerTrackingEntry(name, options.handlerLifetime, scope, handler)
        } catch (ex: Exception) {
            scope.close()
            throw ex
        }
    }

    /*
    启动活动项关联的定时器
     */
    private func startHandlerEntryTimer(entry: ActiveHandlerTrackingEntry) {
        entry.startExpiryTimer {
            expiryTimerTick(entry)
        }
    }

    /*
    活动项关联的定时器执行的任务
     */
    private func expiryTimerTick(active: ActiveHandlerTrackingEntry) {
        synchronized(_lock) {
            _activeHandlers.remove(active.name)
        }
        let expired = ExpiredHandlerTrackingEntry(active)
        _expiredHandlers.add(expired)
        //启动清理线程
        startCleanupTimer()
    }

    /*
    启动垃圾回收定时器
     */
    private func startCleanupTimer(): Unit {
        //如果同时触发，那么丢弃
        synchronized(_cleanupTimerLock) {
            if (_cleanupTimer.isNone()) {
                _cleanupTimer = Timer.once(_cleanupInterval, cleanupTimerTick)
            }
        }
    }

    /*
    停止垃圾回收定时器
     */
    private func stopCleanupTimer() {
        synchronized(_cleanupTimerLock) {
            _cleanupTimer?.cancel()
            _cleanupTimer = None
        }
    }

    /*
    垃圾回收定时器执行的任务
     */
    private func cleanupTimerTick() {
        //停止定时器
        stopCleanupTimer()

        //如果由于上个清理任务未完成，那么安排下次清理
        if (!_cleanupActiveLock.tryLock()) {
            startCleanupTimer()
            return
        }

        try {
            let initialCount = _expiredHandlers.size
            for (_ in 0..initialCount) {
                let entry = _expiredHandlers.remove().getOrThrow()
                if (entry.canDispose) {
                    try {
                        entry.innerHandler?.close()
                    } catch (ex: Exception) {
                        ex.printStackTrace()
                    }
                    try {
                        entry.scope.close()
                    } catch (ex: Exception) {
                        ex.printStackTrace()
                    }
                } else {
                    _expiredHandlers.add(entry)
                }
            }
        } finally {
            _cleanupActiveLock.unlock()
        }

        if (!_expiredHandlers.isEmpty()) {
            startCleanupTimer()
        }
    }
}

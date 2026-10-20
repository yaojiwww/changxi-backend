// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_protocols

import std.sync.*
import std.time.*

/**
 * @brief 提供带缓存与刷新能力的配置管理器实现。
 */
public class ConfigurationManager<T> <: IConfigurationManager<T> where T <: Object {
    // 首次加载锁：保证只有一个线程发起请求，其余等待
    private let _firstLoadLock = Mutex()

    private let _address: String
    private let _refreshInterval: Duration
    private let _automaticRefreshInterval: Duration
    private let _documentRetriever: IDocumentRetriever
    private let _configurationRetriever: IConfigurationRetriever<T>

    // 当前缓存的配置
    private let _currentConfiguration = AtomicOptionReference<T>()

    // 后台刷新是否正在运行（CAS 保证只有一个后台刷新）
    private let _isRefreshing = AtomicBool(false)

    // 下次允许自动刷新的时间点（类似 C# 的 _syncAfter）
    private let _syncAfter = AtomicReference<Box<DateTime>>(Box<DateTime>(DateTime.nowUTC()))

    // 上次 requestRefresh 的时间（用于 RefreshInterval 节流）
    private let _lastRequestRefresh = AtomicReference<Box<DateTime>>(Box<DateTime>(DateTime.nowUTC() - Duration.hour))

    // 首次 requestRefresh 标志：第一次调用无论间隔都触发
    private let _isFirstRefreshRequest = AtomicBool(true)

    /**
     * @brief 表示手动刷新请求的默认最小间隔。
     */
    public static let DefaultRefreshInterval = Duration.minute * 5

    /**
     * @brief 表示自动后台刷新的默认间隔。
     */
    public static let DefaultAutomaticRefreshInterval = Duration.hour * 12

    /**
     * @brief 创建配置管理器。
     * @param address 配置文档地址。
     * @param documentRetriever 用于读取配置文档的检索器。
     * @param configurationRetriever 用于解析配置对象的检索器。
     * @param refreshInterval 手动刷新请求的最小间隔。
     * @param automaticRefreshInterval 自动后台刷新的间隔。
     * @throws IllegalArgumentException 当配置地址为空时抛出。
     */
    public init(address: String, documentRetriever: IDocumentRetriever,
        configurationRetriever: IConfigurationRetriever<T>, refreshInterval!: Duration = DefaultRefreshInterval,
        automaticRefreshInterval!: Duration = DefaultAutomaticRefreshInterval) {
        if (address.isEmpty()) {
            throw IllegalArgumentException("address must not be empty.")
        }
        _address = address
        _documentRetriever = documentRetriever
        _configurationRetriever = configurationRetriever
        _refreshInterval = refreshInterval
        _automaticRefreshInterval = automaticRefreshInterval
    }

    /**
     * @brief 获取当前有效配置。
     * @return 返回当前配置对象。
     * @throws Exception 当首次加载配置失败时抛出。
     */
    public func getConfiguration(): T {
        // 快速路径：缓存命中且未过期
        if (let Some(cfg) <- _currentConfiguration.load()) {
            if (!isSyncAfterExpired()) {
                return cfg
            }
            // 已过自动刷新时间点，后台触发刷新，返回当前缓存（stale-while-revalidate）
            triggerBackgroundRefresh()
            return cfg
        }

        // 慢路径：首次加载，阻塞等待
        return firstLoad()
    }

    /**
     * @brief 请求刷新当前配置缓存。
     * @note 如果刷新间隔未到，则本次请求会被忽略。
     */
    public func requestRefresh(): Unit {
        let isFirst = _isFirstRefreshRequest.load()
        if (!isFirst && !canRequestRefresh()) {
            return
        }

        _isFirstRefreshRequest.swap(false)
        _lastRequestRefresh.swap(Box<DateTime>(DateTime.nowUTC()))

        // 将 _syncAfter 设为过去，使下次 getConfiguration 触发刷新
        _syncAfter.swap(Box<DateTime>(DateTime.nowUTC() - Duration.second))

        // 若已有缓存，后台刷新；若无缓存，下次 getConfiguration 会走首次加载
        if (_currentConfiguration.load().isSome()) {
            triggerBackgroundRefresh()
        }
    }

    // -------------------------------------------------------------------------
    // 内部实现
    // -------------------------------------------------------------------------

    // 首次加载：只有一个线程真正执行，其余在锁上等待
    private func firstLoad(): T {
        synchronized(_firstLoadLock) {
            // 等待期间可能已被其他线程加载完成
            if (let Some(cfg) <- _currentConfiguration.load()) {
                return cfg
            }

            // 本线程持锁，直接同步加载
            var fetchError: ?Exception = None
            try {
                let cfg = _configurationRetriever.getConfiguration(_address, _documentRetriever)
                _currentConfiguration.swap(cfg)
                _syncAfter.swap(Box<DateTime>(DateTime.nowUTC() + _automaticRefreshInterval))
            } catch (e: Exception) {
                fetchError = e
            }

            if (let Some(cfg) <- _currentConfiguration.load()) {
                return cfg
            }

            // 加载失败，抛出附带根因的异常
            if (let Some(cause) <- fetchError) {
                cause.printStackTrace()
                throw Exception("Failed to load configuration from '${_address}': ${cause.message}", cause)
            } else {
                throw Exception("Failed to load configuration from '${_address}'")
            }
        }
    }

    // 后台非阻塞刷新：spawn 协程，不阻塞调用方
    private func triggerBackgroundRefresh(): Unit {
        if (!_isRefreshing.compareAndSwap(false, true)) {
            return
        }
        spawn {
            try {
                let cfg = _configurationRetriever.getConfiguration(_address, _documentRetriever)
                _currentConfiguration.swap(cfg)
                _syncAfter.swap(Box<DateTime>(DateTime.nowUTC() + _automaticRefreshInterval))
            } catch (_: Exception) {
                // 后台刷新失败：保留旧配置，缩短下次重试间隔
                _syncAfter.swap(Box<DateTime>(DateTime.nowUTC() + _refreshInterval))
            } finally {
                _isRefreshing.swap(false)
            }
        }
    }

    private func isSyncAfterExpired(): Bool {
        DateTime.nowUTC() >= _syncAfter.load().value
    }

    private func canRequestRefresh(): Bool {
        DateTime.nowUTC() - _lastRequestRefresh.load().value >= _refreshInterval
    }
}

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_logging

import std.sync.*
import std.collection.*
import std.collection.concurrent.*
import soulsoft_extensions_injection.*

/**
 * @brief 提供日志记录器工厂实现。
 */
public class LoggerFactory <: ILoggerFactory {
    private let _sync = Mutex()
    private let _isClosed = AtomicBool(false)
    private let _options: LoggerFilterOptions
    private let _loggers = ConcurrentHashMap<String, Logger>()
    private let _providerRegistrations = ArrayList<ProviderRegistration>()

    /**
     * @brief 使用指定提供程序集合和过滤选项创建日志记录器工厂。
     * @param providers 日志提供程序集合。
     * @param options 日志过滤选项。
     */
    public init(providers: Collection<ILoggerProvider>, options: LoggerFilterOptions) {
        _options = options
        // 由容器提供的providers，不由LoggerFactory负责释放
        for (provider in providers) {
            addProviderRegistration(provider, false)
        }
    }

    /**
     * @brief 按分类名称创建日志记录器。
     * @param categoryName 日志分类名称。
     * @return 返回创建得到的日志记录器。
     * @throws UnsupportedException 当日志记录器工厂已关闭时抛出。
     */
    public func createLogger(categoryName: String): ILogger {
        checkClosed()
        let normalizedCategoryName = normalizeCategoryName(categoryName)

        if (let Some(logger) <- _loggers.get(normalizedCategoryName)) {
            return logger
        }

        synchronized(_sync) {
            if (let Some(logger) <- _loggers.get(normalizedCategoryName)) {
                return logger
            }

            checkClosed()
            let loggers = createLoggers(normalizedCategoryName)
            let logger = Logger(loggers, applyFilters(loggers))
            _loggers[normalizedCategoryName] = logger
            return logger
        }
    }

    /**
     * @brief 在工厂运行时动态添加日志提供程序。
     * @param provider 要添加的日志提供程序。
     * @throws UnsupportedException 当日志记录器工厂已关闭时抛出。
     */
    public func addProvider(provider: ILoggerProvider): Unit {
        checkClosed()
        synchronized(_sync) {
            checkClosed()
            addProviderRegistration(provider, true)
            for ((categoryName, logger) in _loggers) {
                let loggerInfo = LoggerInformation(provider, categoryName)
                let existingLoggers = logger.loggers
                let updatedLoggers = Array<LoggerInformation>(existingLoggers.size + 1, repeat: loggerInfo)
                var index = 0
                while (index < existingLoggers.size) {
                    updatedLoggers[index] = existingLoggers[index]
                    index++
                }
                updatedLoggers[existingLoggers.size] = loggerInfo
                logger.loggers = updatedLoggers
                logger.messageLoggers = applyFilters(updatedLoggers)
            }
        }
    }

    /**
     * @brief 使用配置回调创建日志记录器工厂。
     * @param configure 用于配置日志构建器的回调。
     * @return 返回创建得到的日志记录器工厂。
     */
    public static func create(configure: (LoggingBuilder) -> Unit): ILoggerFactory {
        let services = ServiceCollection()
        services.addLogging(configure)
        let provider = services.build()
        let loggerFactory = provider.getOrThrow<ILoggerFactory>()
        return DisposingLoggerFactory(provider, loggerFactory)
    }

    /**
     * @brief 关闭日志记录器工厂并释放所有日志提供程序。
     */
    public func close(): Unit {
        if (_isClosed.compareAndSwap(false, true)) {
            for (registration in _providerRegistrations) {
                if (!registration.shouldDispose) {
                    continue
                }
                try {
                    registration.provider.close()
                } catch (_: Exception) {
                }
            }
        }
    }

    /**
     * @brief 检查日志记录器工厂是否已关闭。
     * @return 如果日志记录器工厂已关闭则返回 `true`，否则返回 `false`。
     */
    public func isClosed(): Bool {
        return _isClosed.load()
    }

    private func checkClosed(): Unit {
        if (_isClosed.load()) {
            throw UnsupportedException("LoggerFactory is closed.")
        }
    }

    private func normalizeCategoryName(categoryName: String): String {
        return categoryName.replace("_", ".")
    }

    private func createLoggers(categoryName: String): Array<LoggerInformation> {
        let list = ArrayList<LoggerInformation>(_providerRegistrations.size)
        for (registration in _providerRegistrations) {
            list.add(LoggerInformation(registration.provider, categoryName))
        }
        return list.toArray()
    }

    private func applyFilters(loggers: Array<LoggerInformation>): Array<MessageLogger> {
        let list = ArrayList<MessageLogger>()
        for (loggerInfo in loggers) {
            let (minLevel, filter) = LoggerRuleSelector.select(_options, loggerInfo.providerType, loggerInfo.category)
            if (minLevel == LogLevel.Off) {
                continue
            }
            list.add(
                MessageLogger(loggerInfo.logger, loggerInfo.category, loggerInfo.providerType.qualifiedName, minLevel,
                    filter))
        }
        return list.toArray()
    }

    private func addProviderRegistration(provider: ILoggerProvider, shouldDispose: Bool): Unit {
        _providerRegistrations.add(ProviderRegistration(provider, shouldDispose))
    }
}

private class DisposingLoggerFactory <: ILoggerFactory {
    private let _services: IServiceProvider
    private let _loggerFactory: ILoggerFactory

    init(services: IServiceProvider, loggerFactory: ILoggerFactory) {
        _services = services
        _loggerFactory = loggerFactory
    }

    public func createLogger(categoryName: String): ILogger {
        return _loggerFactory.createLogger(categoryName)
    }

    public func addProvider(provider: ILoggerProvider): Unit {
        _loggerFactory.addProvider(provider)
    }

    public func close(): Unit {
        if (isClosed()) {
            return
        }
        if (let services: Resource <- _services) {
            services.close()
        }
    }

    public func isClosed(): Bool {
        return _loggerFactory.isClosed()
    }
}

struct ProviderRegistration {
    ProviderRegistration(let provider: ILoggerProvider, let shouldDispose: Bool) {}
}

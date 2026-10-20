package soulsoft_extensions_logging

import soulsoft_extensions_options.*
import soulsoft_extensions_injection.*

/**
 * @brief 为服务集合提供日志注册扩展。
 */
public interface LoggingServiceCollectionExtensions {
    /**
     * @brief 注册默认日志服务。
     * @return 返回当前服务集合。
     */
    func addLogging(): Unit {
        addLogging {_ =>}
    }

    /**
     * @brief 注册日志服务并执行自定义配置。
     * @param configure 配置日志构建器的回调。
     * @return 返回当前服务集合。
     */
    func addLogging(configure: (LoggingBuilder) -> Unit): Unit
}

extend ServiceCollection <: LoggingServiceCollectionExtensions {
    /**
     * @brief 注册日志服务并执行自定义配置。
     * @param configure 配置日志构建器的回调。
     * @return 返回当前服务集合。
     */
    public func addLogging(configure: (LoggingBuilder) -> Unit): Unit {
        addOptions<LoggerFilterOptions>()

        tryAddEnumerable(
            ServiceDescriptor.singleton<IConfigureOptions<LoggerFilterOptions>, DefaultLoggerLevelConfigureOptions>(
                DefaultLoggerLevelConfigureOptions(LogLevel.Info)))

        tryAddSingleton<ILoggerFactory> {
            sp =>
                let providers = sp.getAll<ILoggerProvider>()
                let filterOptions = sp.getOrThrow<IOptions<LoggerFilterOptions>>()
                return LoggerFactory(providers, filterOptions.value)
        }
        configure(LoggingBuilder(this))
    }
}

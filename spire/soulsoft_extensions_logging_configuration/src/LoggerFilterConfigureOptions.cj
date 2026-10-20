/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_logging_configuration

import std.collection.*
import soulsoft_extensions_logging.*
import soulsoft_extensions_options.*
import soulsoft_extensions_configuration.*

/**
 * @brief 基于 IConfiguration 为 LoggerFilterOptions 加载规则。
 */
public class LoggerFilterConfigureOptions <: IConfigureOptions<LoggerFilterOptions> {
    private static let logLevelKey = "logLevel"
    private static let defaultCategory = "default"
    private let _configuration: IConfiguration

    /**
     * @brief 使用日志配置创建过滤规则配置器。
     * @param configuration 日志配置根。
     */
    public init(configuration: IConfiguration) {
        _configuration = configuration
    }

    public func configure(options: LoggerFilterOptions): Unit {
        loadRulesFromConfiguration(options)
    }

    private func loadRulesFromConfiguration(options: LoggerFilterOptions): Unit {
        for (configurationSection in _configuration.getChildren()) {
            if (configurationSection.key.equalsIgnoreAsciiCase(logLevelKey)) {
                loadRules(options, configurationSection, None)
            } else {
                let logLevelSection = configurationSection.getSection(logLevelKey)
                if (logLevelSection.exists()) {
                    loadRules(options, logLevelSection, configurationSection.key)
                }
            }
        }
    }

    private func loadRules(options: LoggerFilterOptions, configurationSection: IConfigurationSection, logger: ?String): Unit {
        for ((category, value) in configurationSection.asEnumerable(true)) {
            let level = tryGetSwitch(value)
            if (level.isSome()) {
                var ruleCategory: ?String = category
                if (let Some(categoryValue) <- ruleCategory && categoryValue.equalsIgnoreAsciiCase(defaultCategory)) {
                    ruleCategory = None
                }
                options.rules.add(LoggerFilterRule(logger, ruleCategory, level, None))
            }
        }
    }

    private func tryGetSwitch(value: ?String): ?LogLevel {
        if (let Some(v) <- value) {
            if (v.isEmpty()) {
                return None
            }
            return match (v.toAsciiLower()) {
                case "trace" => Some(LogLevel.Trace)
                case "debug" => Some(LogLevel.Debug)
                case "info" => Some(LogLevel.Info)
                case "warn" => Some(LogLevel.Warn)
                case "error" => Some(LogLevel.Error)
                case "fatal" => Some(LogLevel.Fatal)
                case "off" => Some(LogLevel.Off)
                case _ => throw UnsupportedException("Invalid log level '${v}'")
            }
        }
        return None
    }
}

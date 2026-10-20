// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_logging

import std.reflect.*
import soulsoft_extensions_logging.utilities.*

/**
 * @brief 选择日志过滤规则。
 */
protected class LoggerRuleSelector {
    private static const _wildcardStr = '*'

    public static func select(options: LoggerFilterOptions, providerType: TypeInfo, categoryName: String): (?LogLevel, ?(?String,
        ?String, LogLevel) -> Bool) {
        var filter: ?(?String, ?String, LogLevel) -> Bool = None
        var minLevel: ?LogLevel = options.minLevel
        var current: ?LoggerFilterRule = None
        let providerName = providerType.qualifiedName
        let providerAlias = ProviderAliasUtilities.getAlias(providerType)

        for (rule in options.rules) {
            if (isBetter(rule, current, providerName, categoryName)) {
                current = rule
            }
            if (let Some(providerAlias) <- providerAlias && !providerAlias.isEmpty()) {
                if (isBetter(rule, current, providerAlias, categoryName)) {
                    current = rule
                }
            }
        }

        if (let Some(rule) <- current) {
            filter = rule.filter
            minLevel = rule.logLevel
        }

        return (minLevel, filter)
    }

    /**
     * @brief 判断某条规则是否比当前规则更适合。
     * @param rule 待比较的规则。
     * @param current 当前已选规则。
     * @param providerName 提供程序名称。
     * @param categoryName 日志分类名称。
     * @return 如果待比较规则更合适则返回 `true`，否则返回 `false`。
     */
    private static func isBetter(rule: LoggerFilterRule, current: ?LoggerFilterRule, providerName: String,
        categoryName: String) {
        if (rule.providerName != None && rule.providerName != providerName) {
            return false
        }

        if (let Some(category) <- rule.categoryName) {
            let wildcardIndex = category.indexOf(_wildcardStr)
            if (let Some(firstIdx) <- wildcardIndex) {
                if (category.indexOf(_wildcardStr, firstIdx + 1) != None) {
                    throw UnsupportedException("More Than One '${_wildcardStr}'")
                }
            }
            var prefix = category.toAsciiLower()
            var suffix = String.empty
            if (let Some(index) <- wildcardIndex) {
                prefix = category[0..index].toAsciiLower()
                suffix = category[(index + 1)..].toAsciiLower()
            }
            let categoryNameAsciiLower = categoryName.toAsciiLower()
            if (!categoryNameAsciiLower.startsWith(prefix) || !categoryNameAsciiLower.endsWith(suffix)) {
                return false
            }
        }

        if (current.flatMap {f => f.providerName}.isSome()) {
            if (rule.providerName == None) {
                return false
            }
        } else {
            if (rule.providerName != None) {
                return true
            }
        }

        if (let Some(cur) <- current) {
            if (let Some(category) <- cur.categoryName) {
                if (rule.categoryName.isNone()) {
                    return false
                }

                if (let Some(ruleCategory) <- rule.categoryName) {
                    if (category.size > ruleCategory.size) {
                        return false
                    }
                }
            }
        }
        return true
    }
}

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_staticfiles.fileProviders

/**
 * @brief 表示文件或目录的排除过滤标志。
 * @description 该类型用于组合控制物理文件提供器需要排除的条目类别。
 */
public struct ExclusionFilters <: Equatable<ExclusionFilters> {
    private let _value: Int32

    private init(value: Int32) {
        _value = value
    }

    /**
     * @brief 表示不排除任何文件或目录。
     */
    public static let None = ExclusionFilters(0)

    /**
     * @brief 表示排除以点号开头的文件和目录。
     */
    public static let DotPrefixed = ExclusionFilters(0x0001)

    /**
     * @brief 表示排除具有隐藏属性的文件和目录。
     */
    public static let Hidden = ExclusionFilters(0x0002)

    /**
     * @brief 表示排除具有系统属性的文件和目录。
     */
    public static let System = ExclusionFilters(0x0004)

    /**
     * @brief 表示默认的敏感过滤组合。
     */
    public static let Sensitive = ExclusionFilters(0x0007)

    /**
     * @brief 合并两个排除过滤标志。
     * @param other 要合并的另一个过滤标志。
     * @return 合并后的过滤标志。
     */
    public operator func |(other: ExclusionFilters): ExclusionFilters {
        ExclusionFilters(_value | other._value)
    }

    /**
     * @brief 计算两个排除过滤标志的交集。
     * @param other 要参与计算的另一个过滤标志。
     * @return 同时存在于两个值中的过滤标志。
     */
    public operator func &(other: ExclusionFilters): ExclusionFilters {
        ExclusionFilters(_value & other._value)
    }

    /**
     * @brief 检查两个过滤标志是否相等。
     * @param other 要比较的另一个过滤标志。
     * @return 如果两个过滤标志相等则返回 true，否则返回 false。
     */
    public operator func ==(other: ExclusionFilters): Bool {
        _value == other._value
    }

    /**
     * @brief 检查当前值是否包含指定过滤标志。
     * @param flag 要检查的过滤标志。
     * @return 如果包含指定过滤标志则返回 true，否则返回 false。
     */
    public func hasFlag(flag: ExclusionFilters): Bool {
        (_value & flag._value) != 0
    }
}

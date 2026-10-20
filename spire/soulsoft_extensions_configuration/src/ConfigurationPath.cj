// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_configuration

/**
 * @brief 提供配置路径处理的静态工具方法。
 */
public class ConfigurationPath {
    private init() {
    }

    /**
     * @brief 表示配置路径层级分隔符。
     */
    public static const delimiter = ":"

    /**
     * @brief 按配置分隔符拼接路径片段。
     * @param segments 待拼接的路径片段集合。
     * @return 返回拼接后的配置路径。
     */
    public static func combine(segments: Array<String>): String {
        String.join(segments, delimiter: delimiter)
    }

    /**
     * @brief 返回配置路径的最后一个节键。
     * @param path 完整配置路径。
     * @return 返回路径末尾的节键。
     */
    public static func getSectionKey(path: String): String {
        if (path.isEmpty()) {
            return path
        }

        if (let Some(lastDelimiterIndex) <- path.lastIndexOf(delimiter)) {
            return path[lastDelimiterIndex + 1..]
        } else {
            return path
        }
    }

    /**
     * @brief 返回配置路径的父路径。
     * @param path 完整配置路径。
     * @return 返回父路径；如果不存在则返回 None。
     */
    public static func getParentPath(path: String): ?String {
        if (let Some(lastDelimiterIndex) <- path.lastIndexOf(delimiter)) {
            return path[0..lastDelimiterIndex]
        } else {
            return None
        }
    }
}

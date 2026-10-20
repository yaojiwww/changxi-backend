// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_configuration

import std.fs.*
import std.io.*

extend ConfigurationBuilder {
    /**
     * @brief 添加一个从输入流读取的 JSON 配置源。
     * @param stream 提供 JSON 内容的输入流。
     * @return 返回当前配置构建器。
     */
    public func addJsonStream(stream: IOStream): ConfigurationBuilder {
        let sr = StringReader(stream)
        let json = sr.readToEnd()
        add(JsonConfigurationSource(json))
        return this
    }

    /**
     * @brief 添加一个基于 JSON 字符串的配置源。
     * @param json JSON 格式的配置内容。
     * @return 返回当前配置构建器。
     */
    public func addJsonString(json: String): ConfigurationBuilder {
        add(JsonConfigurationSource(json))
        return this
    }

    /**
     * @brief 添加一个基于 JSON 文件的配置源。
     * @param path JSON 配置文件路径。
     * @param optional 指示文件不存在时是否忽略。
     * @return 返回当前配置构建器。
     */
    public func addJsonFile(path: String, optional!: Bool = true): ConfigurationBuilder {
        if (optional && !exists(path)) {
            return this
        }
        try (file = File(path, OpenMode.Read)) {
            addJsonStream(file)
        }
        return this
    }
}

extend ConfigurationManager {
    /**
     * @brief 添加一个从输入流读取的 JSON 配置源。
     * @param stream 提供 JSON 内容的输入流。
     * @return 返回当前配置管理器。
     */
    public func addJsonStream(stream: IOStream): ConfigurationManager {
        let sr = StringReader(stream)
        let json = sr.readToEnd()
        add(JsonConfigurationSource(json))
        return this
    }

    /**
     * @brief 添加一个基于 JSON 字符串的配置源。
     * @param json JSON 格式的配置内容。
     * @return 返回当前配置管理器。
     */
    public func addJsonString(json: String): ConfigurationManager {
        add(JsonConfigurationSource(json))
        return this
    }

    /**
     * @brief 添加一个基于 JSON 文件的配置源。
     * @param path JSON 配置文件路径。
     * @param optional 指示文件不存在时是否忽略。
     * @return 返回当前配置管理器。
     */
    public func addJsonFile(path: String, optional!: Bool = true): ConfigurationManager {
        if (optional && !exists(path)) {
            return this
        }
        try (file = File(path, OpenMode.Read)) {
            addJsonStream(file)
        }
        return this
    }
}

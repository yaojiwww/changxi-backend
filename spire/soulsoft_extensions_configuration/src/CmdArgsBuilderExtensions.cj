// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_configuration

import std.collection.*

extend ConfigurationBuilder {
    /**
     * @brief 添加一个命令行参数配置源。
     * @param args 命令行参数数组。
     * @param switchMappings 可选的短开关到配置键映射。
     * @return 返回当前配置构建器。
     */
    public func addCmdArgs(args: Array<String>, switchMappings!: ?Map<String, String> = None): ConfigurationBuilder {
        add(CmdArgsConfigurationSource(args, switchMappings: switchMappings))
        return this
    }
}

extend ConfigurationManager {
    /**
     * @brief 添加一个命令行参数配置源。
     * @param args 命令行参数数组。
     * @param switchMappings 可选的短开关到配置键映射。
     * @return 返回当前配置管理器。
     */
    public func addCmdArgs(args: Array<String>, switchMappings!: ?Map<String, String> = None): ConfigurationManager {
        add(CmdArgsConfigurationSource(args, switchMappings: switchMappings))
        return this
    }
}

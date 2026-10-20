// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_configuration

import std.collection.*

class CmdArgsConfigurationSource <: IConfigurationSource {
    private let _args: Array<String>
    private let _switchMappings: ?Map<String, String>

    init(args: Array<String>, switchMappings!: ?Map<String, String> = None) {
        _args = args
        _switchMappings = switchMappings
    }

    /**
     * @brief 创建命令行参数配置提供程序。
     * @param _ 当前配置构建器上下文。
     * @return 返回用于读取命令行参数的配置提供程序。
     */
    public func build(_: IConfigurationBuilder): IConfigurationProvider {
        let provider = CmdArgsConfigurationProvider(_args, switchMappings: _switchMappings)
        return provider
    }
}

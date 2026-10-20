// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_configuration

class EnvVarsConfigurationSource <: IConfigurationSource {
    private let _prefix: String

    init(prefix: String) {
        _prefix = prefix
    }

    /**
     * @brief 创建环境变量配置提供程序。
     * @param _ 当前配置构建器上下文。
     * @return 返回用于读取环境变量的配置提供程序。
     */
    public func build(_: IConfigurationBuilder): IConfigurationProvider {
        let provider = EnvVarsConfigurationProvider(_prefix)
        return provider
    }
}

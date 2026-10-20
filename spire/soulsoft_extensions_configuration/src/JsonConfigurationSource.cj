// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_configuration

class JsonConfigurationSource <: IConfigurationSource {
    private let _json: String

    init(json: String) {
        _json = json
    }

    /**
     * @brief 创建 JSON 配置提供程序。
     * @param _ 当前配置构建器上下文。
     * @return 返回用于读取 JSON 内容的配置提供程序。
     */
    public func build(_: IConfigurationBuilder): IConfigurationProvider {
        let provider = JsonConfigurationProvider(_json)
        return provider
    }
}

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.services

import std.reflect.*
import std.collection.*
import soulsoft_extensions_options.*
import soulsoft_extensions_injection.*
import soulsoft_identity_server.validation.*

protected class ExtensionGrantManager {
    private let _options: ExtensionGrantManagerOptions
    private let _serviceProvider: IServiceProvider

    public init(serviceProvider: IServiceProvider, options: IOptions<ExtensionGrantManagerOptions>) {
        _options = options.value
        _serviceProvider = serviceProvider
    }

    public func getGrantTypes() {
        _options.grantTypes.keys()
    }

    public func findValidator(grantType: String): ?IExtensionGrantValidator {
        if (let Some(typeInfo) <- _options.grantTypes.get(grantType)) {
            return _serviceProvider.getOrThrow(typeInfo) as IExtensionGrantValidator
        }
        return None
    }
}

/**
 * @brief 表示扩展授权管理器配置选项。
 */
public class ExtensionGrantManagerOptions {
    /**
     * @brief 保存扩展授权类型与验证器类型的映射。
     */
    public let grantTypes = HashMap<String, TypeInfo>()
}

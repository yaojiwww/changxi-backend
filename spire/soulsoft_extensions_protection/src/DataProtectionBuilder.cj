// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_protection

import std.fs.*
import soulsoft_extensions_options.*
import soulsoft_extensions_injection.*

/**
 * @brief 提供数据保护服务的链式配置能力。
 */
public class DataProtectionBuilder {
    DataProtectionBuilder(let services: ServiceCollection) {
    }

    /**
     * @brief 设置当前应用的数据保护隔离名称。
     * @param applicationName 应用隔离名称。
     * @return 返回当前数据保护构建器。
     */
    public func setApplicationName(applicationName: String): DataProtectionBuilder {
        services.configure<DataProtectionOptions> {
            configureOptions => configureOptions.applicationDiscriminator = applicationName
        }
        return this
    }

    /**
     * @brief 禁用密钥自动生成。
     * @return 返回当前数据保护构建器。
     */
    public func disableAutomaticKeyGeneration(): DataProtectionBuilder {
        services.configure<KeyManagementOptions> {
            configureOptions => configureOptions.autoGenerateKeys = false
        }
        return this
    }

    /**
     * @brief 设置新密钥的默认生存期。
     * @param lifetime 密钥生存期。
     * @return 返回当前数据保护构建器。
     * @throws IllegalArgumentException 当密钥生存期为负数时抛出。
     */
    public func setDefaultKeyLifetime(lifetime: Duration): DataProtectionBuilder {
        if (lifetime < Duration.Zero) {
            throw IllegalArgumentException("The lifetime must not be negative.")
        }
        services.configure<KeyManagementOptions> {
            configureOptions => configureOptions.newKeyLifetime = lifetime
        }
        return this
    }

    /**
     * @brief 添加密钥管理选项配置委托。
     * @param configureOptions 用于配置密钥管理选项的委托。
     * @return 返回当前数据保护构建器。
     */
    public func addKeyManagementOptions(configureOptions: (KeyManagementOptions) -> Unit): DataProtectionBuilder {
        services.configure(configureOptions)
        return this
    }

    /**
     * @brief 注册密钥托管接收器。
     * @param sink 在密钥持久化前接收明文密钥材料副本的接收器。
     * @return 返回当前数据保护构建器。
     */
    public func addKeyEscrowSink(sink: IKeyEscrowSink): DataProtectionBuilder {
        services.configure<KeyManagementOptions> {
            configureOptions => configureOptions.keyEscrowSinks.add(sink)
        }
        return this
    }

    /**
     * @brief 将密钥持久化到文件系统目录。
     * @param path 密钥存储目录。
     * @return 返回当前数据保护构建器。
     */
    public func persistKeysToFileSystem(path: Path): DataProtectionBuilder {
        services.configure<KeyManagementOptions> {
            configureOptions => configureOptions.keyRepository = FileSystemKeyRepository(path)
        }
        return this
    }

    /**
     * @brief 设置认证加密器算法配置。
     * @param configuration 认证加密器算法配置。
     * @return 返回当前数据保护构建器。
     */
    public func useCryptographicAlgorithms(configuration: AuthenticatedEncryptorConfiguration): DataProtectionBuilder {
        services.configure<KeyManagementOptions> {
            configureOptions => configureOptions.authenticatedEncryptorConfiguration = configuration
        }
        return this
    }
}

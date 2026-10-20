// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_protection.abstractions

import std.collection.*

/**
 * @brief 表示数据保护密钥管理相关配置选项。
 */
public class KeyManagementOptions {
    // 密钥环自动刷新周期：24 小时
    protected let keyRingRefreshPeriod = Duration.hour * 24
    // 密钥传播窗口：48 小时（确保集群各节点在旧密钥失效前均获取到继任密钥）
    protected let keyPropagationWindow = Duration.hour * 48
    // 服务器间最大时钟偏差：5 分钟（允许激活时间轻微超前的密钥被使用）
    protected let maxServerClockSkew = Duration.minute * 5

    /**
     * @brief 指示是否自动生成新密钥。
     */
    public var autoGenerateKeys = true

    /**
     * @brief 指定密钥持久化仓储实现。
     */
    public var keyRepository: ?IKeyRepository = None

    /**
     * @brief 指定新生成密钥的默认生存期。
     */
    public var newKeyLifetime = Duration.day * 90

    /**
     * @brief 指定默认使用的认证加密器算法配置。
     */
    public var authenticatedEncryptorConfiguration: ?AlgorithmConfiguration = None

    /**
     * @brief 保存可用的认证加密器工厂集合。
     */
    public let authenticatedEncryptorFactories = ArrayList<IAuthenticatedEncryptorFactory>()

    /**
     * @brief 保存注册的密钥托管接收器集合。
     */
    public let keyEscrowSinks = ArrayList<IKeyEscrowSink>()
}

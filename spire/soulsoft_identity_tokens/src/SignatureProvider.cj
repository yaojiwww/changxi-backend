// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_tokens

import std.sync.*

/**
 * @brief 表示签名或验签操作的抽象基类。
 * @description 该类型实现 `Resource`，用于支持显式释放和工厂缓存归还。
 */
public abstract class SignatureProvider <: Resource {
    private let _key: SecurityKey
    private let _algorithm: String
    private let _willCreateSignatures: Bool
    private let _closed: AtomicBool = AtomicBool(false)

    /**
     * @brief 创建一个签名提供者。
     * @param key 关联的安全密钥。
     * @param algorithm 签名算法标识。
     * @param willCreateSignatures 是否用于创建签名。
     */
    protected init(key: SecurityKey, algorithm: String, willCreateSignatures!: Bool = false) {
        _key = key
        _algorithm = algorithm
        _willCreateSignatures = willCreateSignatures
    }

    /**
     * @brief 获取关联的安全密钥。
     * @return 当前提供者使用的安全密钥。
     */
    public prop key: SecurityKey {
        get() { _key }
    }

    /**
     * @brief 获取签名算法标识。
     * @return 当前提供者使用的算法标识。
     */
    public prop algorithm: String {
        get() { _algorithm }
    }

    /**
     * @brief 获取当前提供者是否用于签名。
     * @return 用于签名时返回 `true`，用于验签时返回 `false`。
     */
    public prop willCreateSignatures: Bool {
        get() { _willCreateSignatures }
    }

    /**
     * @brief 对输入数据执行签名。
     * @param input 要签名的字节数组。
     * @return 生成的签名字节序列。
     */
    public func sign(input: Array<Byte>): Array<Byte>

    /**
     * @brief 验证输入数据与签名是否匹配。
     * @param input 原始输入数据。
     * @param signature 待验证的签名字节序列。
     * @return 签名有效时返回 `true`。
     */
    public func verify(input: Array<Byte>, signature: Array<Byte>): Bool

    /**
     * @brief 检查当前提供者是否已关闭。
     * @return 已关闭时返回 `true`。
     */
    public func isClosed(): Bool {
        _closed.load()
    }

    /**
     * @brief 关闭当前签名提供者。
     * @description 默认实现仅标记关闭状态，子类可重写以释放额外资源。
     */
    public func close(): Unit {
        _closed.compareAndSwap(false, true)
    }
}

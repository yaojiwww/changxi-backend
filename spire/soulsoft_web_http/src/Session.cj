// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_http

/**
 * @brief 表示 HTTP 会话存储。
 */
public abstract class Session {
    /**
     * @brief 返回会话标识。
     * @return 当前会话标识。
     */
    public prop id: String
    /**
     * @brief 检查会话是否可用。
     * @return 如果会话可用则返回 true，否则返回 false。
     */
    public prop isAvailable: Bool
    /**
     * @brief 返回当前会话中的键集合。
     * @return 当前会话中的键集合。
     */
    public prop keys: Collection<String>
    /**
     * @brief 按键获取会话值。
     * @param key 会话键。
     * @return 对应键的字节数组值。
     */
    public func get(key: String): Array<Byte>
    /**
     * @brief 设置会话键对应的值。
     * @param key 会话键。
     * @param value 要保存的字节数组值。
     */
    public func set(key: String, value: Array<Byte>): Unit
    /**
     * @brief 删除指定会话键。
     * @param key 要删除的会话键。
     */
    public func remove(key: String): Unit
    /**
     * @brief 清空当前会话中的所有数据。
     */
    public func clear(): Unit
    /**
     * @brief 加载当前会话数据。
     */
    public func load(): Unit
    /**
     * @brief 提交当前会话数据。
     */
    public func commit(): Unit
}

class DefaultSession <: Session {
    static let instance = DefaultSession()

    public prop id: String {
        get() {
            String.empty
        }
    }
    public prop isAvailable: Bool {
        get() {
            false
        }
    }
    public prop keys: Collection<String> {
        get() {
            []
        }
    }
    public func get(key: String): Array<Byte> {
        throw UnsupportedException("Session is not available.")
    }
    public func set(key: String, value: Array<Byte>): Unit {
        throw UnsupportedException("Session is not available.")
    }
    public func remove(key: String): Unit {
        throw UnsupportedException("Session is not available.")
    }
    public func clear(): Unit {
        throw UnsupportedException("Session is not available.")
    }
    public func load(): Unit {
        throw UnsupportedException("Session is not available.")
    }
    public func commit(): Unit {
        throw UnsupportedException("Session is not available.")
    }
}

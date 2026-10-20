// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_mvc.abstractions

import std.collection.*

/**
 * @brief 保存模型绑定和验证阶段产生的错误信息。
 */
public class ModelStateDictionary <: Collection<(String, ModelStateEntry)> {
    private var _items: ?HashMap<String, ModelStateEntry> = None

    /**
     * @brief 检查当前模型状态是否有效。
     * @return 如果当前不存在任何错误条目则返回 `true`。
     */
    public prop isValid: Bool {
        get() {
            if (_items.isNone()) {
                return true
            } else {
                return getItems().size == 0
            }
        }
    }

    /**
     * @brief 为指定名称添加文本错误信息。
     * @param name 错误所属的字段或参数名称。
     * @param error 要记录的错误描述。
     */
    public func addError(name: String, error: String): Unit {
        let items = getItems()
        if (let Some(entry) <- items.get(name)) {
            entry.errors.add(error)
        } else {
            let entry = ModelStateEntry()
            entry.errors.add(error)
            items.add(name, entry)
        }
    }

    /**
     * @brief 为指定名称添加异常错误信息。
     * @param name 错误所属的字段或参数名称。
     * @param exception 要记录的异常对象。
     */
    public func addError(name: String, exception: Exception): Unit {
        let items = getItems()
        if (let Some(entry) <- items.get(name)) {
            entry.errors.add(exception)
        } else {
            let entry = ModelStateEntry()
            entry.errors.add(exception)
            items.add(name, entry)
        }
    }

    /**
     * @brief 返回当前错误条目数量。
     * @return 当前模型状态中的错误条目数量。
     */
    public prop size: Int64 {
        get() {
            getItems().size
        }
    }

    /**
     * @brief 返回所有错误条目的键集合。
     * @return 当前模型状态中的所有键。
     */
    public func keys(): Collection<String> {
        getItems().keys()
    }

    /**
     * @brief 返回所有错误条目的值集合。
     * @return 当前模型状态中的所有条目值。
     */
    public func values(): Collection<ModelStateEntry> {
        getItems().values()
    }

    /**
     * @brief 按名称获取模型状态条目。
     * @param key 要查找的字段或参数名称。
     * @return 对应的模型状态条目；如果不存在则返回 `None`。
     */
    public func get(key: String): ?ModelStateEntry {
        getItems().get(key)
    }

    /**
     * @brief 检查当前是否不存在任何错误条目。
     * @return 如果当前没有错误条目则返回 `true`。
     */
    public func isEmpty(): Bool {
        return getItems().isEmpty()
    }

    /**
     * @brief 遍历所有模型状态条目。
     * @return 当前模型状态条目的迭代器。
     */
    public func iterator(): Iterator<(String, ModelStateEntry)> {
        getItems().iterator()
    }

    private func getItems() {
        if (_items.isNone()) {
            _items = HashMap<String, ModelStateEntry>()
        }
        return _items.getOrThrow()
    }
}

/**
 * @brief 表示单个字段或参数的模型状态条目。
 */
public class ModelStateEntry {
    private var _errors: ?ModelErrorCollection = None

    /**
     * @brief 返回当前条目关联的错误集合。
     * @return 当前条目的错误集合。
     */
    public prop errors: ModelErrorCollection {
        get() {
            if (_errors.isNone()) {
                _errors = ModelErrorCollection()
            }
            return _errors.getOrThrow()
        }
    }
}

/**
 * @brief 表示一次模型绑定或验证错误。
 */
public class ModelError {
    private let _exception: ?Exception
    private let _description: String

    /**
     * @brief 使用错误描述创建模型错误实例。
     * @param description 要记录的错误描述。
     */
    public init(description: String) {
        this(description, None)
    }

    /**
     * @brief 使用异常创建模型错误实例。
     * @param exception 要记录的异常对象。
     */
    public init(exception: ?Exception) {
        this(String.empty, exception)
    }

    /**
     * @brief 使用描述和异常创建模型错误实例。
     * @param description 要记录的错误描述。
     * @param exception 要记录的异常对象。
     */
    public init(description: String, exception: ?Exception) {
        _exception = exception
        _description = description
    }

    /**
     * @brief 返回关联的异常对象。
     * @return 当前错误关联的异常对象；如果不存在则返回 `None`。
     */
    public prop exception: ?Exception {
        get() {
            _exception
        }
    }

    /**
     * @brief 返回错误描述文本。
     * @return 当前错误的描述文本。
     */
    public prop description: String {
        get() {
            _description
        }
    }
}

/**
 * @brief 提供模型错误的集合封装。
 */
public class ModelErrorCollection <: Collection<ModelError> {
    private let _errors = ArrayList<ModelError>()

    /**
     * @brief 返回错误数量。
     * @return 当前集合中的错误数量。
     */
    public prop size: Int64 {
        get() {
            _errors.size
        }
    }

    /**
     * @brief 检查集合是否为空。
     * @return 如果当前没有任何错误则返回 `true`。
     */
    public func isEmpty(): Bool {
        _errors.isEmpty()
    }

    /**
     * @brief 遍历所有模型错误。
     * @return 当前错误集合的迭代器。
     */
    public func iterator(): Iterator<ModelError> {
        _errors.iterator()
    }

    /**
     * @brief 添加文本错误。
     * @param error 要添加的错误描述。
     */
    public func add(error: String): Unit {
        _errors.add(ModelError(error))
    }

    /**
     * @brief 添加异常错误。
     * @param exception 要添加的异常对象。
     */
    public func add(exception: Exception): Unit {
        _errors.add(ModelError(exception))
    }
}

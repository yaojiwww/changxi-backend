// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_hosting

import std.collection.*

protected class FormFileCollection <: IFormFileCollection {
    private static let emptyList = ArrayList<IFormFile>(0)
    private let _items = HashMap<String, ArrayList<IFormFile>>()

    /**
     * @brief 返回当前文件字段数量。
     * @return 当前文件字段数量。
     */
    public prop size: Int64 {
        get() {
            _items.size
        }
    }

    /**
     * @brief 检查文件集合是否为空。
     * @return 如果文件集合为空则返回 true，否则返回 false。
     */
    public func isEmpty(): Bool {
        _items.isEmpty()
    }

    /**
     * @brief 返回文件集合的迭代器。
     * @return 当前文件集合的迭代器。
     */
    public func iterator(): Iterator<IFormFile> {
        let files = _items.values() |> flatMap {f => f}
        return files.iterator()
    }

    /**
     * @brief 向指定字段追加上传文件。
     * @param name 字段名称。
     * @param file 要追加的上传文件。
     */
    public func add(name: String, file: IFormFile): Unit {
        if (_items.contains(name)) {
            _items[name].add(file)
        } else {
            _items.add(name, ArrayList<IFormFile>([file]))
        }
    }

    /**
     * @brief 获取指定字段的第一个上传文件。
     * @param name 字段名称。
     * @return 指定字段的第一个上传文件；如果不存在则返回空。
     */
    public func get(name: String): ?IFormFile {
        if (let Some(values) <- _items.get(name)) {
            return values.first
        }
        return None
    }

    /**
     * @brief 获取指定字段的所有上传文件。
     * @param name 字段名称。
     * @return 指定字段的所有上传文件列表。
     */
    public func getAll(name: String): ReadOnlyList<IFormFile> {
        return _items.get(name) ?? emptyList
    }
}

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_hosting

import std.collection.*
import stdx.encoding.url.*

protected class FormCollection <: IFormCollection {
    private let _form: Form
    private let _keys = HashSet<String>()
    private let _files = FormFileCollection()

    /**
     * @brief 创建一个空的表单集合。
     */
    public init() {
        this(Form())
    }

    /**
     * @brief 使用指定表单数据创建表单集合。
     * @param form 底层表单数据对象。
     */
    public init(form: Form) {
        _form = form
    }

    /**
     * @brief 返回当前表单中的文件集合。
     * @return 当前表单中的文件集合。
     */
    public prop files: IFormFileCollection {
        get() {
            _files
        }
    }

    /**
     * @brief 返回当前表单中的字段名集合。
     * @return 当前表单中的字段名集合。
     */
    public func keys(): HashSet<String> {
        _keys
    }

    /**
     * @brief 向表单中追加字段值。
     * @param name 字段名称。
     * @param value 要追加的字段值。
     */
    public func add(name: String, value: String): Unit {
        /*
        由于form暂时不支持keys
         */
        _keys.add(name)
        _form.add(name, value)
    }

    /**
     * @brief 向表单中追加上传文件。
     * @param name 字段名称。
     * @param file 要追加的上传文件。
     */
    public func addFile(name: String, file: IFormFile): Unit {
        _files.add(name, file)
    }

    /**
     * @brief 检查表单是否为空。
     * @return 如果表单为空则返回 true，否则返回 false。
     */
    public func isEmpty(): Bool {
        _form.isEmpty()
    }

    /**
     * @brief 获取指定字段的第一个值。
     * @param name 字段名称。
     * @return 指定字段的第一个值；如果不存在则返回空。
     */
    public func get(name: String): ?String {
        return _form.get(name)
    }

    /**
     * @brief 获取指定字段的所有值。
     * @param name 字段名称。
     * @return 指定字段的所有值集合。
     */
    public func getAll(name: String): ArrayList<String> {
        return _form.getAll(name)
    }
}

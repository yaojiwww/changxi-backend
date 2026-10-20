// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_http

import std.collection.*

/**
 * @brief 定义表单上传文件集合。
 */
public interface IFormFileCollection <: Collection<IFormFile> {
    /**
     * @brief 检查文件集合是否为空。
     * @return 如果文件集合为空则返回 true，否则返回 false。
     */
    func isEmpty(): Bool
    /**
     * @brief 获取指定字段的第一个上传文件。
     * @param name 字段名称。
     * @return 指定字段的第一个上传文件；如果不存在则返回空。
     */
    func get(name: String): ?IFormFile
    /**
     * @brief 获取指定字段的所有上传文件。
     * @param name 字段名称。
     * @return 指定字段的所有上传文件列表。
     */
    func getAll(name: String): ReadOnlyList<IFormFile>
}

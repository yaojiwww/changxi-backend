// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_http

/**
 * @brief 定义表单字段和值的集合。
 */
public interface IFormCollection <: IValueProvider {
    /**
     * @brief 返回当前表单中的文件集合。
     * @return 当前表单中的文件集合。
     */
    prop files: IFormFileCollection
    /**
     * @brief 检查表单集合是否为空。
     * @return 如果表单集合为空则返回 true，否则返回 false。
     */
    func isEmpty(): Bool
    /**
     * @brief 返回表单中的字段名集合。
     * @return 当前表单中的字段名集合。
     */
    func keys(): Collection<String>
}

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_web_openapi.interfaces

/**
 * @brief 定义 OpenAPI 文档写入接口。
 */
public interface IOpenApiWriter {
    /**
     * @brief 刷新当前写入器缓冲区。
     */
    func flush(): Unit
    /**
     * @brief 开始写入对象。
     */
    func startObject(): Unit
    /**
     * @brief 结束写入对象。
     */
    func endObject(): Unit
    /**
     * @brief 开始写入数组。
     */
    func startArray(): Unit
    /**
     * @brief 结束写入数组。
     */
    func endArray(): Unit
    /**
     * @brief 写入属性名称。
     * @param name 要写入的属性名称。
     */
    func writeName(name: String): Unit
    /**
     * @brief 写入整数值。
     * @param value 要写入的整数值。
     */
    func writeValue(value: Int64): Unit
    /**
     * @brief 写入布尔值。
     * @param value 要写入的布尔值。
     */
    func writeValue(value: Bool): Unit
    /**
     * @brief 写入字符串值。
     * @param value 要写入的字符串值。
     */
    func writeValue(value: String): Unit
}

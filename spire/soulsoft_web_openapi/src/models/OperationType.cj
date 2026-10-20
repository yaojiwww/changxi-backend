// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_openapi.models

import soulsoft_web_http.*

/**
 * @brief 表示 OpenAPI 操作类型。
 */
public enum OperationType <: Equatable<OperationType> & Hashable & IOpenApiSerializable {
    /**
     * @brief 表示 GET 操作。
     */
    Get
    /**
     * @brief 表示 PUT 操作。
     */
    | Put
    /**
     * @brief 表示 POST 操作。
     */
    | Post
    /**
     * @brief 表示 DELETE 操作。
     */
    | Delete
    /**
     * @brief 表示 OPTIONS 操作。
     */
    | Options
    /**
     * @brief 表示 HEAD 操作。
     */
    | Head
    /**
     * @brief 表示 PATCH 操作。
     */
    | Patch
    /**
     * @brief 表示 TRACE 操作。
     */
    | Trace
    /**
     * @brief 表示未知操作。
     */
    | Unkonw

    /**
     * @brief 比较两个操作类型是否相等。
     * @param that 要比较的操作类型。
     * @return 如果两个操作类型相等则返回 `true`。
     */
    public operator func ==(that: OperationType): Bool {
        match ((this, that)) {
            case (Get, Get) => true
            case (Put, Put) => true
            case (Post, Post) => true
            case (Delete, Delete) => true
            case (Options, Options) => true
            case (Head, Head) => true
            case (Patch, Patch) => true
            case (Trace, Trace) => true
            case _ => false
        }
    }

    /**
     * @brief 按 OpenAPI V3 格式写出当前操作类型。
     * @param writer OpenAPI 写入器。
     */
    public func serializeAsV3(writer: IOpenApiWriter): Unit {
        writer.writeValue(this.toString())
    }

    /**
     * @brief 返回当前操作类型的哈希值。
     * @return 当前操作类型的哈希值。
     */
    public func hashCode(): Int64 {
        this.toString().hashCode()
    }

    /**
     * @brief 将 HTTP 方法字符串解析为操作类型。
     * @param str 要解析的 HTTP 方法字符串。
     * @return 解析得到的操作类型。
     * @throws IllegalFormatException 当字符串不是支持的 HTTP 方法时抛出。
     */
    public static func parse(str: String): OperationType {
        match (str) {
            case x where HttpMethods.isGet(x) => Get
            case x where HttpMethods.isPut(x) => Put
            case x where HttpMethods.isPost(x) => Post
            case x where HttpMethods.isDelete(x) => Delete
            case x where HttpMethods.isOptions(x) => Options
            case x where HttpMethods.isHead(x) => Head
            case x where HttpMethods.isPatch(x) => Patch
            case x where HttpMethods.isTrace(x) => Trace
            case _ => throw IllegalFormatException("Invalid OperationType format: ${str}")
        }
    }

    /**
     * @brief 返回操作类型对应的名称。
     * @return 当前操作类型对应的名称字符串。
     */
    public func toString(): String {
        match (this) {
            case Get => "get"
            case Put => "put"
            case Post => "post"
            case Delete => "delete"
            case Options => "options"
            case Head => "head"
            case Patch => "patch"
            case Trace => "trace"
            case Unkonw => "*"
        }
    }
}

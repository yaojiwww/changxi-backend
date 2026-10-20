// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_net_http

/**
 * @brief 表示 HTTP 请求方法。
 */
public class HttpMethod <: ToString & Equal<HttpMethod> {
    private let _method: String

    /**
     * @brief 使用方法名创建 HTTP 方法对象。
     * @param method HTTP 方法名。
     */
    public init(method: String) {
        _method = method.toAsciiUpper()
    }

    /**
     * @brief 表示 GET 请求方法。
     */
    public static let Get = HttpMethod("GET")
    /**
     * @brief 表示 POST 请求方法。
     */
    public static let Post = HttpMethod("POST")
    /**
     * @brief 表示 PUT 请求方法。
     */
    public static let Put = HttpMethod("PUT")
    /**
     * @brief 表示 DELETE 请求方法。
     */
    public static let Delete = HttpMethod("DELETE")
    /**
     * @brief 表示 PATCH 请求方法。
     */
    public static let Patch = HttpMethod("PATCH")
    /**
     * @brief 表示 HEAD 请求方法。
     */
    public static let Head = HttpMethod("HEAD")
    /**
     * @brief 表示 OPTIONS 请求方法。
     */
    public static let Options = HttpMethod("OPTIONS")
    /**
     * @brief 表示 TRACE 请求方法。
     */
    public static let Trace = HttpMethod("TRACE")
    /**
     * @brief 表示 CONNECT 请求方法。
     */
    public static let Connect = HttpMethod("CONNECT")

    /**
     * @brief 获取方法名字符串。
     * @return 当前 HTTP 方法名。
     */
    public func toString(): String {
        return _method
    }

    /**
     * @brief 检查两个 HTTP 方法是否相等。
     * @param that 要比较的另一个 HTTP 方法。
     * @return 方法名相同时返回 `true`。
     */
    public operator func ==(that: HttpMethod): Bool {
        this.toString() == that.toString()
    }
}

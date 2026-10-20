// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_http

/**
 * @brief 提供 HTTP 请求方法常量和比较工具。
 */
public struct HttpMethods {
    // 使用 let 而非 const，确保所有调用方共享同一个字符串实例，
    // 与 C# 中使用 static readonly 而非 const 的原因相同。

    /**
     * @brief 表示 HTTP CONNECT 方法。
     */
    public static const Connect = "CONNECT"
    /**
     * @brief 表示 HTTP DELETE 方法。
     */
    public static const Delete = "DELETE"
    /**
     * @brief 表示 HTTP GET 方法。
     */
    public static const Get = "GET"
    /**
     * @brief 表示 HTTP HEAD 方法。
     */
    public static const Head = "HEAD"
    /**
     * @brief 表示 HTTP OPTIONS 方法。
     */
    public static const Options = "OPTIONS"
    /**
     * @brief 表示 HTTP PATCH 方法。
     */
    public static const Patch = "PATCH"
    /**
     * @brief 表示 HTTP POST 方法。
     */
    public static const Post = "POST"
    /**
     * @brief 表示 HTTP PUT 方法。
     */
    public static const Put = "PUT"
    /**
     * @brief 表示 HTTP QUERY 方法。
     */
    public static const Query = "QUERY"
    /**
     * @brief 表示 HTTP TRACE 方法。
     */
    public static const Trace = "TRACE"

    /**
     * @brief 检查请求方法是否为 CONNECT。
     * @param method 要检查的请求方法。
     * @return 如果请求方法为 CONNECT 则返回 true，否则返回 false。
     */
    public static func isConnect(method: String): Bool {
        return equals(Connect, method)
    }

    /**
     * @brief 检查请求方法是否为 DELETE。
     * @param method 要检查的请求方法。
     * @return 如果请求方法为 DELETE 则返回 true，否则返回 false。
     */
    public static func isDelete(method: String): Bool {
        return equals(Delete, method)
    }

    /**
     * @brief 检查请求方法是否为 GET。
     * @param method 要检查的请求方法。
     * @return 如果请求方法为 GET 则返回 true，否则返回 false。
     */
    public static func isGet(method: String): Bool {
        return equals(Get, method)
    }

    /**
     * @brief 检查请求方法是否为 HEAD。
     * @param method 要检查的请求方法。
     * @return 如果请求方法为 HEAD 则返回 true，否则返回 false。
     */
    public static func isHead(method: String): Bool {
        return equals(Head, method)
    }

    /**
     * @brief 检查请求方法是否为 OPTIONS。
     * @param method 要检查的请求方法。
     * @return 如果请求方法为 OPTIONS 则返回 true，否则返回 false。
     */
    public static func isOptions(method: String): Bool {
        return equals(Options, method)
    }

    /**
     * @brief 检查请求方法是否为 PATCH。
     * @param method 要检查的请求方法。
     * @return 如果请求方法为 PATCH 则返回 true，否则返回 false。
     */
    public static func isPatch(method: String): Bool {
        return equals(Patch, method)
    }

    /**
     * @brief 检查请求方法是否为 POST。
     * @param method 要检查的请求方法。
     * @return 如果请求方法为 POST 则返回 true，否则返回 false。
     */
    public static func isPost(method: String): Bool {
        return equals(Post, method)
    }

    /**
     * @brief 检查请求方法是否为 PUT。
     * @param method 要检查的请求方法。
     * @return 如果请求方法为 PUT 则返回 true，否则返回 false。
     */
    public static func isPut(method: String): Bool {
        return equals(Put, method)
    }

    /**
     * @brief 检查请求方法是否为 QUERY。
     * @param method 要检查的请求方法。
     * @return 如果请求方法为 QUERY 则返回 true，否则返回 false。
     */
    public static func isQuery(method: String): Bool {
        return equals(Query, method)
    }

    /**
     * @brief 检查请求方法是否为 TRACE。
     * @param method 要检查的请求方法。
     * @return 如果请求方法为 TRACE 则返回 true，否则返回 false。
     */
    public static func isTrace(method: String): Bool {
        return equals(Trace, method)
    }

    /**
     * @brief 返回请求方法的规范化字符串实例。
     * @param method 原始请求方法。
     * @return 与已知方法匹配的共享字符串；如果未匹配则返回原始字符串。
     */
    public static func getCanonicalizedValue(method: String): String {
        return match (method) {
            case m where isGet(m) => Get
            case m where isPost(m) => Post
            case m where isPut(m) => Put
            case m where isDelete(m) => Delete
            case m where isOptions(m) => Options
            case m where isHead(m) => Head
            case m where isPatch(m) => Patch
            case m where isQuery(m) => Query
            case m where isTrace(m) => Trace
            case m where isConnect(m) => Connect
            case _ => method
        }
    }

    /**
     * @brief 比较两个请求方法是否相等。
     * @param methodA 第一个请求方法。
     * @param methodB 第二个请求方法。
     * @return 如果两个请求方法相等则返回 true，否则返回 false。
     */
    public static func equals(methodA: String, methodB: String): Bool {
        return methodA.equalsIgnoreAsciiCase(methodB)
    }
}

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_net_http


protected class KnownHeaders {
   
    public static func getHeaderType(name: String): HttpHeaderType {
        match (name.toAsciiLower()) {
            // General — 请求与响应均可携带的通用头部
            // 对应 C#：HttpHeaderType.General
            case "cache-control" | "connection" | "date" | "pragma"
                | "trailer" | "transfer-encoding" | "upgrade"
                | "via" | "warning" => HttpHeaderType.General

            // Request — 请求专属头部
            // 对应 C#：HttpHeaderType.Request
            case "accept" | "accept-charset" | "accept-encoding" | "accept-language"
                | "authorization" | "expect" | "from" | "host"
                | "if-match" | "if-modified-since" | "if-none-match" | "if-range"
                | "if-unmodified-since" | "max-forwards" | "proxy-authorization"
                | "range" | "referer" | "te" | "user-agent" => HttpHeaderType.Request

            // Response — 响应专属头部
            // 对应 C#：HttpHeaderType.Response
            case "accept-ranges" | "age" | "etag" | "location"
                | "proxy-authenticate" | "retry-after" | "server"
                | "vary" | "www-authenticate" => HttpHeaderType.Response

            // Content — HttpContent.Headers 管辖的内容头部
            // 对应 C#：HttpHeaderType.Content
            case "allow"
                | "content-disposition" | "content-encoding" | "content-language"
                | "content-length"      | "content-location" | "content-md5"
                | "content-range"       | "content-type"
                | "expires" | "last-modified" => HttpHeaderType.Content

            // Custom — 自定义/未知头部，不在 KnownHeaders 注册表中
            case _ => HttpHeaderType.Custom
        }
    }

 
    public static func isSingleValue(name: String): Bool {
        match (name.toAsciiLower()) {
            // Content 相关（HttpContentHeaders 管辖）
            case "content-type" | "content-length" | "content-location" | "content-range"
                | "content-disposition" | "content-md5" => true

            // 认证授权（HttpRequestHeaders 管辖）
            case "authorization" | "proxy-authorization" => true

            // 请求定位类
            case "host" | "referer" | "origin" | "from" | "range" => true

            // 条件请求类
            case "if-modified-since" | "if-unmodified-since" | "if-range" => true

            // 响应元数据类
            case "location" | "etag" | "age" | "date" | "expires" | "last-modified" | "retry-after" => true

            // 其他请求类
            case "max-forwards" => true

            // CORS 响应类（parser=null，HTTP 语义单值）
            case "access-control-allow-origin" | "access-control-allow-credentials"
                | "access-control-max-age" => true

            // 多值头部及自定义头部：默认 false（对应 SupportsMultipleValues = true 或 parser=null 的多值语义）
            case _ => false
        }
    }
}

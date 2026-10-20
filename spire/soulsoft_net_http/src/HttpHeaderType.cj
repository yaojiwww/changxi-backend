// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_net_http

/// 头部所属分类，对应 C# System.Net.Http.Headers.HttpHeaderType [Flags] enum。
///
/// C# 原始定义为位标志枚举（General=1, Request=2, Response=4, Content=8, Custom=16,
/// NonTrailing=32）；仓颉枚举不支持位运算，头部验证场景中各分类互斥，故以普通枚举表示。
/// NonTrailing 仅影响 HTTP trailer 发送逻辑，与头部类型校验无关，此处省略。
protected enum HttpHeaderType <: Equatable<HttpHeaderType> {
    /// 通用头部（请求与响应均可携带，不归属于内容），对应 HttpHeaderType.General。
    /// 示例：Cache-Control / Connection / Date / Transfer-Encoding
    | General

    /// 请求专属头部，对应 HttpHeaderType.Request。
    /// 示例：Accept / Authorization / Host / User-Agent
    | Request

    /// 响应专属头部，对应 HttpHeaderType.Response。
    /// 示例：Age / ETag / Location / Server
    | Response

    /// 内容头部（HttpContent.Headers 管辖），对应 HttpHeaderType.Content。
    /// 示例：Content-Type / Content-Length / Content-Encoding
    | Content

    /// 自定义/未知头部，对应 HttpHeaderType.Custom。
    | Custom

    public operator func ==(that: HttpHeaderType): Bool {
        match ((this, that)) {
            case (General, General) => true
            case (Request, Request) => true
            case (Response, Response) => true
            case (Content, Content) => true
            case (Custom, Custom) => true
            case _ => false
        }
    }
}

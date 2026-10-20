// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_http

import std.unicode.*
import std.convert.*
import std.collection.*

/**
 * @brief 表示 HTTP 标头集合。
 */
public interface IHeaderDictionary <: Collection<(String, Collection<String>)> & IValueProvider {
    /**
     * @brief 添加指定名称的标头值集合。
     * @param name 标头名称。
     * @param values 要添加的标头值集合。
     */
    func add(name: String, values: StringValues): Unit

    /**
     * @brief 删除指定名称的标头。
     * @param name 要删除的标头名称。
     */
    func remove(name: String): Unit

    /**
     * @brief 检查是否包含指定名称的标头。
     * @param name 要检查的标头名称。
     * @return 如果包含指定标头则返回 true，否则返回 false。
     */
    func contains(name: String): Bool

    /**
     * @brief 按名称获取标头值集合。
     * @param name 标头名称。
     * @return 指定名称对应的标头值集合。
     */
    operator func [](name: String): StringValues

    /**
     * @brief 按名称设置标头值集合。
     * @param name 标头名称。
     * @param value 要设置的标头值集合。
     */
    operator func [](name: String, value!: StringValues): Unit

    /**
     * @brief 获取指定标头的逗号分隔值集合。
     * @param name 标头名称。
     * @return 去除空值和首尾空白后的标头值集合。
     */
    func getCommaSeparatedValues(name: String): StringValues {
        return this[name] |> flatMap {f => f.split(',', removeEmpty: true)} |> map {f => f.trim()} |> collectArray
    }

    /**
     * @brief 获取或设置 Content-Length 标头
     */
    mut prop contentLength: Option<Int64> {
        get() {
            if (let Some(value) <- this[HeaderNames.ContentLength].first) {
                return Int64.tryParse(value)
            }
            return None
        }
        set(value) {
            if (let Some(value) <- value) {
                this[HeaderNames.ContentLength] = [value.toString()]
            }
        }
    }

    /**
     * @brief 获取或设置 Accept HTTP 标头
     */
    mut prop accept: StringValues {
        get() {
            this[HeaderNames.Accept]
        }
        set(value) {
            this[HeaderNames.Accept] = value
        }
    }

    /**
     * @brief 获取或设置 Accept-Charset HTTP 标头
     */
    mut prop acceptCharset: StringValues {
        get() {
            this[HeaderNames.AcceptCharset]
        }
        set(value) {
            this[HeaderNames.AcceptCharset] = value
        }
    }

    /**
     * @brief 获取或设置 Accept-Encoding HTTP 标头
     */
    mut prop acceptEncoding: StringValues {
        get() {
            this[HeaderNames.AcceptEncoding]
        }
        set(value) {
            this[HeaderNames.AcceptEncoding] = value
        }
    }

    /**
     * @brief 获取或设置 Accept-Language HTTP 标头
     */
    mut prop acceptLanguage: StringValues {
        get() {
            this[HeaderNames.AcceptLanguage]
        }
        set(value) {
            this[HeaderNames.AcceptLanguage] = value
        }
    }

    /**
     * @brief 获取或设置 Accept-Ranges HTTP 标头
     */
    mut prop acceptRanges: StringValues {
        get() {
            this[HeaderNames.AcceptRanges]
        }
        set(value) {
            this[HeaderNames.AcceptRanges] = value
        }
    }

    /**
     * @brief 获取或设置 Access-Control-Allow-Credentials HTTP 标头
     */
    mut prop accessControlAllowCredentials: StringValues {
        get() {
            this[HeaderNames.AccessControlAllowCredentials]
        }
        set(value) {
            this[HeaderNames.AccessControlAllowCredentials] = value
        }
    }

    /**
     * @brief 获取或设置 Access-Control-Allow-Headers HTTP 标头
     */
    mut prop accessControlAllowHeaders: StringValues {
        get() {
            this[HeaderNames.AccessControlAllowHeaders]
        }
        set(value) {
            this[HeaderNames.AccessControlAllowHeaders] = value
        }
    }

    /**
     * @brief 获取或设置 Access-Control-Allow-Methods HTTP 标头
     */
    mut prop accessControlAllowMethods: StringValues {
        get() {
            this[HeaderNames.AccessControlAllowMethods]
        }
        set(value) {
            this[HeaderNames.AccessControlAllowMethods] = value
        }
    }

    /**
     * @brief 获取或设置 Access-Control-Allow-Origin HTTP 标头
     */
    mut prop accessControlAllowOrigin: StringValues {
        get() {
            this[HeaderNames.AccessControlAllowOrigin]
        }
        set(value) {
            this[HeaderNames.AccessControlAllowOrigin] = value
        }
    }

    /**
     * @brief 获取或设置 Access-Control-Expose-Headers HTTP 标头
     */
    mut prop accessControlExposeHeaders: StringValues {
        get() {
            this[HeaderNames.AccessControlExposeHeaders]
        }
        set(value) {
            this[HeaderNames.AccessControlExposeHeaders] = value
        }
    }

    /**
     * @brief 获取或设置 Access-Control-Max-Age HTTP 标头
     */
    mut prop accessControlMaxAge: StringValues {
        get() {
            this[HeaderNames.AccessControlMaxAge]
        }
        set(value) {
            this[HeaderNames.AccessControlMaxAge] = value
        }
    }

    /**
     * @brief 获取或设置 Access-Control-Request-Headers HTTP 标头
     */
    mut prop accessControlRequestHeaders: StringValues {
        get() {
            this[HeaderNames.AccessControlRequestHeaders]
        }
        set(value) {
            this[HeaderNames.AccessControlRequestHeaders] = value
        }
    }

    /**
     * @brief 获取或设置 Access-Control-Request-Method HTTP 标头
     */
    mut prop accessControlRequestMethod: StringValues {
        get() {
            this[HeaderNames.AccessControlRequestMethod]
        }
        set(value) {
            this[HeaderNames.AccessControlRequestMethod] = value
        }
    }

    /**
     * @brief 获取或设置 Age HTTP 标头
     */
    mut prop age: StringValues {
        get() {
            this[HeaderNames.Age]
        }
        set(value) {
            this[HeaderNames.Age] = value
        }
    }

    /**
     * @brief 获取或设置 Allow HTTP 标头
     */
    mut prop allow: StringValues {
        get() {
            this[HeaderNames.Allow]
        }
        set(value) {
            this[HeaderNames.Allow] = value
        }
    }

    /**
     * @brief 获取或设置 Alt-Svc HTTP 标头
     */
    mut prop altSvc: StringValues {
        get() {
            this[HeaderNames.AltSvc]
        }
        set(value) {
            this[HeaderNames.AltSvc] = value
        }
    }

    /**
     * @brief 获取或设置 Authorization HTTP 标头
     */
    mut prop authorization: StringValues {
        get() {
            this[HeaderNames.Authorization]
        }
        set(value) {
            this[HeaderNames.Authorization] = value
        }
    }

    /**
     * @brief 获取或设置 baggage HTTP 标头
     */
    mut prop baggage: StringValues {
        get() {
            this[HeaderNames.Baggage]
        }
        set(value) {
            this[HeaderNames.Baggage] = value
        }
    }

    /**
     * @brief 获取或设置 Cache-Control HTTP 标头
     */
    mut prop cacheControl: StringValues {
        get() {
            this[HeaderNames.CacheControl]
        }
        set(value) {
            this[HeaderNames.CacheControl] = value
        }
    }

    /**
     * @brief 获取或设置 Connection HTTP 标头
     */
    mut prop connection: StringValues {
        get() {
            this[HeaderNames.Connection]
        }
        set(value) {
            this[HeaderNames.Connection] = value
        }
    }

    /**
     * @brief 获取或设置 Content-Disposition HTTP 标头
     */
    mut prop contentDisposition: StringValues {
        get() {
            this[HeaderNames.ContentDisposition]
        }
        set(value) {
            this[HeaderNames.ContentDisposition] = value
        }
    }

    /**
     * @brief 获取或设置 Content-Encoding HTTP 标头
     */
    mut prop contentEncoding: StringValues {
        get() {
            this[HeaderNames.ContentEncoding]
        }
        set(value) {
            this[HeaderNames.ContentEncoding] = value
        }
    }

    /**
     * @brief 获取或设置 Content-Language HTTP 标头
     */
    mut prop contentLanguage: StringValues {
        get() {
            this[HeaderNames.ContentLanguage]
        }
        set(value) {
            this[HeaderNames.ContentLanguage] = value
        }
    }

    /**
     * @brief 获取或设置 Content-Location HTTP 标头
     */
    mut prop contentLocation: StringValues {
        get() {
            this[HeaderNames.ContentLocation]
        }
        set(value) {
            this[HeaderNames.ContentLocation] = value
        }
    }

    /**
     * @brief 获取或设置 Content-MD5 HTTP 标头
     */
    mut prop contentMD5: StringValues {
        get() {
            this[HeaderNames.ContentMD5]
        }
        set(value) {
            this[HeaderNames.ContentMD5] = value
        }
    }

    /**
     * @brief 获取或设置 Content-Range HTTP 标头
     */
    mut prop contentRange: StringValues {
        get() {
            this[HeaderNames.ContentRange]
        }
        set(value) {
            this[HeaderNames.ContentRange] = value
        }
    }

    /**
     * @brief 获取或设置 Content-Security-Policy HTTP 标头
     */
    mut prop contentSecurityPolicy: StringValues {
        get() {
            this[HeaderNames.ContentSecurityPolicy]
        }
        set(value) {
            this[HeaderNames.ContentSecurityPolicy] = value
        }
    }

    /**
     * @brief 获取或设置 Content-Security-Policy-Report-Only HTTP 标头
     */
    mut prop contentSecurityPolicyReportOnly: StringValues {
        get() {
            this[HeaderNames.ContentSecurityPolicyReportOnly]
        }
        set(value) {
            this[HeaderNames.ContentSecurityPolicyReportOnly] = value
        }
    }

    /**
     * @brief 获取或设置 Content-Type HTTP 标头
     */
    mut prop contentType: StringValues {
        get() {
            this[HeaderNames.ContentType]
        }
        set(value) {
            this[HeaderNames.ContentType] = value
        }
    }

    /**
     * @brief 获取或设置 Correlation-Context HTTP 标头
     */
    mut prop correlationContext: StringValues {
        get() {
            this[HeaderNames.CorrelationContext]
        }
        set(value) {
            this[HeaderNames.CorrelationContext] = value
        }
    }

    /**
     * @brief 获取或设置 Cookie HTTP 标头
     */
    mut prop cookie: StringValues {
        get() {
            this[HeaderNames.Cookie]
        }
        set(value) {
            this[HeaderNames.Cookie] = value
        }
    }

    /**
     * @brief 获取或设置 Date HTTP 标头
     */
    mut prop date: StringValues {
        get() {
            this[HeaderNames.Date]
        }
        set(value) {
            this[HeaderNames.Date] = value
        }
    }

    /**
     * @brief 获取或设置 ETag HTTP 标头
     */
    mut prop eTag: StringValues {
        get() {
            this[HeaderNames.ETag]
        }
        set(value) {
            this[HeaderNames.ETag] = value
        }
    }

    /**
     * @brief 获取或设置 Expires HTTP 标头
     */
    mut prop expires: StringValues {
        get() {
            this[HeaderNames.Expires]
        }
        set(value) {
            this[HeaderNames.Expires] = value
        }
    }

    /**
     * @brief 获取或设置 Expect HTTP 标头
     */
    mut prop expect: StringValues {
        get() {
            this[HeaderNames.Expect]
        }
        set(value) {
            this[HeaderNames.Expect] = value
        }
    }

    /**
     * @brief 获取或设置 From HTTP 标头
     */
    mut prop from: StringValues {
        get() {
            this[HeaderNames.From]
        }
        set(value) {
            this[HeaderNames.From] = value
        }
    }

    /**
     * @brief 获取或设置 Grpc-Accept-Encoding HTTP 标头
     */
    mut prop grpcAcceptEncoding: StringValues {
        get() {
            this[HeaderNames.GrpcAcceptEncoding]
        }
        set(value) {
            this[HeaderNames.GrpcAcceptEncoding] = value
        }
    }

    /**
     * @brief 获取或设置 Grpc-Encoding HTTP 标头
     */
    mut prop grpcEncoding: StringValues {
        get() {
            this[HeaderNames.GrpcEncoding]
        }
        set(value) {
            this[HeaderNames.GrpcEncoding] = value
        }
    }

    /**
     * @brief 获取或设置 Grpc-Message HTTP 标头
     */
    mut prop grpcMessage: StringValues {
        get() {
            this[HeaderNames.GrpcMessage]
        }
        set(value) {
            this[HeaderNames.GrpcMessage] = value
        }
    }

    /**
     * @brief 获取或设置 Grpc-Status HTTP 标头
     */
    mut prop grpcStatus: StringValues {
        get() {
            this[HeaderNames.GrpcStatus]
        }
        set(value) {
            this[HeaderNames.GrpcStatus] = value
        }
    }

    /**
     * @brief 获取或设置 Grpc-Timeout HTTP 标头
     */
    mut prop grpcTimeout: StringValues {
        get() {
            this[HeaderNames.GrpcTimeout]
        }
        set(value) {
            this[HeaderNames.GrpcTimeout] = value
        }
    }

    /**
     * @brief 获取或设置 Host HTTP 标头
     */
    mut prop host: StringValues {
        get() {
            this[HeaderNames.Host]
        }
        set(value) {
            this[HeaderNames.Host] = value
        }
    }

    /**
     * @brief 获取或设置 Keep-Alive HTTP 标头
     */
    mut prop keepAlive: StringValues {
        get() {
            this[HeaderNames.KeepAlive]
        }
        set(value) {
            this[HeaderNames.KeepAlive] = value
        }
    }

    /**
     * @brief 获取或设置 If-Match HTTP 标头
     */
    mut prop ifMatch: StringValues {
        get() {
            this[HeaderNames.IfMatch]
        }
        set(value) {
            this[HeaderNames.IfMatch] = value
        }
    }

    /**
     * @brief 获取或设置 If-Modified-Since HTTP 标头
     */
    mut prop ifModifiedSince: StringValues {
        get() {
            this[HeaderNames.IfModifiedSince]
        }
        set(value) {
            this[HeaderNames.IfModifiedSince] = value
        }
    }

    /**
     * @brief 获取或设置 If-None-Match HTTP 标头
     */
    mut prop ifNoneMatch: StringValues {
        get() {
            this[HeaderNames.IfNoneMatch]
        }
        set(value) {
            this[HeaderNames.IfNoneMatch] = value
        }
    }

    /**
     * @brief 获取或设置 If-Range HTTP 标头
     */
    mut prop ifRange: StringValues {
        get() {
            this[HeaderNames.IfRange]
        }
        set(value) {
            this[HeaderNames.IfRange] = value
        }
    }

    /**
     * @brief 获取或设置 If-Unmodified-Since HTTP 标头
     */
    mut prop ifUnmodifiedSince: StringValues {
        get() {
            this[HeaderNames.IfUnmodifiedSince]
        }
        set(value) {
            this[HeaderNames.IfUnmodifiedSince] = value
        }
    }

    /**
     * @brief 获取或设置 Last-Modified HTTP 标头
     */
    mut prop lastModified: StringValues {
        get() {
            this[HeaderNames.LastModified]
        }
        set(value) {
            this[HeaderNames.LastModified] = value
        }
    }

    /**
     * @brief 获取或设置 Link HTTP 标头
     */
    mut prop link: StringValues {
        get() {
            this[HeaderNames.Link]
        }
        set(value) {
            this[HeaderNames.Link] = value
        }
    }

    /**
     * @brief 获取或设置 Location HTTP 标头
     */
    mut prop location: StringValues {
        get() {
            this[HeaderNames.Location]
        }
        set(value) {
            this[HeaderNames.Location] = value
        }
    }

    /**
     * @brief 获取或设置 Max-Forwards HTTP 标头
     */
    mut prop maxForwards: StringValues {
        get() {
            this[HeaderNames.MaxForwards]
        }
        set(value) {
            this[HeaderNames.MaxForwards] = value
        }
    }

    /**
     * @brief 获取或设置 Origin HTTP 标头
     */
    mut prop origin: StringValues {
        get() {
            this[HeaderNames.Origin]
        }
        set(value) {
            this[HeaderNames.Origin] = value
        }
    }

    /**
     * @brief 获取或设置 Pragma HTTP 标头
     */
    mut prop pragma: StringValues {
        get() {
            this[HeaderNames.Pragma]
        }
        set(value) {
            this[HeaderNames.Pragma] = value
        }
    }

    /**
     * @brief 获取或设置 Proxy-Authenticate HTTP 标头
     */
    mut prop proxyAuthenticate: StringValues {
        get() {
            this[HeaderNames.ProxyAuthenticate]
        }
        set(value) {
            this[HeaderNames.ProxyAuthenticate] = value
        }
    }

    /**
     * @brief 获取或设置 Proxy-Authorization HTTP 标头
     */
    mut prop proxyAuthorization: StringValues {
        get() {
            this[HeaderNames.ProxyAuthorization]
        }
        set(value) {
            this[HeaderNames.ProxyAuthorization] = value
        }
    }

    /**
     * @brief 获取或设置 Proxy-Connection HTTP 标头
     */
    mut prop proxyConnection: StringValues {
        get() {
            this[HeaderNames.ProxyConnection]
        }
        set(value) {
            this[HeaderNames.ProxyConnection] = value
        }
    }

    /**
     * @brief 获取或设置 Range HTTP 标头
     */
    mut prop range: StringValues {
        get() {
            this[HeaderNames.Range]
        }
        set(value) {
            this[HeaderNames.Range] = value
        }
    }

    /**
     * @brief 获取或设置 Referer HTTP 标头
     */
    mut prop referer: StringValues {
        get() {
            this[HeaderNames.Referer]
        }
        set(value) {
            this[HeaderNames.Referer] = value
        }
    }

    /**
     * @brief 获取或设置 Retry-After HTTP 标头
     */
    mut prop retryAfter: StringValues {
        get() {
            this[HeaderNames.RetryAfter]
        }
        set(value) {
            this[HeaderNames.RetryAfter] = value
        }
    }

    /**
     * @brief 获取或设置 Request-Id HTTP 标头
     */
    mut prop requestId: StringValues {
        get() {
            this[HeaderNames.RequestId]
        }
        set(value) {
            this[HeaderNames.RequestId] = value
        }
    }

    /**
     * @brief 获取或设置 Sec-WebSocket-Accept HTTP 标头
     */
    mut prop secWebSocketAccept: StringValues {
        get() {
            this[HeaderNames.SecWebSocketAccept]
        }
        set(value) {
            this[HeaderNames.SecWebSocketAccept] = value
        }
    }

    /**
     * @brief 获取或设置 Sec-WebSocket-Key HTTP 标头
     */
    mut prop secWebSocketKey: StringValues {
        get() {
            this[HeaderNames.SecWebSocketKey]
        }
        set(value) {
            this[HeaderNames.SecWebSocketKey] = value
        }
    }

    /**
     * @brief 获取或设置 Sec-WebSocket-Protocol HTTP 标头
     */
    mut prop secWebSocketProtocol: StringValues {
        get() {
            this[HeaderNames.SecWebSocketProtocol]
        }
        set(value) {
            this[HeaderNames.SecWebSocketProtocol] = value
        }
    }

    /**
     * @brief 获取或设置 Sec-WebSocket-Version HTTP 标头
     */
    mut prop secWebSocketVersion: StringValues {
        get() {
            this[HeaderNames.SecWebSocketVersion]
        }
        set(value) {
            this[HeaderNames.SecWebSocketVersion] = value
        }
    }

    /**
     * @brief 获取或设置 Sec-WebSocket-Extensions HTTP 标头
     */
    mut prop secWebSocketExtensions: StringValues {
        get() {
            this[HeaderNames.SecWebSocketExtensions]
        }
        set(value) {
            this[HeaderNames.SecWebSocketExtensions] = value
        }
    }

    /**
     * @brief 获取或设置 Server HTTP 标头
     */
    mut prop server: StringValues {
        get() {
            this[HeaderNames.Server]
        }
        set(value) {
            this[HeaderNames.Server] = value
        }
    }

    /**
     * @brief 获取或设置 Set-Cookie HTTP 标头
     */
    mut prop setCookie: StringValues {
        get() {
            this[HeaderNames.SetCookie]
        }
        set(value) {
            this[HeaderNames.SetCookie] = value
        }
    }

    /**
     * @brief 获取或设置 Strict-Transport-Security HTTP 标头
     */
    mut prop strictTransportSecurity: StringValues {
        get() {
            this[HeaderNames.StrictTransportSecurity]
        }
        set(value) {
            this[HeaderNames.StrictTransportSecurity] = value
        }
    }

    /**
     * @brief 获取或设置 TE HTTP 标头
     */
    mut prop te: StringValues {
        get() {
            this[HeaderNames.TE]
        }
        set(value) {
            this[HeaderNames.TE] = value
        }
    }

    /**
     * @brief 获取或设置 Trailer HTTP 标头
     */
    mut prop trailer: StringValues {
        get() {
            this[HeaderNames.Trailer]
        }
        set(value) {
            this[HeaderNames.Trailer] = value
        }
    }

    /**
     * @brief 获取或设置 Transfer-Encoding HTTP 标头
     */
    mut prop transferEncoding: StringValues {
        get() {
            this[HeaderNames.TransferEncoding]
        }
        set(value) {
            this[HeaderNames.TransferEncoding] = value
        }
    }

    /**
     * @brief 获取或设置 Translate HTTP 标头
     */
    mut prop translate: StringValues {
        get() {
            this[HeaderNames.Translate]
        }
        set(value) {
            this[HeaderNames.Translate] = value
        }
    }

    /**
     * @brief 获取或设置 traceparent HTTP 标头
     */
    mut prop traceParent: StringValues {
        get() {
            this[HeaderNames.TraceParent]
        }
        set(value) {
            this[HeaderNames.TraceParent] = value
        }
    }

    /**
     * @brief 获取或设置 tracestate HTTP 标头
     */
    mut prop traceState: StringValues {
        get() {
            this[HeaderNames.TraceState]
        }
        set(value) {
            this[HeaderNames.TraceState] = value
        }
    }

    /**
     * @brief 获取或设置 Upgrade HTTP 标头
     */
    mut prop upgrade: StringValues {
        get() {
            this[HeaderNames.Upgrade]
        }
        set(value) {
            this[HeaderNames.Upgrade] = value
        }
    }

    /**
     * @brief 获取或设置 Upgrade-Insecure-Requests HTTP 标头
     */
    mut prop upgradeInsecureRequests: StringValues {
        get() {
            this[HeaderNames.UpgradeInsecureRequests]
        }
        set(value) {
            this[HeaderNames.UpgradeInsecureRequests] = value
        }
    }

    /**
     * @brief 获取或设置 User-Agent HTTP 标头
     */
    mut prop userAgent: StringValues {
        get() {
            this[HeaderNames.UserAgent]
        }
        set(value) {
            this[HeaderNames.UserAgent] = value
        }
    }

    /**
     * @brief 获取或设置 Vary HTTP 标头
     */
    mut prop vary: StringValues {
        get() {
            this[HeaderNames.Vary]
        }
        set(value) {
            this[HeaderNames.Vary] = value
        }
    }

    /**
     * @brief 获取或设置 Via HTTP 标头
     */
    mut prop via: StringValues {
        get() {
            this[HeaderNames.Via]
        }
        set(value) {
            this[HeaderNames.Via] = value
        }
    }

    /**
     * @brief 获取或设置 Warning HTTP 标头
     */
    mut prop warning: StringValues {
        get() {
            this[HeaderNames.Warning]
        }
        set(value) {
            this[HeaderNames.Warning] = value
        }
    }

    /**
     * @brief 获取或设置 Sec-WebSocket-Protocol HTTP 标头
     */
    mut prop webSocketSubProtocols: StringValues {
        get() {
            this[HeaderNames.WebSocketSubProtocols]
        }
        set(value) {
            this[HeaderNames.WebSocketSubProtocols] = value
        }
    }

    /**
     * @brief 获取或设置 WWW-Authenticate HTTP 标头
     */
    mut prop wwwAuthenticate: StringValues {
        get() {
            this[HeaderNames.WWWAuthenticate]
        }
        set(value) {
            this[HeaderNames.WWWAuthenticate] = value
        }
    }

    /**
     * @brief 获取或设置 X-Content-Type-Options HTTP 标头
     */
    mut prop xContentTypeOptions: StringValues {
        get() {
            this[HeaderNames.XContentTypeOptions]
        }
        set(value) {
            this[HeaderNames.XContentTypeOptions] = value
        }
    }

    /**
     * @brief 获取或设置 X-Frame-Options HTTP 标头
     */
    mut prop xFrameOptions: StringValues {
        get() {
            this[HeaderNames.XFrameOptions]
        }
        set(value) {
            this[HeaderNames.XFrameOptions] = value
        }
    }

    /**
     * @brief 获取或设置 X-Powered-By HTTP 标头
     */
    mut prop xPoweredBy: StringValues {
        get() {
            this[HeaderNames.XPoweredBy]
        }
        set(value) {
            this[HeaderNames.XPoweredBy] = value
        }
    }

    /**
     * @brief 获取或设置 X-Requested-With HTTP 标头
     */
    mut prop xRequestedWith: StringValues {
        get() {
            this[HeaderNames.XRequestedWith]
        }
        set(value) {
            this[HeaderNames.XRequestedWith] = value
        }
    }

    /**
     * @brief 获取或设置 X-UA-Compatible HTTP 标头
     */
    mut prop xUACompatible: StringValues {
        get() {
            this[HeaderNames.XUACompatible]
        }
        set(value) {
            this[HeaderNames.XUACompatible] = value
        }
    }

    /**
     * @brief 获取或设置 X-XSS-Protection HTTP 标头
     */
    mut prop xXSSProtection: StringValues {
        get() {
            this[HeaderNames.XXSSProtection]
        }
        set(value) {
            this[HeaderNames.XXSSProtection] = value
        }
    }
}

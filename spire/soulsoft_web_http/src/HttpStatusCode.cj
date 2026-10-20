// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_http

/**
 * @brief 提供常用 HTTP 状态码常量。
 */
public struct StatusCodes {
    /**
     * @brief 表示 100 Continue HTTP 状态码。
     */
    public static const Continue: UInt16 = 100
    /**
     * @brief 表示 101 Switching Protocols HTTP 状态码。
     */
    public static const SwitchingProtocols: UInt16 = 101
    /**
     * @brief 表示 102 Processing HTTP 状态码。
     */
    public static const Processing: UInt16 = 102
    /**
     * @brief 表示 103 Early Hints HTTP 状态码。
     */
    public static const EarlyHints: UInt16 = 103

    /**
     * @brief 表示 200 Ok HTTP 状态码。
     */
    public static const Ok: UInt16 = 200
    /**
     * @brief 表示 201 Created HTTP 状态码。
     */
    public static const Created: UInt16 = 201
    /**
     * @brief 表示 202 Accepted HTTP 状态码。
     */
    public static const Accepted: UInt16 = 202
    /**
     * @brief 表示 203 Non Authoritative Info HTTP 状态码。
     */
    public static const NonAuthoritativeInfo: UInt16 = 203
    /**
     * @brief 表示 204 No Content HTTP 状态码。
     */
    public static const NoContent: UInt16 = 204
    /**
     * @brief 表示 205 Reset Content HTTP 状态码。
     */
    public static const ResetContent: UInt16 = 205
    /**
     * @brief 表示 206 Partial Content HTTP 状态码。
     */
    public static const PartialContent: UInt16 = 206
    /**
     * @brief 表示 207 Multi Status HTTP 状态码。
     */
    public static const MultiStatus: UInt16 = 207
    /**
     * @brief 表示 208 Already Reported HTTP 状态码。
     */
    public static const AlreadyReported: UInt16 = 208
    /**
     * @brief 表示 226 Im Used HTTP 状态码。
     */
    public static const ImUsed: UInt16 = 226

    /**
     * @brief 表示 300 Multiple Choices HTTP 状态码。
     */
    public static const MultipleChoices: UInt16 = 300
    /**
     * @brief 表示 301 Moved Permanently HTTP 状态码。
     */
    public static const MovedPermanently: UInt16 = 301
    /**
     * @brief 表示 302 Found HTTP 状态码。
     */
    public static const Found: UInt16 = 302
    /**
     * @brief 表示 303 See Other HTTP 状态码。
     */
    public static const SeeOther: UInt16 = 303
    /**
     * @brief 表示 304 Not Modified HTTP 状态码。
     */
    public static const NotModified: UInt16 = 304
    /**
     * @brief 表示 305 Use Proxy HTTP 状态码。
     */
    public static const UseProxy: UInt16 = 305
    /**
     * @brief 表示 307 Temporary Redirect HTTP 状态码。
     */
    public static const TemporaryRedirect: UInt16 = 307
    /**
     * @brief 表示 308 Permanent Redirect HTTP 状态码。
     */
    public static const PermanentRedirect: UInt16 = 308

    /**
     * @brief 表示 400 Bad Request HTTP 状态码。
     */
    public static const BadRequest: UInt16 = 400
    /**
     * @brief 表示 401 Unauthorized HTTP 状态码。
     */
    public static const Unauthorized: UInt16 = 401
    /**
     * @brief 表示 402 Payment Required HTTP 状态码。
     */
    public static const PaymentRequired: UInt16 = 402
    /**
     * @brief 表示 403 Forbidden HTTP 状态码。
     */
    public static const Forbidden: UInt16 = 403
    /**
     * @brief 表示 404 Not Found HTTP 状态码。
     */
    public static const NotFound: UInt16 = 404
    /**
     * @brief 表示 405 Method Not Allowed HTTP 状态码。
     */
    public static const MethodNotAllowed: UInt16 = 405
    /**
     * @brief 表示 406 Not Acceptable HTTP 状态码。
     */
    public static const NotAcceptable: UInt16 = 406
    /**
     * @brief 表示 407 Proxy Auth Required HTTP 状态码。
     */
    public static const ProxyAuthRequired: UInt16 = 407
    /**
     * @brief 表示 408 Request Timeout HTTP 状态码。
     */
    public static const RequestTimeout: UInt16 = 408
    /**
     * @brief 表示 409 Conflict HTTP 状态码。
     */
    public static const Conflict: UInt16 = 409
    /**
     * @brief 表示 410 Gone HTTP 状态码。
     */
    public static const Gone: UInt16 = 410
    /**
     * @brief 表示 411 Length Required HTTP 状态码。
     */
    public static const LengthRequired: UInt16 = 411
    /**
     * @brief 表示 412 Precondition Failed HTTP 状态码。
     */
    public static const PreconditionFailed: UInt16 = 412
    /**
     * @brief 表示 413 Request Content Too Large HTTP 状态码。
     */
    public static const RequestContentTooLarge: UInt16 = 413
    /**
     * @brief 表示 414 Request Uri Too Long HTTP 状态码。
     */
    public static const RequestUriTooLong: UInt16 = 414
    /**
     * @brief 表示 415 Unsupported Media Type HTTP 状态码。
     */
    public static const UnsupportedMediaType: UInt16 = 415
    /**
     * @brief 表示 416 Requested Range Not Satisfiable HTTP 状态码。
     */
    public static const RequestedRangeNotSatisfiable: UInt16 = 416
    /**
     * @brief 表示 417 Expectation Failed HTTP 状态码。
     */
    public static const ExpectationFailed: UInt16 = 417
    /**
     * @brief 表示 418 Teapot HTTP 状态码。
     */
    public static const Teapot: UInt16 = 418
    /**
     * @brief 表示 421 Misdirected Request HTTP 状态码。
     */
    public static const MisdirectedRequest: UInt16 = 421
    /**
     * @brief 表示 422 Unprocessable Entity HTTP 状态码。
     */
    public static const UnprocessableEntity: UInt16 = 422
    /**
     * @brief 表示 423 Locked HTTP 状态码。
     */
    public static const Locked: UInt16 = 423
    /**
     * @brief 表示 424 Failed Dependency HTTP 状态码。
     */
    public static const FailedDependency: UInt16 = 424
    /**
     * @brief 表示 425 Too Early HTTP 状态码。
     */
    public static const TooEarly: UInt16 = 425
    /**
     * @brief 表示 426 Upgrade Required HTTP 状态码。
     */
    public static const UpgradeRequired: UInt16 = 426
    /**
     * @brief 表示 428 Precondition Required HTTP 状态码。
     */
    public static const PreconditionRequired: UInt16 = 428
    /**
     * @brief 表示 429 Too Many Requests HTTP 状态码。
     */
    public static const TooManyRequests: UInt16 = 429
    /**
     * @brief 表示 431 Request Header Fields Too Large HTTP 状态码。
     */
    public static const RequestHeaderFieldsTooLarge: UInt16 = 431
    /**
     * @brief 表示 451 Unavailable For Legal Reasons HTTP 状态码。
     */
    public static const UnavailableForLegalReasons: UInt16 = 451

    /**
     * @brief 表示 500 Internal Server Error HTTP 状态码。
     */
    public static const InternalServerError: UInt16 = 500
    /**
     * @brief 表示 501 Not Implemented HTTP 状态码。
     */
    public static const NotImplemented: UInt16 = 501
    /**
     * @brief 表示 502 Bad Gateway HTTP 状态码。
     */
    public static const BadGateway: UInt16 = 502
    /**
     * @brief 表示 503 Service Unavailable HTTP 状态码。
     */
    public static const ServiceUnavailable: UInt16 = 503
    /**
     * @brief 表示 504 Gateway Timeout HTTP 状态码。
     */
    public static const GatewayTimeout: UInt16 = 504
    /**
     * @brief 表示 505 Http Version Not Supported HTTP 状态码。
     */
    public static const HttpVersionNotSupported: UInt16 = 505
    /**
     * @brief 表示 506 Variant Also Negotiates HTTP 状态码。
     */
    public static const VariantAlsoNegotiates: UInt16 = 506
    /**
     * @brief 表示 507 Insufficient Storage HTTP 状态码。
     */
    public static const InsufficientStorage: UInt16 = 507
    /**
     * @brief 表示 508 Loop Detected HTTP 状态码。
     */
    public static const LoopDetected: UInt16 = 508
    /**
     * @brief 表示 510 Not Extended HTTP 状态码。
     */
    public static const NotExtended: UInt16 = 510
    /**
     * @brief 表示 511 Network Authentication Required HTTP 状态码。
     */
    public static const NetworkAuthenticationRequired: UInt16 = 511
}

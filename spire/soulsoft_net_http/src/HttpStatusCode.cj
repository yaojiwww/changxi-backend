// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_net_http

/**
 * @brief 表示 HTTP 状态码数字常量。
 */
public struct HttpStatusCode {
    /**
     * @brief 表示 HTTP 100 Continue 状态。
     */
    public static const Continue = 100
    /**
     * @brief 表示 HTTP 101 Switching Protocols 状态。
     */
    public static const SwitchingProtocols = 101
    /**
     * @brief 表示 HTTP 102 Processing 状态。
     */
    public static const Processing = 102
    /**
     * @brief 表示 HTTP 103 Early Hints 状态。
     */
    public static const EarlyHints = 103
    /**
     * @brief 表示 HTTP 200 OK 状态。
     */
    public static const OK = 200
    /**
     * @brief 表示 HTTP 201 Created 状态。
     */
    public static const Created = 201
    /**
     * @brief 表示 HTTP 202 Accepted 状态。
     */
    public static const Accepted = 202
    /**
     * @brief 表示 HTTP 203 Non-Authoritative Information 状态。
     */
    public static const NonAuthoritativeInformation = 203
    /**
     * @brief 表示 HTTP 204 No Content 状态。
     */
    public static const NoContent = 204
    /**
     * @brief 表示 HTTP 205 Reset Content 状态。
     */
    public static const ResetContent = 205
    /**
     * @brief 表示 HTTP 206 Partial Content 状态。
     */
    public static const PartialContent = 206
    /**
     * @brief 表示 HTTP 207 Multi-Status 状态。
     */
    public static const MultiStatus = 207
    /**
     * @brief 表示 HTTP 208 Already Reported 状态。
     */
    public static const AlreadyReported = 208
    /**
     * @brief 表示 HTTP 226 IM Used 状态。
     */
    public static const IMUsed = 226
    /**
     * @brief 表示 HTTP 300 Multiple Choices 状态。
     */
    public static const MultipleChoices = 300
    /**
     * @brief 表示 HTTP 301 Moved Permanently 状态。
     */
    public static const MovedPermanently = 301
    /**
     * @brief 表示 HTTP 302 Found 状态。
     */
    public static const Found = 302
    /**
     * @brief 表示 HTTP 303 See Other 状态。
     */
    public static const SeeOther = 303
    /**
     * @brief 表示 HTTP 304 Not Modified 状态。
     */
    public static const NotModified = 304
    /**
     * @brief 表示 HTTP 305 Use Proxy 状态。
     */
    public static const UseProxy = 305
    /**
     * @brief 表示 HTTP 306 Unused 状态。
     */
    public static const Unused = 306
    /**
     * @brief 表示 HTTP 307 Temporary Redirect 状态。
     */
    public static const TemporaryRedirect = 307
    /**
     * @brief 表示 HTTP 308 Permanent Redirect 状态。
     */
    public static const PermanentRedirect = 308
    /**
     * @brief 表示 HTTP 400 Bad Request 状态。
     */
    public static const BadRequest = 400
    /**
     * @brief 表示 HTTP 401 Unauthorized 状态。
     */
    public static const Unauthorized = 401
    /**
     * @brief 表示 HTTP 402 Payment Required 状态。
     */
    public static const PaymentRequired = 402
    /**
     * @brief 表示 HTTP 403 Forbidden 状态。
     */
    public static const Forbidden = 403
    /**
     * @brief 表示 HTTP 404 Not Found 状态。
     */
    public static const NotFound = 404
    /**
     * @brief 表示 HTTP 405 Method Not Allowed 状态。
     */
    public static const MethodNotAllowed = 405
    /**
     * @brief 表示 HTTP 406 Not Acceptable 状态。
     */
    public static const NotAcceptable = 406
    /**
     * @brief 表示 HTTP 407 Proxy Authentication Required 状态。
     */
    public static const ProxyAuthenticationRequired = 407
    /**
     * @brief 表示 HTTP 408 Request Timeout 状态。
     */
    public static const RequestTimeout = 408
    /**
     * @brief 表示 HTTP 409 Conflict 状态。
     */
    public static const Conflict = 409
    /**
     * @brief 表示 HTTP 410 Gone 状态。
     */
    public static const Gone = 410
    /**
     * @brief 表示 HTTP 411 Length Required 状态。
     */
    public static const LengthRequired = 411
    /**
     * @brief 表示 HTTP 412 Precondition Failed 状态。
     */
    public static const PreconditionFailed = 412
    /**
     * @brief 表示 HTTP 413 Request Entity Too Large 状态。
     */
    public static const RequestEntityTooLarge = 413
    /**
     * @brief 表示 HTTP 414 Request-URI Too Long 状态。
     */
    public static const RequestUriTooLong = 414
    /**
     * @brief 表示 HTTP 415 Unsupported Media Type 状态。
     */
    public static const UnsupportedMediaType = 415
    /**
     * @brief 表示 HTTP 416 Requested Range Not Satisfiable 状态。
     */
    public static const RequestedRangeNotSatisfiable = 416
    /**
     * @brief 表示 HTTP 417 Expectation Failed 状态。
     */
    public static const ExpectationFailed = 417
    /**
     * @brief 表示 HTTP 421 Misdirected Request 状态。
     */
    public static const MisdirectedRequest = 421
    /**
     * @brief 表示 HTTP 422 Unprocessable Entity 状态。
     */
    public static const UnprocessableEntity = 422
    /**
     * @brief 表示 HTTP 423 Locked 状态。
     */
    public static const Locked = 423
    /**
     * @brief 表示 HTTP 424 Failed Dependency 状态。
     */
    public static const FailedDependency = 424
    /**
     * @brief 表示 HTTP 426 Upgrade Required 状态。
     */
    public static const UpgradeRequired = 426
    /**
     * @brief 表示 HTTP 428 Precondition Required 状态。
     */
    public static const PreconditionRequired = 428
    /**
     * @brief 表示 HTTP 429 Too Many Requests 状态。
     */
    public static const TooManyRequests = 429
    /**
     * @brief 表示 HTTP 431 Request Header Fields Too Large 状态。
     */
    public static const RequestHeaderFieldsTooLarge = 431
    /**
     * @brief 表示 HTTP 451 Unavailable For Legal Reasons 状态。
     */
    public static const UnavailableForLegalReasons = 451
    /**
     * @brief 表示 HTTP 500 Internal Server Error 状态。
     */
    public static const InternalServerError = 500
    /**
     * @brief 表示 HTTP 501 Not Implemented 状态。
     */
    public static const NotImplemented = 501
    /**
     * @brief 表示 HTTP 502 Bad Gateway 状态。
     */
    public static const BadGateway = 502
    /**
     * @brief 表示 HTTP 503 Service Unavailable 状态。
     */
    public static const ServiceUnavailable = 503
    /**
     * @brief 表示 HTTP 504 Gateway Timeout 状态。
     */
    public static const GatewayTimeout = 504
    /**
     * @brief 表示 HTTP 505 HTTP Version Not Supported 状态。
     */
    public static const HttpVersionNotSupported = 505
    /**
     * @brief 表示 HTTP 506 Variant Also Negotiates 状态。
     */
    public static const VariantAlsoNegotiates = 506
    /**
     * @brief 表示 HTTP 507 Insufficient Storage 状态。
     */
    public static const InsufficientStorage = 507
    /**
     * @brief 表示 HTTP 508 Loop Detected 状态。
     */
    public static const LoopDetected = 508
    /**
     * @brief 表示 HTTP 510 Not Extended 状态。
     */
    public static const NotExtended = 510
    /**
     * @brief 表示 HTTP 511 Network Authentication Required 状态。
     */
    public static const NetworkAuthenticationRequired = 511
}

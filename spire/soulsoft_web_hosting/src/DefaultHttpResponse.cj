// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_hosting

import std.io.*
import std.collection.*
import stdx.net.http.HttpResponseWriter
import stdx.net.http.HttpContext as HttpContextBase

class DefaultHttpResponse <: HttpResponse {
    private let _serverContext: HttpContextBase
    private var _owningContext: ?HttpContext = None
    private var _responseHeaders: ?HeaderDictionary = None
    private var _responseCookies: ?IResponseCookies = None
    private var _statusCode: UInt16 = StatusCodes.Ok
    private var _hasStarted: Bool = false
    private var _hasInvokedOnStarting: Bool = false
    private var _responseWriter: ?HttpResponseWriter = None
    private var _responseBodyStream: ?HttpResponseBodyStream = None
    // 逆序执行：使用 ArrayList 存储，invoke 时从尾部向头部遍历
    private var _onStartingCallbacks: ?ArrayList<() -> Unit> = None
    private var _onCompletedCallbacks: ?ArrayList<() -> Unit> = None

    init(ctx: HttpContextBase) {
        _serverContext = ctx
    }

    /**
     * @brief 返回当前响应关联的 HTTP 上下文。
     * @return 当前 HTTP 上下文。
     * @throws Exception 当上下文尚未初始化时抛出。
     */
    public prop httpContext: HttpContext {
        get() {
            _owningContext ?? throw Exception("HttpContext not initialized")
        }
    }

    /**
     * @brief 检查响应是否已开始写出。
     * @return 如果响应已开始写出则返回 true，否则返回 false。
     */
    public prop hasStarted: Bool {
        get() {
            _hasStarted
        }
    }

    /**
     * @brief 获取或设置响应状态码。
     * @return 当前响应状态码。
     */
    public mut prop statusCode: UInt16 {
        get() {
            _statusCode
        }
        set(value) {
            ensureMutable("The status code")
            _statusCode = value
        }
    }

    /**
     * @brief 获取或设置响应内容类型。
     * @return 当前响应内容类型；如果未设置则返回空。
     */
    public mut prop contentType: ?String {
        get() {
            headers.contentType.first
        }
        set(value) {
            if (let Some(value) <- value) {
                ensureMutable("The response headers")
                headers.contentType = [value]
            }
        }
    }

    /**
     * @brief 获取或设置响应内容长度。
     * @return 当前响应内容长度；如果未设置则返回空。
     */
    public mut prop contentLength: ?Int64 {
        get() {
            headers.contentLength
        }
        set(value) {
            ensureMutable("The response headers")
            headers.contentLength = value
        }
    }

    /**
     * @brief 返回响应体流。
     * @return 当前响应体流。
     */
    public prop body: IOStream {
        get() {
            if (_responseBodyStream.isNone()) {
                _responseBodyStream = HttpResponseBodyStream(this)
            }
            return _responseBodyStream.getOrThrow()
        }
    }

    /**
     * @brief 返回响应 Cookie 集合。
     * @return 当前响应 Cookie 集合。
     */
    public prop cookies: IResponseCookies {
        get() {
            if (_responseCookies.isNone()) {
                _responseCookies = ResponseCookies(this)
            }
            return _responseCookies.getOrThrow()
        }
    }

    /**
     * @brief 返回响应头集合。
     * @return 当前响应头集合。
     */
    public prop headers: IHeaderDictionary {
        get() {
            return getOrCreateResponseHeaders()
        }
    }

    /**
     * @brief 将字节数组写入响应体。
     * @param bytes 要写入响应体的字节数据。
     */
    public func write(bytes: Array<Byte>): Unit {
        let statusCode = _statusCode
        let responseMustNotHaveBody = responseStatusMustNotHaveBody(statusCode)
        if (responseMustNotHaveBody) {
            // 1xx/204/304 响应一旦写 body，会连带触发非法的分帧或额外字节输出。
            throw IllegalStateException("Responses with status 1xx, 204, or 304 must not write a response body.")
        }
        if (!_hasStarted) {
            prepareResponseForStart()
            applyHeadersToResponseBuilder()
            _responseWriter = HttpResponseWriter(_serverContext)
            _hasStarted = true
        }
        _responseWriter?.write(bytes)
    }

    /**
     * @brief 注册响应开始前执行的回调。
     * @param callback 在响应头发送前执行的回调。
     */
    public func onStarting(callback: () -> Unit): Unit {
        ensureMutable("OnStarting")
        if (_onStartingCallbacks.isNone()) {
            _onStartingCallbacks = ArrayList<() -> Unit>()
        }
        _onStartingCallbacks?.add(callback)
    }

    /**
     * @brief 注册响应完成后执行的回调。
     * @param callback 在响应完全发送后执行的回调。
     */
    public func onCompleted(callback: () -> Unit): Unit {
        if (_onCompletedCallbacks.isNone()) {
            _onCompletedCallbacks = ArrayList<() -> Unit>()
        }
        _onCompletedCallbacks.getOrThrow().add(callback)
    }

    /**
     * @brief 由宿主层在 pipeline 结束后调用。
     * @details hasStarted == true 表示流式写出已完成，框架负责发送 last-chunk，此处无需操作。
     * @details hasStarted == false 表示触发 OnStarting 回调后，再将 status/headers 推入 responseBuilder，由框架统一发送。
     */
    internal func flushResponse(): Unit {
        if (_hasStarted) {
            return
        }
        prepareResponseForStart()
        applyHeadersToResponseBuilder()
    }

    /**
     * @brief 由 DefaultHttpContext 在构造完成后设置反向引用，避免循环依赖。
     */
    internal func setOwningContext(ctx: HttpContext): Unit {
        _owningContext = ctx
    }

    /**
     * @brief 由宿主层请求处理流程结束时调用，触发所有 OnCompleted 回调。
     * @details 当前时机位于 handler 返回之后、底层 stdx 真正写响应之前。
     * @details 回调按注册逆序执行。
     */
    internal func completeResponse(): Unit {
        invokeCallbacksReversed(_onCompletedCallbacks)
    }

    /**
     * @brief 将当前 status 和 headers 推入底层 responseBuilder。
     */
    private func applyHeadersToResponseBuilder(): Unit {
        _serverContext.responseBuilder.status(_statusCode)
        if (let Some(h) <- _responseHeaders) {
            for ((name, values) in h) {
                for (value in values) {
                    _serverContext.responseBuilder.header(name, value)
                }
            }
        }
    }

    /**
     * @brief 应用宿主层默认的响应分帧策略。
     * @details 仅在 pipeline 结束且尚未开始写出时执行，避免为默认策略额外注册回调。
     */
    private func applyDefaultResponseFraming(): Unit {
        let responseMustNotHaveBody = responseStatusMustNotHaveBody(_statusCode)
        if (responseMustNotHaveBody) {
            if (let Some(responseHeaders) <- _responseHeaders) {
                responseHeaders.remove(HeaderNames.TransferEncoding)
            }
            return
        }
        let responseHeaders = getOrCreateResponseHeaders()
        if (!responseHeaders.contains(HeaderNames.ContentLength) &&
            !responseHeaders.contains(HeaderNames.TransferEncoding)) {
            responseHeaders.transferEncoding = ["chunked"]
        }
    }

    internal func resetHeadersForErrorResponse(): Unit {
        let responseHeaders = getOrCreateResponseHeaders()
        responseHeaders.remove(HeaderNames.ContentLength)
        responseHeaders.remove(HeaderNames.Trailer)
    }

    /**
     * @brief 逆序执行 OnStarting 回调。
     * @details 最后注册的回调最先调用，对齐 ASP.NET Core 中间件语义。
     * @details 即便回调抛出异常，也只会尝试执行一次，避免异常恢复路径重复触发副作用。
     */
    private func invokeOnStartingOnce(): Unit {
        if (_hasInvokedOnStarting) {
            return
        }
        _hasInvokedOnStarting = true
        invokeCallbacksReversed(_onStartingCallbacks)
    }

    /**
     * @brief 在响应首次写出或 flush 前统一执行准备逻辑。
     * @details 先执行用户注册的 OnStarting，再应用宿主默认分帧策略。
     */
    private func prepareResponseForStart(): Unit {
        invokeOnStartingOnce()
        applyDefaultResponseFraming()
    }

    /**
     * @brief 逆序遍历并执行回调列表。
     */
    private func invokeCallbacksReversed(callbacks: ?ArrayList<() -> Unit>): Unit {
        if (let Some(cbs) <- callbacks) {
            var i = cbs.size - 1
            while (i >= 0) {
                cbs[i]()
                i--
            }
        }
    }

    private func getOrCreateResponseHeaders(): HeaderDictionary {
        if (_responseHeaders.isNone()) {
            let responseHeaders = HeaderDictionary()
            responseHeaders.setMutationGuard({
                => ensureMutable("The response headers")
            })
            _responseHeaders = responseHeaders
        }
        return _responseHeaders.getOrThrow()
    }

    internal func ensureMutable(target: String): Unit {
        if (_hasStarted) {
            throw IllegalStateException("${target} cannot be modified because the response has already started.")
        }
    }
}

class HttpResponseBodyStream <: IOStream {
    private let _response: DefaultHttpResponse

    init(response: DefaultHttpResponse) {
        _response = response
    }

    /**
     * @brief 将字节数组写入关联的响应对象。
     * @param buf 要写入响应体的字节数据。
     */
    public func write(buf: Array<Byte>): Unit {
        _response.write(buf)
    }

    /**
     * @brief 从响应体流读取数据。
     * @param buf 用于接收读取结果的缓冲区。
     * @throws UnsupportedException 响应体流默认不可读时抛出。
     */
    public func read(_: Array<Byte>): Int64 {
        throw UnsupportedException("Specified method is not supported.")
    }
}

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_hosting

import std.io.*
import stdx.encoding.url.URL
import stdx.net.http.{Protocol}
import stdx.net.http.HttpRequest as HttpRequestBase

/**
 * @brief 提供 HttpRequest 抽象的默认实现。
 */
class DefaultHttpRequest <: HttpRequest {
    private let _request: HttpRequestBase
    private var _form: ?IFormCollection = None
    private var _query: ?IQueryCollection = None
    private var _bufferedBody: ?InputStream = None
    private var _requestHeaders: ?HeaderDictionary = None
    private var _cookies: ?IRequestCookieCollection = None
    private var _routeValues: ?RouteValueDictionary = None
    private var _path: ?PathString = None

    init(request: HttpRequestBase) {
        _request = request
    }

    /**
     * @brief 返回当前请求体流。
     * @return 当前请求体流。
     */
    public prop body: InputStream {
        get() {
            if (let Some(_bufferedBody) <- _bufferedBody) {
                return _bufferedBody
            }
            return _request.body
        }
    }

    /**
     * @brief 返回请求体长度。
     * @return 当前请求体长度；如果未提供则返回空。
     */
    public prop contentLength: ?Int64 {
        get() {
            return headers.contentLength
        }
    }

    /**
     * @brief 返回请求的内容类型。
     * @return 当前请求的内容类型；如果未提供则返回空。
     */
    public prop contentType: ?String {
        get() {
            return headers.contentType.first
        }
    }

    /**
     * @brief 检查当前请求是否使用 HTTPS。
     * @return 如果当前请求使用 HTTPS 则返回 true，否则返回 false。
     */
    public prop isHttps: Bool {
        get() {
            return "https".equalsIgnoreAsciiCase(_request.url.scheme)
        }
    }

    /**
     * @brief 返回当前请求的表单集合。
     * @return 当前请求的表单集合。
     */
    public prop form: IFormCollection {
        get() {
            if (let Some(form) <- _form) {
                return form
            }
            if (let Some(contentType) <- contentType && contentType.startsWith("multipart/form-data")) {
                _form = readForm()
            } else {
                _form = FormCollection(_request.form)
            }
            return _form.getOrThrow()
        }
    }

    /**
     * @brief 获取或设置当前请求路径。
     * @return 当前请求路径。
     */
    public mut prop path: PathString {
        get() {
            _path ?? PathString(_request.url.path)
        }
        set(value) {
            _path = value
        }
    }

    /**
     * @brief 返回当前请求主机信息。
     * @return 当前请求主机信息。
     */
    public prop host: HostString {
        get() {
            return HostString(_request.url.host)
        }
    }

    /**
     * @brief 返回当前请求的 Cookie 集合。
     * @return 当前请求的 Cookie 集合。
     */
    public prop cookies: IRequestCookieCollection {
        get() {
            if (_cookies.isNone()) {
                let cookieValue = headers.cookie.first
                _cookies = RequestCookieCollection(cookieValue)
            }
            return _cookies.getOrThrow()
        }
    }

    /**
     * @brief 返回当前请求的查询字符串。
     * @return 当前请求的查询字符串。
     */
    public prop queryString: QueryString {
        get() {
            if (let Some(rawQuery) <- _request.url.rawQuery) {
                return QueryString("?${rawQuery}")
            }
            return QueryString.empty
        }
    }

    /**
     * @brief 返回当前请求的查询参数集合。
     * @return 当前请求的查询参数集合。
     */
    public prop query: IQueryCollection {
        get() {
            if (_query.isNone()) {
                _query = QueryCollection(_request.url.queryForm)
            }
            return _query.getOrThrow()
        }
    }

    /**
     * @brief 返回当前请求使用的协议方案。
     * @return 当前请求使用的协议方案。
     */
    public prop scheme: String {
        get() {
            return _request.url.scheme
        }
    }

    /**
     * @brief 返回当前请求头集合。
     * @return 当前请求头集合。
     */
    public prop headers: IHeaderDictionary {
        get() {
            if (_requestHeaders.isNone()) {
                _requestHeaders = HeaderDictionary(_request.headers)
            }
            return _requestHeaders.getOrThrow()
        }
    }

    /**
     * @brief 返回当前请求方法。
     * @return 当前请求方法。
     */
    public prop method: String {
        get() {
            return _request.method
        }
    }

    /**
     * @brief 返回请求读取超时设置。
     * @return 当前读取超时设置；如果未设置则返回空。
     */
    public prop readTimeout: ?Duration {
        get() {
            return _request.readTimeout
        }
    }

    /**
     * @brief 返回远端地址。
     * @return 当前请求的远端地址。
     */
    public prop remoteAddr: String {
        get() {
            return _request.remoteAddr
        }
    }

    /**
     * @brief 返回协议版本字符串。
     * @return 当前请求的协议版本字符串。
     */
    public prop protocol: String {
        get() {
            return _request.version.toString()
        }
    }

    /**
     * @brief 返回路由值集合。
     * @return 当前路由值集合。
     */
    public prop routeValues: RouteValueDictionary {
        get() {
            if (_routeValues.isNone()) {
                _routeValues = RouteValueDictionary()
            }
            return _routeValues.getOrThrow()
        }
    }

    /**
     * @brief 返回请求写入超时设置。
     * @return 当前写入超时设置；如果未设置则返回空。
     */
    public prop writeTimeout: ?Duration {
        get() {
            return _request.writeTimeout
        }
    }

    /**
     * @brief 返回当前请求的完整显示地址。
     * @return 当前请求的完整显示地址。
     */
    public func getDisplayUrl(): String {
        return _request.url.toString()
    }

    /**
     * @brief 读取并返回当前请求的表单集合。
     * @return 读取后的表单集合。
     */
    public func readForm(): IFormCollection {
        return FromReader.readForm(this)
    }

    /**
     * @brief 为当前请求体启用缓冲读取。
     */
    public func enableBuffering(): Unit {
        if (_bufferedBody.isSome()) {
            return
        }
        let buffer = ByteBuffer()
        copy(_request.body, to: buffer)
        _bufferedBody = buffer
    }
}

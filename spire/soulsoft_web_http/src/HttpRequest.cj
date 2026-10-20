// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_http

import std.io.*

/**
 * @brief 表示 HTTP 请求。
 */
public abstract class HttpRequest {
    /**
     * @brief 返回请求表单集合。
     * @return 当前请求的表单集合。
     */
    public prop form: IFormCollection
    /**
     * @brief 返回请求正文流。
     * @return 当前请求的正文输入流。
     */
    public prop body: InputStream
    /**
     * @brief 返回请求主机信息。
     * @return 当前请求的主机信息。
     */
    public prop host: HostString
    /**
     * @brief 检查当前请求是否使用 HTTPS。
     * @return 如果当前请求使用 HTTPS 则返回 true，否则返回 false。
     */
    public prop isHttps: Bool
    /**
     * @brief 获取或修改请求路径。
     * @return 当前请求路径。
     */
    public mut prop path: PathString
    /**
     * @brief 返回请求协议方案。
     * @return 当前请求的协议方案。
     */
    public prop scheme: String
    /**
     * @brief 返回查询参数集合。
     * @return 当前请求的查询参数集合。
     */
    public prop query: IQueryCollection
    /**
     * @brief 返回查询字符串。
     * @return 当前请求的查询字符串。
     */
    public prop queryString: QueryString
    /**
     * @brief 返回请求头集合。
     * @return 当前请求的请求头集合。
     */
    public prop headers: IHeaderDictionary
    /**
     * @brief 返回 HTTP 请求方法。
     * @return 当前请求的方法名称。
     */
    public prop method: String
    /**
     * @brief 返回读取超时时间。
     * @return 当前请求的读取超时时间；未设置时返回空。
     */
    public prop readTimeout: ?Duration
    /**
     * @brief 返回远端地址。
     * @return 当前请求的远端地址。
     */
    public prop remoteAddr: String
    /**
     * @brief 返回 HTTP 协议版本字符串。
     * @return 当前请求的协议版本字符串。
     */
    public prop protocol: String
    /**
     * @brief 返回写入超时时间。
     * @return 当前请求的写入超时时间；未设置时返回空。
     */
    public prop writeTimeout: ?Duration
    /**
     * @brief 返回请求 Cookie 集合。
     * @return 当前请求的 Cookie 集合。
     */
    public prop cookies: IRequestCookieCollection
    /**
     * @brief 返回路由值集合。
     * @return 当前请求的路由值集合。
     */
    public prop routeValues: RouteValueDictionary
    /**
     * @brief 返回请求正文长度。
     * @return 当前请求的正文长度；未设置时返回空。
     */
    public prop contentLength: ?Int64
    /**
     * @brief 返回请求正文类型。
     * @return 当前请求的内容类型；未设置时返回空。
     */
    public prop contentType: ?String
    /**
     * @brief 读取并返回请求表单数据。
     * @return 当前请求的表单集合。
     */
    public func readForm(): IFormCollection
    /**
     * @brief 返回可显示的完整请求地址。
     * @return 当前请求的完整显示地址。
     */
    public func getDisplayUrl(): String
    /**
     * @brief 启用请求正文缓冲。
     */
    public func enableBuffering(): Unit
}

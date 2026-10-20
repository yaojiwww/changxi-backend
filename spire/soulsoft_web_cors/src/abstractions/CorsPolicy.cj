// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_cors.abstractions

import std.collection.*

/**
 * @brief 表示一组 CORS 请求处理规则。
 */
public class CorsPolicy {
    private let _headers = ArrayList<String>()
    private let _methods = ArrayList<String>()
    private let _origins = ArrayList<String>()
    private var _supportsCredentials = false
    protected var isDefaultIsOriginAllowed = true
    private var _preflightMaxAge: ?Duration = None
    private let _exposedHeaders = ArrayList<String>()
    private var _isOriginAllowed: ?(String) -> Bool = None

    /**
     * @brief 创建一个新的 CORS 策略实例。
     */
    public init() {
        _isOriginAllowed = {
            origin => return _origins |> any {f => f == origin}
        }
    }

    /**
     * @brief 检查当前策略是否允许任意请求头。
     * @return 如果当前策略允许任意请求头则返回 true，否则返回 false。
     */
    public prop allowAnyHeader: Bool {
        get() {
            if (_headers.size != 1 || _headers[0] != CorsConstants.AnyHeader) {
                return false
            }
            return true
        }
    }

    /**
     * @brief 检查当前策略是否允许任意请求方法。
     * @return 如果当前策略允许任意请求方法则返回 true，否则返回 false。
     */
    public prop allowAnyMethod: Bool {
        get() {
            if (_methods.size != 1 || _methods[0] != CorsConstants.AnyMethod) {
                return false
            }
            return true
        }
    }

    /**
     * @brief 检查当前策略是否允许任意请求源。
     * @return 如果当前策略允许任意请求源则返回 true，否则返回 false。
     */
    public prop allowAnyOrigin: Bool {
        get() {
            if (_origins.size != 1 || _origins[0] != CorsConstants.AnyOrigin) {
                return false
            }
            return true
        }
    }

    /**
     * @brief 获取或设置请求源是否被允许的判定函数。
     * @return 返回当前使用的源地址判定函数。
     */
    public mut prop isOriginAllowed: (String) -> Bool {
        get() {
            _isOriginAllowed.getOrThrow()
        }
        set(value) {
            _isOriginAllowed = value
            isDefaultIsOriginAllowed = false
        }
    }

    /**
     * @brief 返回预检成功后可暴露给客户端的响应头集合。
     * @return 当前策略配置的暴露响应头集合。
     */
    public prop exposedHeaders: List<String> {
        get() {
            _exposedHeaders
        }
    }

    /**
     * @brief 获取或设置预检响应可缓存的最大时长。
     * @return 当前策略配置的预检缓存时长。
     * @throws IllegalArgumentException 当设置为负持续时间时抛出。
     */
    public mut prop preflightMaxAge: ?Duration {
        get() {
            _preflightMaxAge
        }
        set(value) {
            if (value.flatMap {f => f < Duration.Zero} == true) {
                throw IllegalArgumentException()
            }
            _preflightMaxAge = value
        }
    }

    /**
     * @brief 获取或设置当前策略是否支持携带凭据。
     * @return 如果当前策略支持携带凭据则返回 true，否则返回 false。
     */
    public mut prop supportsCredentials: Bool {
        get() {
            _supportsCredentials
        }
        set(value) {
            _supportsCredentials = value
        }
    }

    /**
     * @brief 返回当前策略允许的请求头集合。
     * @return 当前策略配置的请求头集合。
     */
    public prop headers: List<String> {
        get() {
            _headers
        }
    }

    /**
     * @brief 返回当前策略允许的请求方法集合。
     * @return 当前策略配置的请求方法集合。
     */
    public prop methods: List<String> {
        get() {
            _methods
        }
    }

    /**
     * @brief 返回当前策略允许的请求源集合。
     * @return 当前策略配置的请求源集合。
     */
    public prop origins: List<String> {
        get() {
            _origins
        }
    }
}

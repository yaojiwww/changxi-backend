// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_net_http

import stdx.net.http.HttpHeaders

/**
 * @brief 表示 HTTP 内容头集合。
 */
public class HttpContentHeaders <: HttpHeadersBase {
    init() {
        super(HttpHeaders())
    }

    /**
     * @brief 添加一个内容头。
     * @param name 头名称。
     * @param value 头值。
     * @return 无返回值。
     * @throws IllegalArgumentException 当头类型不允许出现在内容头集合中时抛出。
     */
    public override func add(name: String, value: String): Unit {
        checkAllowed(name)
        super.add(name, value)
    }

    /**
     * @brief 设置一个内容头。
     * @param name 头名称。
     * @param value 头值。
     * @return 无返回值。
     * @throws IllegalArgumentException 当头类型不允许出现在内容头集合中时抛出。
     */
    public override func set(name: String, value: String): Unit {
        checkAllowed(name)
        super.set(name, value)
    }

    /**
     * @brief 尝试绕过验证添加内容头。
     * @param name 头名称。
     * @param value 头值。
     * @return 添加成功时返回 `true`，头类型不允许时返回 `false`。
     */
    public override func tryAddWithoutValidation(name: String, value: String): Bool {
        match (KnownHeaders.getHeaderType(name)) {
            case HttpHeaderType.Request | HttpHeaderType.Response | HttpHeaderType.General => return false
            case _ => ()
        }
        add(name, value)
        return true
    }

    private static func checkAllowed(name: String): Unit {
        match (KnownHeaders.getHeaderType(name)) {
            case HttpHeaderType.Request | HttpHeaderType.Response | HttpHeaderType.General => throw IllegalArgumentException(
                StringResx.net_http_headers_misused(name))
            case _ => ()
        }
    }
}

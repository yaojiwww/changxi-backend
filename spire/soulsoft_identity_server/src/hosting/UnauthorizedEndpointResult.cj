/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.hosting

import soulsoft_web_http.*

/**
 * @brief 表示返回未授权响应的端点结果。
 */
public class UnauthorizedEndpointResult <: IEndpointResult {
    /**
     * @brief 创建未授权端点结果。
     * @param data 需要写出的响应内容。
     * @param description 未授权描述信息。
     */
    public UnauthorizedEndpointResult(let data: String, let description: ?String) {
    }

    /**
     * @brief 将未授权响应写入当前上下文。
     * @param context 当前 HTTP 上下文。
     */
    public func execute(context: HttpContext): Unit {
        if (let Some(description) <- description) {
            let wwwAuthenticateJson = "Bearer error=\"invalid_token\", error_description=\"${description}\", charset=\"UTF-8\""
            context.response.headers.add("WWW-Authenticate", wwwAuthenticateJson)
        }
        context.response.write(data)
    }
}

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.hosting

import soulsoft_web_http.*

/**
 * @brief 表示返回文本内容的端点结果。
 */
public class ContentEndpointResult <: IEndpointResult {
    /**
     * @brief 创建文本内容端点结果。
     * @param data 需要写出的文本内容。
     * @param contentType 响应内容类型。
     */
    public ContentEndpointResult(let data: String, let contentType: String) {
    }

    /**
     * @brief 将文本内容写入当前响应。
     * @param context 当前 HTTP 上下文。
     */
    public func execute(context: HttpContext): Unit {
        context.response.contentType = contentType
        context.response.headers.pragma = ["no-cache"]
        context.response.headers.cacheControl = ["no-store"]
        context.response.write(data)
    }
}

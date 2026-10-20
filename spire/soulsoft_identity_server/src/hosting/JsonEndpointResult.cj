/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.hosting

import soulsoft_web_http.*
import stdx.encoding.json.*

/**
 * @brief 表示返回 JSON 内容的端点结果。
 */
public class JsonEndpointResult <: IEndpointResult {
    /**
     * @brief 创建 JSON 端点结果。
     * @param data 需要写出的 JSON 数据。
     */
    public JsonEndpointResult(let data: JsonValue) {
    }

    /**
     * @brief 将 JSON 内容写入当前响应。
     * @param context 当前 HTTP 上下文。
     */
    public func execute(context: HttpContext): Unit {
        context.response.headers.pragma = ["no-cache"]
        context.response.headers.cacheControl = ["no-store"]
        context.response.writeAsJson(data)
    }
}

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.hosting

import soulsoft_web_http.*

/**
 * @brief 表示仅设置状态码的端点结果。
 */
public class StatusEndpointResult <: IEndpointResult {
    /**
     * @brief 创建状态码端点结果。
     * @param status 响应状态码。
     */
    public StatusEndpointResult(let status: UInt16) {
    }

    /**
     * @brief 将状态码写入当前响应。
     * @param context 当前 HTTP 上下文。
     */
    public func execute(context: HttpContext): Unit {
        context.response.statusCode = this.status
    }
}

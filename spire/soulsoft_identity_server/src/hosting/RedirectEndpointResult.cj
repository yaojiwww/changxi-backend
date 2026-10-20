/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.hosting

import soulsoft_web_http.*

/**
 * @brief 表示执行重定向的端点结果。
 */
public class RedirectEndpointResult <: IEndpointResult {
    /**
     * @brief 创建重定向端点结果。
     * @param location 重定向目标地址。
     */
    public RedirectEndpointResult(let location: String) {
    }

    /**
     * @brief 将当前响应重定向到目标地址。
     * @param context 当前 HTTP 上下文。
     */
    public func execute(context: HttpContext): Unit {
        context.response.redirect(location)
    }
}

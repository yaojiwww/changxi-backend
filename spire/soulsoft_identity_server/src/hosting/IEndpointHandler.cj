/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.hosting

import soulsoft_web_http.*

/**
 * @brief 定义端点处理器接口。
 */
public interface IEndpointHandler {
    /**
     * @brief 处理当前请求并返回端点结果。
     * @param context 当前 HTTP 上下文。
     * @return 返回端点处理结果。
     */
    func handle(context: HttpContext): IEndpointResult
}

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.hosting

import soulsoft_web_http.*

/**
 * @brief 定义端点结果接口。
 */
public interface IEndpointResult {
    /**
     * @brief 将结果写入当前 HTTP 上下文。
     * @param context 当前 HTTP 上下文。
     */
    func execute(context: HttpContext): Unit
}

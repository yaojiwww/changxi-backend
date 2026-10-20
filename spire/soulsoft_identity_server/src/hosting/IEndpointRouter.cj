/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.hosting

import soulsoft_web_http.*

/**
 * @brief 定义端点路由器接口。
 */
public interface IEndpointRouter {
    /**
     * @brief 根据当前请求匹配端点处理器。
     * @param context 当前 HTTP 上下文。
     * @return 返回匹配到的端点处理器；未匹配时返回空。
     */
    func routing(context: HttpContext): ?IEndpointHandler
}

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.services

import soulsoft_web_http.*

/**
 * @brief 定义访问令牌解析器接口。
 */
public interface ITokenParser {
    /**
     * @brief 尝试从当前请求中解析令牌字符串。
     * @param context 当前 HTTP 上下文。
     * @return 返回解析到的令牌字符串；不存在时返回空。
     */
    func tryParse(context: HttpContext): ?String
}

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.endpoints

import soulsoft_web_http.*

extend HttpRequest {
    /**
     * @brief 检查当前请求是否使用表单 URL 编码内容类型。
     * @return 如果当前请求使用表单 URL 编码内容类型则返回 true，否则返回 false。
     */
    public func hasFormContentType(): Bool {
        if (let Some(contextType) <- this.contentType) {
            return contextType.equalsIgnoreAsciiCase("application/x-www-form-urlencoded")
        }
        return false
    }
}

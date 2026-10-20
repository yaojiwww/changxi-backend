/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_http

import stdx.encoding.url.*

/**
 * @brief 提供 HTTP 相关的常用编码工具。
 */
public class HttpUtility {
    /**
     * @brief 对字符串执行 URL 编码。
     * @param value 要编码的字符串。
     * @return 编码后的字符串。
     */
    public static func urlEncode(value: String): String {
        return URL.encodeComponent(value)
    }

    /**
     * @brief 对字符串执行 URL 解码。
     * @param encodedValue 要解码的字符串。
     * @return 解码后的字符串。
     */
    public static func urlDecode(encodedValue: String): String {
        return URL.decodeComponent(encodedValue)
    }
}

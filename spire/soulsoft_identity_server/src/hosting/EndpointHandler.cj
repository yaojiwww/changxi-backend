/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.hosting

import stdx.encoding.json.*
import soulsoft_identity_server.models.*

/**
 * @brief 表示端点处理器的抽象基类。
 */
public abstract class EndpointHandler <: IEndpointHandler {
    /**
     * @brief 创建状态码响应结果。
     * @param status HTTP 状态码。
     * @return 返回状态码响应结果。
     */
    public func status(status: UInt16): IEndpointResult {
        return StatusEndpointResult(status)
    }

    /**
     * @brief 使用 JSON 值创建响应结果。
     * @param value JSON 响应内容。
     * @return 返回 JSON 响应结果。
     */
    public func json(value: JsonValue): IEndpointResult {
        return JsonEndpointResult(value)
    }

    /**
     * @brief 使用 JSON 字符串创建响应结果。
     * @param json JSON 字符串内容。
     * @return 返回 JSON 文本响应结果。
     */
    public func json(json: String): IEndpointResult {
        return ContentEndpointResult(json, "application/json; charset=utf-8")
    }

    /**
     * @brief 创建重定向响应结果。
     * @param location 重定向目标地址。
     * @return 返回重定向响应结果。
     */
    public func redirect(location: String): IEndpointResult {
        return RedirectEndpointResult(location)
    }

    /**
     * @brief 创建错误请求响应结果。
     * @param error 错误代码。
     * @param errorDescription 错误描述。
     * @return 返回错误请求响应结果。
     */
    public func badRequest(error: String, errorDescription: ?String): IEndpointResult {
        return json(ValidationErrorResult(error, errorDescription).toJson())
    }
}

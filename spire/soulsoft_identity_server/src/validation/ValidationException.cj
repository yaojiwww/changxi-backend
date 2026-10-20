/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.validation

/**
 * @brief 表示身份服务器验证失败异常。
 */
public class ValidationException <: Exception {
    /**
     * @brief 保存验证错误代码。
     */
    public let error: String
    /**
     * @brief 保存可选的错误描述。
     */
    public let description: ?String

    /**
     * @brief 创建默认的验证异常。
     */
    public init() {
        this(ValidationErrors.InvalidRequest, None)
    }

    /**
     * @brief 使用错误代码创建验证异常。
     * @param error 验证错误代码。
     */
    public init(error: String) {
        this(error, None)
    }

    /**
     * @brief 使用错误代码和描述创建验证异常。
     * @param error 验证错误代码。
     * @param description 错误描述。
     */
    public init(error: String, description: ?String) {
        super("[${error}]:${description}")
        this.error = error
        this.description = description
    }
}

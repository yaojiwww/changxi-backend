/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.validation

import soulsoft_identity_claims.*
import soulsoft_identity_server.models.*

/**
 * @brief 定义令牌验证器接口。
 */
public interface ITokenValidator {
    /**
     * @brief 验证访问令牌。
     * @param token 访问令牌字符串。
     * @return 返回访问令牌验证结果。
     */
    func validateAccessToken(token: String): AccessTokenValidationResult
    /**
     * @brief 验证身份令牌。
     * @param token 身份令牌字符串。
     * @return 返回身份令牌验证结果。
     */
    func validateIdentityToken(token: String): IdentityTokenValidationResult
    /**
     * @brief 验证刷新令牌。
     * @param token 刷新令牌字符串。
     * @return 返回刷新令牌验证结果。
     */
    func validateRefreshToken(token: String): RefreshTokenValidationResult
}

/**
 * @brief 表示访问令牌验证结果。
 */
public class AccessTokenValidationResult {
    /**
     * @brief 创建访问令牌验证结果。
     * @param client 验证通过的客户端。
     * @param claims 令牌中的声明集合。
     */
    public AccessTokenValidationResult(public let client: Client, public let claims: Collection<Claim>) {
    }
}

/**
 * @brief 表示身份令牌验证结果。
 */
public class IdentityTokenValidationResult {
    /**
     * @brief 创建身份令牌验证结果。
     * @param client 验证通过的客户端。
     * @param claims 令牌中的声明集合。
     */
    public IdentityTokenValidationResult(public let client: Client, public let claims: Collection<Claim>) {
    }
}

/**
 * @brief 表示刷新令牌验证结果。
 */
public class RefreshTokenValidationResult {
    /**
     * @brief 创建刷新令牌验证结果。
     * @param client 验证通过的客户端。
     * @param refreshToken 验证通过的刷新令牌。
     */
    public RefreshTokenValidationResult(public let client: Client, public let refreshToken: RefreshToken) {
    }
}

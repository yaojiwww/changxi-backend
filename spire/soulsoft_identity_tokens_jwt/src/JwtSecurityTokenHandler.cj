// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/**
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_tokens_jwt

import std.time.*
import std.reflect.*
import std.collection.*
import soulsoft_identity_claims.*
import soulsoft_identity_tokens.*

/**
 * @brief 提供 JWT 的创建、写出、读取与验证能力。
 */
public class JwtSecurityTokenHandler <: SecurityTokenHandler {
    private static const MaximumTokenSizeInBytes = 1024 * 250

    /**
     * @brief 检查当前处理器是否可以读取指定 JWT 字符串。
     * @param token 要检查的 JWT 字符串。
     * @return 格式和长度满足基本要求时返回 `true`。
     */
    public func canReadToken(token: String): Bool {
        if (token.isEmpty()) {
            return false
        }
        if (token.size > MaximumTokenSizeInBytes) {
            return false
        }
        let tokenPartCount = JwtTokenUtilities.countJwtTokenPart(token)
        return tokenPartCount == 3
    }

    /**
     * @brief 根据令牌描述创建 JWT 安全令牌。
     * @param tokenDescriptor 用于生成 JWT 的描述信息。
     * @return 创建出的 JWT 安全令牌。
     */
    public func createToken(tokenDescriptor: SecurityTokenDescriptor): SecurityToken {
        let header = JwtHeader(tokenDescriptor.signingCredentials)
        let payload = JwtPayload()

        if (tokenDescriptor.claims.size > 0) {
            payload.addClaims(tokenDescriptor.claims)
        }

        if (tokenDescriptor.audiences.size > 0) {
            for (pattern in tokenDescriptor.audiences) {
                payload.add(ClaimTypes.Aud, pattern)
            }
        }
        if (let Some(issuer) <- tokenDescriptor.issuer) {
            payload.add(ClaimTypes.Iss, issuer)
        }

        if (let Some(audience) <- tokenDescriptor.audience) {
            payload.add(ClaimTypes.Aud, audience)
        }

        if (let Some(notBefore) <- tokenDescriptor.notBefore) {
            payload.add(ClaimTypes.Nbf, notBefore.toUnixTimeStamp().toSeconds())
        }

        if (let Some(expires) <- tokenDescriptor.expires) {
            payload.add(ClaimTypes.Exp, expires.toUnixTimeStamp().toSeconds())
        }

        if (let Some(issuedAt) <- tokenDescriptor.issuedAt) {
            payload.add(ClaimTypes.Iat, issuedAt.toUnixTimeStamp().toSeconds())
        }

        return JwtSecurityToken(header, payload)
    }

    /**
     * @brief 将 JWT 安全令牌写出为紧凑字符串。
     * @param securityToken 要写出的安全令牌。
     * @return 紧凑格式的 JWT 字符串。
     * @throws UnsupportedException 当令牌缺少签名凭据时抛出。
     * @throws IllegalArgumentException 当输入对象不是 `JwtSecurityToken` 时抛出。
     */
    public func writeToken(securityToken: SecurityToken): String {
        if (let securityToken: JwtSecurityToken <- securityToken) {
            let encodedHeader = securityToken.header.base64UrlEncode()
            let encodedPayload = securityToken.payload.base64UrlEncode()
            if (let Some(signingCredentials) <- securityToken.header.signingCredentials) {
                // 获取签名提供者
                let signer = getSignatureProvider(signingCredentials)
                let signData = signer.sign("${encodedHeader}.${encodedPayload}".toArray())
                let encodedSignature = Base64UrlEncoder.encode(signData)
                return String.join(encodedHeader, encodedPayload, encodedSignature, delimiter: '.')
            } else {
                throw UnsupportedException(
                    "Cannot sign token: signing credentials are required in SecurityTokenDescriptor.")
            }
        } else {
            throw IllegalArgumentException(
                "Expected JwtSecurityToken but received ${ClassTypeInfo.of(securityToken)}. (Parameter 'securityToken')")
        }
    }

    /**
     * @brief 直接从令牌描述创建已编码的 JWT 字符串。
     * @param descriptor 用于生成 JWT 的描述信息。
     * @return 已签名并编码的 JWT 字符串。
     * @throws UnsupportedException 当令牌缺少签名凭据时抛出。
     * @throws IllegalArgumentException 当生成的令牌不是 `JwtSecurityToken` 时抛出。
     */
    public func createEncodedJwt(descriptor: SecurityTokenDescriptor): String {
        let securityToken = createToken(descriptor)
        return writeToken(securityToken)
    }

    /**
     * @brief 验证 JWT 并返回验证结果。
     * @param token 要验证的 JWT 字符串。
     * @param validationParameters 用于控制验证流程的参数。
     * @return JWT 验证结果。
     */
    public func validateToken(token: String, validationParameters: TokenValidationParameters): TokenValidationResult {
        try {
            // 验证签名
            let securityToken = validateSignature(token, validationParameters)
            // 验证令牌负载
            validateTokenPayload(securityToken, validationParameters)
            // 创建身份
            let identity = ClaimsIdentity(validationParameters.authenticationType)
            identity.addClaims(securityToken.payload.toClaims())
            return TokenValidationResult.Success(identity, securityToken)
        } catch (exception: Exception) {
            return TokenValidationResult.Failed(exception)
        }
    }

    /**
     * @brief 读取 JWT 字符串并解析为安全令牌对象。
     * @param token 要解析的 JWT 字符串。
     * @return 解析得到的 JWT 安全令牌。
     * @throws SecurityTokenValidationException 当 JWT 分段错误或 Base64Url 解码失败时抛出。
     * @throws IllegalArgumentException 当头部或载荷 JSON 无法反序列化时抛出。
     */
    public func readJwtToken(token: String): JwtSecurityToken {
        let tokenParts = token.split('.')
        if (tokenParts.size != 3) {
            throw SecurityTokenValidationException("Malformed token. JWT must have three parts separated by dots.")
        }

        let segments = JwtSegments(tokenParts[0], tokenParts[1], tokenParts[2])

        let headerClaims = if (let Some(json) <- Base64UrlEncoder.decode(segments.header)) {
            JwtSerializer.deserialize(json)
        } else {
            throw SecurityTokenValidationException("Failed to decode JWT header: invalid Base64Url encoding.")
        }

        let payloadClaims = if (let Some(json) <- Base64UrlEncoder.decode(segments.payload)) {
            JwtSerializer.deserialize(json)
        } else {
            throw SecurityTokenValidationException("Failed to decode JWT payload: invalid Base64Url encoding.")
        }

        let header = JwtHeader(headerClaims)
        let payload = JwtPayload(payloadClaims)
        return JwtSecurityToken(header, payload, segments)
    }

    private func readJwtToken(token: String, validationParameters: TokenValidationParameters): JwtSecurityToken {
        if (let Some(reader) <- validationParameters.tokenReader) {
            let securityToken = reader(token, validationParameters)
            return (securityToken as JwtSecurityToken).getOrThrow {
                throw SecurityTokenValidationException("Token reader must return a JwtSecurityToken instance.")
            }
        }
        return readJwtToken(token)
    }

    private func validateTokenPayload(securityToken: JwtSecurityToken, validationParameters: TokenValidationParameters) {
        let expires: ?DateTime = if (let Some(duration) <- securityToken.payload.exp) {
            DateTime.fromUnixTimeStamp(Duration.second * duration)
        } else {
            None
        }

        let notBefore: ?DateTime = if (let Some(duration) <- securityToken.payload.nbf) {
            DateTime.fromUnixTimeStamp(Duration.second * duration)
        } else {
            None
        }

        // 验证生命周期
        validateLifetime(expires, notBefore, securityToken, validationParameters)

        // 验证受众
        validateAudience(securityToken.payload.aud, securityToken, validationParameters)

        // 验证发行者
        validateIssuer(securityToken.payload.iss ?? String.empty, securityToken, validationParameters)

        // 验证令牌类型
        validateTokenType(securityToken.header.typ, securityToken, validationParameters)

        // 验证令牌 replay
        if (let Some(segments) <- securityToken.segments) {
            validateTokenReplay(expires, segments.rawData, validationParameters)
        }
    }

    private func validateLifetime(expires: ?DateTime, notBefore: ?DateTime, securityToken: JwtSecurityToken,
        validationParameters: TokenValidationParameters) {
        if (!validationParameters.validateLifetime) {
            return
        }

        // 如果存在自定义验证器
        if (let Some(validator) <- validationParameters.lifetimeValidator) {
            if (!validator(expires, notBefore, securityToken, validationParameters)) {
                throw SecurityTokenValidationException("Custom lifetime validator rejected the token.")
            }
            return
        }

        // 过期时间字段是否是必须的
        if (validationParameters.requireExpirationTime && expires.isNone()) {
            throw SecurityTokenValidationException("Token must contain an expiration time (exp claim).")
        }

        // notBefore 必须大于 expires
        if (let Some(expires) <- expires && let Some(notBefore) <- notBefore && notBefore > expires) {
            throw SecurityTokenValidationException(
                "Token lifetime is invalid: nbf (${notBefore}) must be before exp (${expires}).")
        }

        // expires 必须大于当前时间
        let utcNow = DateTime.nowUTC()
        if (let Some(expires) <- expires && expires < utcNow.addSeconds(validationParameters.clockSkew.toSeconds())) {
            throw SecurityTokenValidationException("Token has expired at ${expires}.")
        }

        // notBefore 必须大于当前时间
        if (let Some(notBefore) <- notBefore && notBefore > utcNow.addSeconds(
            validationParameters.clockSkew.toSeconds() * -1)) {
            throw SecurityTokenValidationException("Token is not yet valid until ${notBefore}.")
        }
    }

    private func validateAudience(audiences: Collection<String>, securityToken: JwtSecurityToken,
        validationParameters: TokenValidationParameters) {

        // 如果不验证受众
        if (!validationParameters.validateAudience) {
            return
        }

        // 如果存在自定义验证器
        if (let Some(validator) <- validationParameters.audienceValidator) {
            if (!validator(audiences, securityToken, validationParameters)) {
                throw SecurityTokenValidationException("Custom audience validator rejected the token.")
            }
            return
        }
        // 当受众不是必须的，并且正好为空，那么跳过验证
        if (!validationParameters.requireAudience && audiences.isEmpty()) {
            return
        }

        // 如果受众为空
        if (audiences.isEmpty()) {
            throw SecurityTokenValidationException("Token must contain an audience (aud claim).")
        }

        // 如果没有配置有效的受众
        if (validationParameters.validAudiences.isEmpty()) {
            throw SecurityTokenValidationException("No valid audiences configured for token validation.")
        }

        // 遍历受众
        var isValid = false
        for (audience in audiences) {
            if (audience.isEmpty()) {
                continue
            }
            if (validationParameters.validAudiences.contains(audience)) {
                isValid = true
                break
            }
        }

        if (!isValid) {
            throw SecurityTokenValidationException("Token audience validation failed: no matching audience found.")
        }
    }

    private func validateIssuer(issuer: String, securityToken: JwtSecurityToken,
        validationParameters: TokenValidationParameters) {

        // 如果不验证发行者
        if (!validationParameters.validateIssuer) {
            return
        }
        // 如果存在自定义验证器
        if (let Some(validator) <- validationParameters.issuerValidator) {
            if (!validator(issuer, securityToken, validationParameters)) {
                throw SecurityTokenValidationException("Custom issuer validator rejected the token.")
            }
            return
        }

        // 如果发行者为空
        if (issuer.isEmpty()) {
            throw SecurityTokenValidationException("Token must contain an issuer (iss claim).")
        }

        // 如果没有配置有效的发行者
        if (validationParameters.validIssuers.isEmpty()) {
            throw SecurityTokenValidationException("No valid issuers configured for token validation.")
        }

        // 如果发行者不在有效发行者列表中
        if (!validationParameters.validIssuers.contains(issuer)) {
            throw SecurityTokenValidationException("Token issuer validation failed.")
        }
    }

    private func validateTokenReplay(expires: ?DateTime, token: String, validationParameters: TokenValidationParameters) {
        // 如果不验证令牌重放
        if (!validationParameters.validateTokenReplay) {
            return
        }

        // 如果存在自定义验证器
        if (let Some(validator) <- validationParameters.tokenReplayValidator) {
            if (!validator(expires, token, validationParameters)) {
                throw SecurityTokenValidationException("Custom token replay validator rejected the token.")
            }
            return
        }

        // 如果存在令牌重放缓存
        if (let Some(tokenReplayCache) <- validationParameters.tokenReplayCache) {
            if (expires.isNone()) {
                throw SecurityTokenValidationException(
                    "Token replay validation requires an expiration time (exp claim).")
            }

            // 如果令牌在缓存中存在，则表示令牌重放
            if (tokenReplayCache.contains(token)) {
                throw SecurityTokenValidationException("Token replay detected: this token has already been used.")
            }

            // 将令牌添加到缓存中
            if (!tokenReplayCache.add(token, expires.getOrThrow())) {
                throw SecurityTokenValidationException("Failed to add token to replay cache.")
            }
        }
    }

    private func validateTokenType(`type`: String, securityToken: JwtSecurityToken,
        validationParameters: TokenValidationParameters) {
        // 跳过验证
        if (validationParameters.typeValidator.isNone() && validationParameters.validTypes.isEmpty()) {
            return
        }

        // 如果存在自定义验证器
        if (let Some(typeValidator) <- validationParameters.typeValidator) {
            if (!typeValidator(`type`, securityToken, validationParameters)) {
                throw SecurityTokenValidationException("Custom token type validator rejected the token.")
            }
        }

        // 如果类型为空
        if (`type`.isEmpty()) {
            throw SecurityTokenValidationException("Token must contain a type (typ claim).")
        }

        // 如果没有配置有效的类型
        if (!validationParameters.validTypes.contains(`type`)) {
            throw SecurityTokenValidationException("Token type validation failed.")
        }
    }

    private func validateSignature(token: String, validationParameters: TokenValidationParameters): JwtSecurityToken {

        // 读取 JWT 令牌
        let securityToken = readJwtToken(token, validationParameters)

        // 如果存在自定义验证器
        if (let Some(validator) <- validationParameters.signatureValidator) {
            let securityToken = validator(token, validationParameters)
            return (securityToken as JwtSecurityToken).getOrThrow {
                throw UnsupportedException("Custom signature validator must return a JwtSecurityToken instance.")
            }
        } else {
            // 验证签名
            return validateSignature(securityToken, validationParameters)
        }
    }

    private func validateSignature(securityToken: JwtSecurityToken, validationParameters: TokenValidationParameters) {
        var signingKeys = if (let Some(resolver) <- validationParameters.issuerSigningKeyResolver) {
            resolver(securityToken, validationParameters)
        } else {
            validationParameters.issuerSigningKeys
        }

        // 验证密钥的合法性
        if (validationParameters.validateIssuerSigningKey && let Some(validator) <- validationParameters
            .issuerSigningKeyValidator) {
            var validKeys = ArrayList<SecurityKey>()
            for (pattern in signingKeys) {
                if (validator(pattern, securityToken, validationParameters)) {
                    validKeys.add(pattern)
                }
            }
            signingKeys = validKeys
        }

        let segments = securityToken.segments.getOrThrow {
            throw SecurityTokenValidationException("Token segments missing for signature validation.")
        }

        // 获取签名提供者
        let input = "${segments.header}.${segments.payload}".toArray()
        let signature = Base64UrlEncoder.decodeBytes(segments.signature).getOrThrow {
            throw SecurityTokenValidationException("Failed to decode signature: invalid Base64Url encoding.")
        }

        // 获取算法
        let algorithm = securityToken.header.alg.getOrThrow {
            throw SecurityTokenValidationException("Token header must contain an algorithm (alg claim).")
        }

        // 遍历签名密钥，找到任意一个能验证通过即可
        var verified = false
        for (pattern in signingKeys) {
            let provider = getSignatureProvider(pattern, algorithm)
            if (provider.verify(input, signature)) {
                verified = true
                break
            }
        }
        if (verified) {
            return securityToken
        } else {
            throw SecurityTokenValidationException("Signature validation failed: unable to verify token signature.")
        }
    }

    private static func getSignatureProvider(signingCredentials: SigningCredentials) {
        return getSignatureProvider(signingCredentials.key, signingCredentials.algorithm)
    }

    private static func getSignatureProvider(signingKey: SecurityKey, algorithm: String) {
        // 获取签名提供者
        if (signingKey is AsymmetricSecurityKey) {
            return AsymmetricSignatureProvider(signingKey, algorithm)
        }
        return SymmetricSignatureProvider(signingKey, algorithm)
    }
}

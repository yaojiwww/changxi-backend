// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_claims

/**
 * @brief 定义常用声明类型名称常量。
 */
public abstract class ClaimTypes {
    /**
     * @brief 表示初始化向量声明类型。
     */
    public static const IV = "iv"
    /**
     * @brief 表示主体标识声明类型。
     */
    public static const Sub = "sub"
    /**
     * @brief 表示过期时间声明类型。
     */
    public static const Exp = "exp"
    /**
     * @brief 表示签发时间声明类型。
     */
    public static const Iat = "iat"
    /**
     * @brief 表示签发者声明类型。
     */
    public static const Iss = "iss"
    /**
     * @brief 表示受众声明类型。
     */
    public static const Aud = "aud"
    /**
     * @brief 表示生效时间声明类型。
     */
    public static const Nbf = "nbf"
    /**
     * @brief 表示令牌标识声明类型。
     */
    public static const Jti = "jti"
    /**
     * @brief 表示令牌类型声明类型。
     */
    public static const Typ = "typ"
    /**
     * @brief 表示算法声明类型。
     */
    public static const Alg = "alg"
    /**
     * @brief 表示密钥标识声明类型。
     */
    public static const Kid = "kid"
    /**
     * @brief 表示加密算法声明类型。
     */
    public static const Enc = "enc"
    /**
     * @brief 表示内容类型声明类型。
     */
    public static const Cty = "cty"
    /**
     * @brief 表示认证上下文类引用声明类型。
     */
    public static const Acr = "acr"
    /**
     * @brief 表示认证方法引用声明类型。
     */
    public static const Amr = "amr"
    /**
     * @brief 表示身份提供方声明类型。
     */
    public static const Idp = "idp"
    /**
     * @brief 表示确认声明类型。
     */
    public static const Cnf = "cnf"
    /**
     * @brief 表示地址声明类型。
     */
    public static const Address = "address"
    /**
     * @brief 表示访问令牌哈希声明类型。
     */
    public static const AtHash = "at_hash"
    /**
     * @brief 表示认证时间声明类型。
     */
    public static const AuthTime = "auth_time"
    /**
     * @brief 表示授权方声明类型。
     */
    public static const Azp = "azp"
    /**
     * @brief 表示出生日期声明类型。
     */
    public static const Birthdate = "birthdate"
    /**
     * @brief 表示授权码哈希声明类型。
     */
    public static const CHash = "c_hash"
    /**
     * @brief 表示邮箱声明类型。
     */
    public static const Email = "email"
    /**
     * @brief 表示邮箱是否已验证声明类型。
     */
    public static const EmailVerified = "email_verified"
    /**
     * @brief 表示性别声明类型。
     */
    public static const Gender = "gender"
    /**
     * @brief 表示姓氏声明类型。
     */
    public static const FamilyName = "family_name"
    /**
     * @brief 表示名字声明类型。
     */
    public static const GivenName = "given_name"
    /**
     * @brief 表示区域设置声明类型。
     */
    public static const Locale = "locale"
    /**
     * @brief 表示中间名声明类型。
     */
    public static const MiddleName = "middle_name"
    /**
     * @brief 表示姓名声明类型。
     */
    public static const Name = "name"
    /**
     * @brief 表示昵称声明类型。
     */
    public static const Nickname = "nickname"
    /**
     * @brief 表示随机数声明类型。
     */
    public static const Nonce = "nonce"
    /**
     * @brief 表示电话号码声明类型。
     */
    public static const PhoneNumber = "phone_number"
    /**
     * @brief 表示电话号码是否已验证声明类型。
     */
    public static const PhoneNumberVerified = "phone_number_verified"
    /**
     * @brief 表示头像声明类型。
     */
    public static const Picture = "picture"
    /**
     * @brief 表示首选用户名声明类型。
     */
    public static const PreferredUsername = "preferred_username"
    /**
     * @brief 表示个人资料声明类型。
     */
    public static const Profile = "profile"
    /**
     * @brief 表示会话标识声明类型。
     */
    public static const Sid = "sid"
    /**
     * @brief 表示更新时间声明类型。
     */
    public static const UpdatedAt = "updated_at"
    /**
     * @brief 表示网站声明类型。
     */
    public static const Website = "website"
    /**
     * @brief 表示时区信息声明类型。
     */
    public static const ZoneInfo = "zoneinfo"
    /**
     * @brief 表示角色声明类型。
     */
    public static const Role = "role"
    /**
     * @brief 表示角色集合声明类型。
     */
    public static const Roles = "roles"
    /**
     * @brief 表示作用域声明类型。
     */
    public static const Scope = "scope"
    /**
     * @brief 表示权限声明类型。
     */
    public static const Permissions = "permissions"
    /**
     * @brief 表示租户标识声明类型。
     */
    public static const TenantId = "tenant_id"
    /**
     * @brief 表示客户端标识声明类型。
     */
    public static const ClientId = "client_id"
    /**
     * @brief 表示用户标识声明类型。
     */
    public static const UserId = "user_id"
    /**
     * @brief 表示员工标识声明类型。
     */
    public static const EmployeeId = "employee_id"
    /**
     * @brief 表示旧版代理主体声明类型。
     */
    public static const Actort = "actort"
    /**
     * @brief 表示旧版名称标识声明类型。
     */
    public static const NameId = "nameid"
    /**
     * @brief 表示旧版主体声明类型。
     */
    public static const Prn = "prn"
    /**
     * @brief 表示旧版唯一名称声明类型。
     */
    public static const UniqueName = "unique_name"
    /**
     * @brief 表示访问令牌哈希声明类型别名。
     */
    public static const AccessTokenHash = "at_hash"
    /**
     * @brief 表示授权码哈希声明类型别名。
     */
    public static const CodeHash = "c_hash"

    private init() {
        
    }
}

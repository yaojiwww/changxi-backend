// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_claims

import std.collection.*
import stdx.serialization.serialization.*

/**
 * @brief 表示一组声明及其认证信息。
 */
public class ClaimsIdentity <: Serializable<ClaimsIdentity> {
    private let _claims: ArrayList<Claim>
    private var _authenticationType: ?String = None

    /**
     * @brief 创建空的声明标识。
     */
    public init() {
        _claims = ArrayList<Claim>()
    }

    /**
     * @brief 使用指定声明集合创建声明标识。
     * @param claims 初始声明集合。
     */
    public init(claims: Collection<Claim>) {
        _claims = ArrayList<Claim>(claims)
    }

    /**
     * @brief 使用认证类型创建空声明标识。
     * @param authenticationType 认证类型。
     */
    public init(authenticationType: ?String) {
        _claims = ArrayList<Claim>()
        _authenticationType = authenticationType
    }

    /**
     * @brief 使用认证类型和声明集合创建声明标识。
     * @param authenticationType 认证类型。
     * @param claims 初始声明集合。
     */
    public init(authenticationType: ?String, claims: Collection<Claim>) {
        _claims = ArrayList<Claim>(claims)
        _authenticationType = authenticationType
    }

    /**
     * @brief 返回当前标识包含的声明集合。
     * @return 返回当前标识包含的声明集合。
     */
    public prop claims: Collection<Claim> {
        get() {
            _claims
        }
    }

    /**
     * @brief 返回当前标识是否已通过认证。
     * @return 如果当前标识已通过认证则返回 true，否则返回 false。
     */
    public prop isAuthenticated: Bool {
        get() {
            authenticationType.isSome()
        }
    }

    /**
     * @brief 返回当前标识的认证类型。
     * @return 返回当前标识的认证类型；如果未设置则返回 None。
     */
    public prop authenticationType: ?String {
        get() {
            _authenticationType
        }
    }

    /**
     * @brief 添加一条声明。
     * @param claim 需要添加的声明。
     */
    public func addClaim(claim: Claim): Unit {
        _claims.add(claim)
    }

    /**
     * @brief 添加一条字符串值类型声明。
     * @param type 声明类型。
     * @param value 声明值。
     */
    public func addClaim(`type`: String, value: String): Unit {
        _claims.add(Claim(`type`, value))
    }

    /**
     * @brief 添加一条指定值类型声明。
     * @param type 声明类型。
     * @param value 声明值。
     * @param valueType 声明值类型。
     */
    public func addClaim(`type`: String, value: String, valueType: String): Unit {
        _claims.add(Claim(`type`, value, valueType))
    }

    /**
     * @brief 批量添加声明。
     * @param claims 需要添加的声明集合。
     */
    public func addClaims(claims: Collection<Claim>): Unit {
        _claims.add(all: claims)
    }

    /**
     * @brief 查找满足条件的全部声明。
     * @param predicate 声明筛选条件。
     * @return 返回匹配的声明数组。
     */
    public func findAll(predicate: (Claim) -> Bool): Array<Claim> {
        _claims |> filter(predicate) |> collectArray
    }

    /**
     * @brief 按声明类型查找全部声明。
     * @param type 声明类型。
     * @return 返回匹配的声明数组。
     */
    public func findAll(`type`: String): Array<Claim> {
        _claims |> filter {f => f.`type` == `type`} |> collectArray
    }

    /**
     * @brief 查找首个满足条件的声明。
     * @param predicate 声明筛选条件。
     * @return 返回首个匹配的声明；不存在时返回空。
     */
    public func findFirst(predicate: (Claim) -> Bool): ?Claim {
        findAll(predicate) |> first
    }

    /**
     * @brief 按声明类型查找首条声明。
     * @param type 声明类型。
     * @return 返回首个匹配的声明；不存在时返回空。
     */
    public func findFirst(`type`: String): ?Claim {
        findAll(`type`) |> first
    }

    /**
     * @brief 查找首个满足条件声明的值。
     * @param predicate 声明筛选条件。
     * @return 返回首个匹配声明的值；不存在时返回空。
     */
    public func findFirstValue(predicate: (Claim) -> Bool): ?String {
        findFirst(predicate).flatMap {f => f.value}
    }

    /**
     * @brief 按声明类型查找首个声明值。
     * @param type 声明类型。
     * @return 返回首个匹配声明的值；不存在时返回空。
     */
    public func findFirstValue(`type`: String): ?String {
        findFirst(`type`).flatMap {f => f.value}
    }

    /**
     * @brief 检查是否存在满足条件的声明。
     * @param predicate 声明筛选条件。
     * @return 如果存在匹配声明则返回 `true`。
     */
    public func hasClaim(predicate: (Claim) -> Bool): Bool {
        _claims |> any(predicate)
    }

    /**
     * @brief 检查是否存在指定类型和值的声明。
     * @param type 声明类型。
     * @param value 声明值。
     * @return 如果存在匹配声明则返回 `true`。
     */
    public func hasClaim(`type`: String, value: String): Bool {
        return hasClaim {f => f.`type` == `type` && f.value == value}
    }

    /**
     * @brief 将当前声明标识序列化为数据模型。
     * @return 返回声明标识对应的数据模型结构。
     */
    public func serialize(): DataModelStruct {
        let dms = DataModelStruct()
        dms.add(field("authenticationType", authenticationType))
        dms.add(Field("claims", claims.toArray().serialize()))
        return dms
    }

    /**
     * @brief 从数据模型反序列化声明标识。
     * @param dm 声明标识对应的数据模型。
     * @return 返回反序列化后的声明标识。
     * @throws DataModelException 当数据模型不是结构类型时抛出。
     */
    public static func deserialize(dm: DataModel): ClaimsIdentity {
        let dms = match (dm) {
            case dms: DataModelStruct => dms
            case _ => throw DataModelException("The data is not DataModelStruct.")
        }
        let authenticationType = Option<String>.deserialize(dms.get("authenticationType"))
        let claims = Array<Claim>.deserialize(dms.get("claims"))
        return ClaimsIdentity(authenticationType, claims)
    }

    /**
     * @brief 克隆当前声明标识。
     * @return 返回克隆后的声明标识。
     */
    public func clone(): ClaimsIdentity {
        let identity = ClaimsIdentity(this.authenticationType)
        for (claim in claims) {
            identity.addClaim(claim.`type`, claim.value, claim.valueType)
        }
        return identity
    }
}

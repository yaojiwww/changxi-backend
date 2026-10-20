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
 * @brief 表示包含多个声明标识的主体。
 */
public class ClaimsPrincipal <: Serializable<ClaimsPrincipal> {
    private let _identities: ArrayList<ClaimsIdentity>
    private static var _selectPrimaryIdentity = selectPrimaryIdentity

    /**
     * @brief 使用声明标识数组创建主体。
     * @param claimsIdenties 主体包含的声明标识数组。
     */
    public init(claimsIdenties: Array<ClaimsIdentity>) {
        _identities = ArrayList<ClaimsIdentity>(claimsIdenties)
    }

    /**
     * @brief 返回主体聚合后的全部声明。
     * @return 返回主体聚合后的全部声明。
     */
    public prop claims: Collection<Claim> {
        get() {
            _identities |> flatMap {f => f.claims} |> collectArray
        }
    }

    /**
     * @brief 添加一个声明标识。
     * @param claimsIdentity 需要添加的声明标识。
     */
    public func addIdentity(claimsIdentity: ClaimsIdentity): Unit {
        _identities.add(claimsIdentity)
    }

    /**
     * @brief 批量添加声明标识。
     * @param claimsIdentities 需要添加的声明标识集合。
     */
    public func addIdentities(claimsIdentities: Collection<ClaimsIdentity>): Unit {
        _identities.add(all: claimsIdentities)
    }

    /**
     * @brief 返回当前主体的主声明标识。
     * @return 返回当前主体的主声明标识；如果不存在则返回 None。
     */
    public prop identity: ?ClaimsIdentity {
        get() {
            _selectPrimaryIdentity(_identities)
        }
    }

    /**
     * @brief 返回主体包含的全部声明标识。
     * @return 返回主体包含的全部声明标识。
     */
    public prop identities: Collection<ClaimsIdentity> {
        get() {
            _identities
        }
    }

    /**
     * @brief 检查主体是否存在满足条件的声明。
     * @param predicate 声明筛选条件。
     * @return 如果存在匹配声明则返回 `true`。
     */
    public func hasClaim(predicate: (Claim) -> Bool): Bool {
        return _identities |> any {f => f.hasClaim(predicate)}
    }

    /**
     * @brief 检查主体是否存在指定类型和值的声明。
     * @param type 声明类型。
     * @param value 声明值。
     * @return 如果存在匹配声明则返回 `true`。
     */
    public func hasClaim(`type`: String, value: String): Bool {
        return hasClaim {f => f.`type` == `type` && f.value == value}
    }

    /**
     * @brief 查找满足条件的全部声明。
     * @param selector 声明筛选条件。
     * @return 返回匹配的声明数组。
     */
    public func findAll(selector: (Claim) -> Bool): Array<Claim> {
        return _identities |> flatMap {f => f.claims} |> filter {f => selector(f)} |> collectArray
    }

    /**
     * @brief 查找首个满足条件的声明。
     * @param selector 声明筛选条件。
     * @return 返回首个匹配的声明；不存在时返回空。
     */
    public func findFirst(selector: (Claim) -> Bool): ?Claim {
        return findAll(selector) |> first
    }

    /**
     * @brief 查找首个满足条件声明的值。
     * @param selector 声明筛选条件。
     * @return 返回首个匹配声明的值；不存在时返回空。
     */
    public func findFirstValue(selector: (Claim) -> Bool): ?String {
        return findFirst(selector).flatMap {f => f.value}
    }

    /**
     * @brief 按声明类型查找全部声明。
     * @param type 声明类型。
     * @return 返回匹配的声明数组。
     */
    public func findAll(`type`: String): Array<Claim> {
        return findAll {f => f.`type` == `type`}
    }

    /**
     * @brief 按声明类型查找首条声明。
     * @param type 声明类型。
     * @return 返回首个匹配的声明；不存在时返回空。
     */
    public func findFirst(`type`: String): ?Claim {
        return findFirst {f => f.`type` == `type`}
    }

    /**
     * @brief 按声明类型查找首个声明值。
     * @param type 声明类型。
     * @return 返回首个匹配声明的值；不存在时返回空。
     */
    public func findFirstValue(`type`: String): ?String {
        return findFirstValue {f => f.`type` == `type`}
    }

    /**
     * @brief 检查主体是否包含指定角色声明。
     * @param role 角色名称。
     * @return 如果主体拥有该角色则返回 `true`。
     */
    public func isInRole(role: String): Bool {
        for (identity in _identities) {
            if (identity.hasClaim(ClaimTypes.Role, role)) {
                return true
            }
        }
        return false
    }

    /**
     * @brief 克隆当前主体。
     * @return 返回克隆后的主体。
     */
    public func clone(): ClaimsPrincipal {
        let clonedIdentities = _identities |> map {identity => identity.clone()} |> collectArray
        return ClaimsPrincipal(clonedIdentities)
    }

    /**
     * @brief 设置主声明标识选择器。
     * @param selector 用于选择主声明标识的委托。
     */
    public static func setPrimaryIdentitySelector(selector: (identities: Collection<ClaimsIdentity>) -> ?ClaimsIdentity): Unit {
        _selectPrimaryIdentity = selector
    }

    private static func selectPrimaryIdentity(identities: Collection<ClaimsIdentity>): ?ClaimsIdentity {
        return identities |> first
    }

    /**
     * @brief 将当前主体序列化为数据模型。
     * @return 返回主体对应的数据模型结构。
     */
    public func serialize(): DataModelStruct {
        let dms = DataModelStruct()
        dms.add(field("identities", identities.toArray()))
        return dms
    }

    /**
     * @brief 从数据模型反序列化主体。
     * @param dm 主体对应的数据模型。
     * @return 返回反序列化后的主体。
     * @throws DataModelException 当数据模型不是结构类型时抛出。
     */
    public static func deserialize(dm: DataModel): ClaimsPrincipal {
        let dms = match (dm) {
            case dms: DataModelStruct => dms
            case _ => throw DataModelException("The data is not DataModelStruct.")
        }
        let identities = Array<ClaimsIdentity>.deserialize(dms.get("identities"))
        return ClaimsPrincipal(identities)
    }
}

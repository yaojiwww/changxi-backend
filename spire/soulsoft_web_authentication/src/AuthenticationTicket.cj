// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_authentication

import soulsoft_identity_claims.*
import stdx.serialization.serialization.*

/**
 * @brief 表示一次身份验证产生的票据。
 */
public class AuthenticationTicket {
    private let _principal: ClaimsPrincipal
    private let _authenticationScheme: String
    private let _properties: AuthenticationProperties

    /**
     * @brief 使用默认属性创建身份验证票据。
     * @param principal 用户主体。
     * @param authenticationScheme 身份验证方案名称。
     */
    public init(principal: ClaimsPrincipal, authenticationScheme: String) {
        this(principal, authenticationScheme, None)
    }

    /**
     * @brief 创建一个身份验证票据。
     * @param principal 用户主体。
     * @param authenticationScheme 身份验证方案名称。
     * @param properties 票据附带属性。
     */
    public init(principal: ClaimsPrincipal, authenticationScheme: String, properties: ?AuthenticationProperties) {
        _principal = principal
        _properties = properties ?? AuthenticationProperties()
        _authenticationScheme = authenticationScheme
    }

    /**
     * @brief 返回票据所属方案名称。
     * @return 身份验证方案名称。
     */
    public prop authenticationScheme: String {
        get() {
            _authenticationScheme
        }
    }

    /**
     * @brief 返回票据关联的用户主体。
     * @return 用户主体。
     */
    public prop principal: ClaimsPrincipal {
        get() {
            _principal
        }
    }

    /**
     * @brief 返回票据附带属性。
     * @return 身份验证属性。
     */
    public prop properties: AuthenticationProperties {
        get() {
            _properties
        }
    }

    /**
     * @brief 将当前票据序列化为数据模型。
     * @return 序列化后的数据模型。
     */
    public func serialize(): DataModelStruct {
        let dms = DataModelStruct()
        dms.add(field("principal", principal))
        dms.add(field("properties", properties))
        dms.add(field("authenticationScheme", authenticationScheme))
        return dms
    }

    /**
     * @brief 从数据模型反序列化身份验证票据。
     * @param dm 输入的数据模型。
     * @return 反序列化后的身份验证票据。
     * @throws DataModelException 当输入数据不是对象结构时抛出。
     */
    public static func deserialize(dm: DataModel): AuthenticationTicket {
        let dms = match (dm) {
            case dms: DataModelStruct => dms
            case _ => throw DataModelException("The data is not DataModelStruct.")
        }
        let principal = ClaimsPrincipal.deserialize(dms.get("principal"))
        let properties = AuthenticationProperties.deserialize(dms.get("properties"))
        let authenticationScheme = String.deserialize(dms.get("authenticationScheme"))
        return AuthenticationTicket(principal, authenticationScheme, properties)
    }
}

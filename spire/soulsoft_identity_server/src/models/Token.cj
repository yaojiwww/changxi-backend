/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.models

import std.time.*
import soulsoft_identity_claims.*

/**
 * @brief 表示待生成或已生成的令牌负载信息。
 */
public class Token {
    /**
     * @brief 保存令牌签发者标识。
     */
    public var issuer = String.empty
    /**
     * @brief 保存令牌有效时长。
     */
    public var lifetime: Int64 = 0
    /**
     * @brief 保存令牌所属的客户端标识。
     */
    public var clientId = String.empty
    /**
     * @brief 保存令牌描述信息。
     */
    public var description: ?String = None
    /**
     * @brief 保存令牌关联的用户主体。
     */
    public var subject = ClaimsPrincipal()
    /**
     * @brief 保存令牌面向的受众集合。
     */
    public var audiences: Collection<String> = []
    /**
     * @brief 保存令牌类型。
     */
    public var tokenType: String = String.empty
    /**
     * @brief 保存令牌创建时间。
     */
    public var creationTime: DateTime = DateTime.now().inUTC()
}

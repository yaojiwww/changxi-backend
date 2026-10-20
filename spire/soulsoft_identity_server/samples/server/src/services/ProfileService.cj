/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package server.services

import std.collection.*
import soulsoft_identity_claims.*
import soulsoft_identity_server.services.*

public class ProfileService <: IProfileService {
    public func getProfileData(request: ProfileDataRequest): Collection<Claim> {
        // 获取所有用户 claims
        let allClaims = ArrayList<Claim>()

        // 添加示例 profile 信息
        allClaims.add(Claim("name", "张三"))
        allClaims.add(Claim("email", "zhangsan@example.com"))
        allClaims.add(Claim("picture", "xxxfffff"))

        // 根据 scopes 过滤
        return allClaims
    }
}

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.endpoints.generators

import std.collection.*
import soulsoft_identity_claims.*
import soulsoft_identity_server.validation.*

/**
 * @brief 定义用户信息响应生成器接口。
 */
public interface IUserInfoResponseGenerator {
    /**
     * @brief 根据验证通过的用户信息请求创建响应声明集合。
     * @param request 验证通过的用户信息请求。
     * @return 返回用户信息声明集合。
     */
    func createResponse(request: ValidatedUserInfoRequest): Collection<Claim>
}
